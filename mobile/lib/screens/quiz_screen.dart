import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../widgets/app_scaffold.dart';

enum StopReason { completed, tooManyErrors, timeUp }

class QuizConfig {
  final List<int> questionIndices;
  final String resultKey;
  final bool revealImmediately;
  final int? timeLimitSec;
  final int? stopOnErrors;

  const QuizConfig({
    required this.questionIndices,
    required this.resultKey,
    required this.revealImmediately,
    this.timeLimitSec,
    this.stopOnErrors,
  });
}

class QuizScreen extends StatefulWidget {
  final QuizConfig config;
  const QuizScreen({super.key, required this.config});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question>? _questions;
  int _index = 0;
  final Map<int, int> _selected = {};
  StopReason? _finished;
  int _timeLeft = 0;
  Timer? _timer;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.config.timeLimitSec ?? 0;
    _load();
  }

  Future<void> _load() async {
    final all = await DataRepository.instance.loadQuestions();
    final qs = widget.config.questionIndices.map((i) => all[i]).toList();
    if (!mounted) return;
    setState(() => _questions = qs);
    if (widget.config.timeLimitSec != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_finished != null) {
          t.cancel();
          return;
        }
        setState(() {
          _timeLeft -= 1;
          if (_timeLeft <= 0) {
            _timeLeft = 0;
            _finish(StopReason.timeUp);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _correctCount {
    var n = 0;
    _selected.forEach((qi, ansIdx) {
      final q = _questions![qi];
      if (q.answers[ansIdx].correct) n++;
    });
    return n;
  }

  int get _wrongCount => _selected.length - _correctCount;

  void _finish(StopReason reason) {
    if (_finished != null) return;
    _timer?.cancel();
    setState(() => _finished = reason);
    if (!_saved) {
      _saved = true;
      Storage.instance.recordAttempt(
        widget.config.resultKey,
        AttemptRecord(correct: _correctCount, total: _questions!.length, finishedAt: DateTime.now()),
      );
    }
  }

  void _choose(int ansIdx) {
    if (_selected.containsKey(_index)) return;
    setState(() => _selected[_index] = ansIdx);
    if (widget.config.stopOnErrors != null && _wrongCount >= widget.config.stopOnErrors!) {
      _finish(StopReason.tooManyErrors);
    }
  }

  void _next() {
    if (_index == _questions!.length - 1) {
      _finish(StopReason.completed);
    } else {
      setState(() => _index += 1);
    }
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppStateScope.of(context).locale;

    if (_questions == null) {
      return AppScaffold(title: '', body: const Center(child: CircularProgressIndicator()));
    }

    if (_finished != null) {
      return _ResultView(
        questions: _questions!,
        selected: _selected,
        finished: _finished!,
        correctCount: _correctCount,
        onRetry: () {
          setState(() {
            _index = 0;
            _selected.clear();
            _finished = null;
            _saved = false;
            _timeLeft = widget.config.timeLimitSec ?? 0;
          });
          if (widget.config.timeLimitSec != null) {
            _timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (_finished != null) {
                t.cancel();
                return;
              }
              setState(() {
                _timeLeft -= 1;
                if (_timeLeft <= 0) {
                  _timeLeft = 0;
                  _finish(StopReason.timeUp);
                }
              });
            });
          }
        },
      );
    }

    final q = _questions![_index];
    final chosen = _selected[_index];
    final correctIdx = q.correctIndex;
    final isLast = _index == _questions!.length - 1;

    return AppScaffold(
      title: '${appT(context, 'question')} ${_index + 1}/${_questions!.length}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.config.timeLimitSec != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${appT(context, 'timeLeft')}: ${_formatTime(_timeLeft)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: _timeLeft < 60 ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(q.texts.get(locale), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                if (q.hasImage)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appT(context, 'imageMissing'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),
                for (var ai = 0; ai < q.answers.length; ai++)
                  _AnswerButton(
                    text: q.answers[ai].texts.get(locale),
                    state: _answerState(ai, chosen, correctIdx),
                    onTap: () => _choose(ai),
                  ),
                if (widget.config.revealImmediately && chosen != null && q.explanation[locale.code] != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appT(context, 'explanation'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        for (final block in q.explanation[locale.code]!)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(block.text, style: const TextStyle(fontSize: 13)),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: chosen == null ? null : _next,
                child: Text(isLast ? appT(context, 'finish') : appT(context, 'next')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _AnswerState _answerState(int ai, int? chosen, int correctIdx) {
    if (chosen == null) return _AnswerState.idle;
    if (widget.config.revealImmediately) {
      if (ai == correctIdx) return _AnswerState.correct;
      if (ai == chosen) return _AnswerState.wrong;
      return _AnswerState.idle;
    }
    return ai == chosen ? _AnswerState.selected : _AnswerState.idle;
  }
}

enum _AnswerState { idle, selected, correct, wrong }

class _AnswerButton extends StatelessWidget {
  final String text;
  final _AnswerState state;
  final VoidCallback onTap;

  const _AnswerButton({required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color border = Colors.grey.shade300;
    Color? bg;
    switch (state) {
      case _AnswerState.idle:
        break;
      case _AnswerState.selected:
        border = Colors.blue;
        bg = Colors.blue.shade50;
        break;
      case _AnswerState.correct:
        border = Colors.green;
        bg = Colors.green.shade50;
        break;
      case _AnswerState.wrong:
        border = Colors.red;
        bg = Colors.red.shade50;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12),
            color: bg,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final List<Question> questions;
  final Map<int, int> selected;
  final StopReason finished;
  final int correctCount;
  final VoidCallback onRetry;

  const _ResultView({
    required this.questions,
    required this.selected,
    required this.finished,
    required this.correctCount,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppStateScope.of(context).locale;
    final passed = correctCount >= (questions.length * 0.9).ceil();

    return AppScaffold(
      title: appT(context, 'yourResult'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '$correctCount/${questions.length}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.blue),
                ),
                if (finished == StopReason.tooManyErrors)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(appT(context, 'stoppedTooManyErrors'), style: const TextStyle(color: Colors.red)),
                  ),
                if (finished == StopReason.timeUp)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(appT(context, 'stoppedTimeUp'), style: const TextStyle(color: Colors.orange)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: passed ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      passed ? appT(context, 'passed') : appT(context, 'failed'),
                      style: TextStyle(
                        color: passed ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(appT(context, 'reviewAnswers'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          for (var qi = 0; qi < questions.length; qi++) ..._reviewRow(context, locale, qi),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(onPressed: onRetry, child: Text(appT(context, 'tryAgain'))),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Text(appT(context, 'backHome')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _reviewRow(BuildContext context, dynamic locale, int qi) {
    final q = questions[qi];
    final ans = selected[qi];
    final correctIdx = q.correctIndex;
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${qi + 1}. ${q.texts.get(locale)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${appT(context, 'yourAnswer')}: ', style: const TextStyle(color: Colors.grey)),
                  TextSpan(
                    text: ans == null ? appT(context, 'noAnswer') : q.answers[ans].texts.get(locale),
                    style: TextStyle(
                      color: ans == null ? Colors.grey : (q.answers[ans].correct ? Colors.green.shade700 : Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
            if (ans != null && !q.answers[ans].correct)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${appT(context, 'correct')}: ', style: const TextStyle(color: Colors.grey)),
                    TextSpan(text: q.answers[correctIdx].texts.get(locale), style: TextStyle(color: Colors.green.shade700)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }
}
