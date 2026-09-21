import 'package:flutter/material.dart';
import '../data_repository.dart';
import '../widgets/app_scaffold.dart';
import 'quiz_screen.dart';

const _examCount = 20;
const _examTimeSec = 25 * 60;
const _examMaxErrors = 3;

class ExamStartScreen extends StatelessWidget {
  const ExamStartScreen({super.key});

  Future<void> _start(BuildContext context) async {
    final all = await DataRepository.instance.loadQuestions();
    final indices = List<int>.generate(all.length, (i) => i)..shuffle();
    final picked = indices.take(_examCount).toList();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          config: QuizConfig(
            questionIndices: picked,
            resultKey: 'exam',
            revealImmediately: false,
            timeLimitSec: _examTimeSec,
            stopOnErrors: _examMaxErrors,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: appT(context, 'exam'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appT(context, 'examDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _start(context),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                child: Text(appT(context, 'start')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
