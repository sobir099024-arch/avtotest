import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';
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
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    if (widget.config.timeLimitSec == null) return;
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

  void _retry() {
    _timer?.cancel();
    setState(() {
      _index = 0;
      _selected.clear();
      _finished = null;
      _saved = false;
      _timeLeft = widget.config.timeLimitSec ?? 0;
    });
    _startTimerIfNeeded();
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_finished != null) {
      return _ResultView(
        questions: _questions!,
        selected: _selected,
        finished: _finished!,
        correctCount: _correctCount,
        onRetry: _retry,
      );
    }

    final q = _questions![_index];
    final chosen = _selected[_index];
    final correctIdx = q.correctIndex;
    final isLast = _index == _questions!.length - 1;
    final progress = (_index + (chosen != null ? 1 : 0)) / _questions!.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${appT(context, 'question')} ${_index + 1}/${_questions!.length}'),
        actions: [
          if (widget.config.timeLimitSec != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (_timeLeft < 60 ? AppColors.danger : AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 15, color: _timeLeft < 60 ? AppColors.danger : AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        _formatTime(_timeLeft),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: _timeLeft < 60 ? AppColors.danger : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 4,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(q.texts.get(locale), style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, height: 1.35)),
                  if (q.hasImage && q.image != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      constraints: const BoxConstraints(maxHeight: 260),
                      width: double.infinity,
                      child: Image.asset('assets/${q.image}', fit: BoxFit.contain),
                    ),
                  if (q.hasImage && q.image == null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 26),
                          const SizedBox(height: 6),
                          Text(
                            appT(context, 'imageMissing'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  for (var ai = 0; ai < q.answers.length; ai++)
                    _AnswerButton(
                      letter: String.fromCharCode(65 + ai),
                      text: q.answers[ai].texts.get(locale),
                      state: _answerState(ai, chosen, correctIdx),
                      onTap: () => _choose(ai),
                    ),
                  if (widget.config.revealImmediately && chosen != null && q.explanation[locale.code] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, size: 17, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(appT(context, 'explanation'),
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          for (final block in q.explanation[locale.code]!)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(block.text, style: const TextStyle(fontSize: 13, height: 1.4)),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: chosen == null ? null : _next,
                  icon: Icon(isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded, size: 18),
                  label: Text(isLast ? appT(context, 'finish') : appT(context, 'next')),
                ),
              ),
            ),
          ],
        ),
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
  final String letter;
  final String text;
  final _AnswerState state;
  final VoidCallback onTap;

  const _AnswerButton({required this.letter, required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color border = Colors.grey.shade300;
    Color bg = Colors.white;
    Color badgeBg = Colors.grey.shade100;
    Color badgeFg = Colors.grey.shade600;
    Widget? trailing;

    switch (state) {
      case _AnswerState.idle:
        break;
      case _AnswerState.selected:
        border = AppColors.primary;
        bg = AppColors.primary.withValues(alpha: 0.06);
        badgeBg = AppColors.primary;
        badgeFg = Colors.white;
        break;
      case _AnswerState.correct:
        border = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.07);
        badgeBg = AppColors.success;
        badgeFg = Colors.white;
        trailing = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20);
        break;
      case _AnswerState.wrong:
        border = AppColors.danger;
        bg = AppColors.danger.withValues(alpha: 0.07);
        badgeBg = AppColors.danger;
        badgeFg = Colors.white;
        trailing = const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 20);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: border, width: state == _AnswerState.idle ? 1 : 1.5),
            borderRadius: BorderRadius.circular(14),
            color: bg,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
                child: Text(letter, style: TextStyle(color: badgeFg, fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5, height: 1.3))),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
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
    final total = questions.length;
    final ratio = total == 0 ? 0.0 : correctCount / total;
    final passed = correctCount >= (total * 0.9).ceil();
    final color = passed ? AppColors.success : AppColors.danger;

    return Scaffold(
      appBar: AppBar(title: Text(appT(context, 'yourResult'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: SizedBox(
                width: 168,
                height: 168,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 168,
                      height: 168,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$correctCount/$total',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
                        Text('${(ratio * 100).round()}%', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(passed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      passed ? appT(context, 'passed') : appT(context, 'failed'),
                      style: TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            if (finished == StopReason.tooManyErrors)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(appT(context, 'stoppedTooManyErrors'),
                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                ),
              ),
            if (finished == StopReason.timeUp)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(appT(context, 'stoppedTimeUp'),
                      style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500)),
                ),
              ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(appT(context, 'tryAgain')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: Text(appT(context, 'backHome')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(appT(context, 'reviewAnswers'),
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 10),
            for (var qi = 0; qi < questions.length; qi++) _reviewCard(context, locale, qi),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(BuildContext context, dynamic locale, int qi) {
    final q = questions[qi];
    final ans = selected[qi];
    final correctIdx = q.correctIndex;
    final isCorrect = ans != null && q.answers[ans].correct;
    final statusColor = ans == null ? Colors.grey : (isCorrect ? AppColors.success : AppColors.danger);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                ans == null ? Icons.remove_circle_outline_rounded : (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded),
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${qi + 1}. ${q.texts.get(locale)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${appT(context, 'yourAnswer')}: ', style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
                      TextSpan(
                        text: ans == null ? appT(context, 'noAnswer') : q.answers[ans].texts.get(locale),
                        style: TextStyle(color: statusColor, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (ans != null && !isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${appT(context, 'correct')}: ', style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
                          TextSpan(
                            text: q.answers[correctIdx].texts.get(locale),
                            style: const TextStyle(color: AppColors.success, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
