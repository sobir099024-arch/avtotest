import 'package:flutter/material.dart';
import '../data_repository.dart';
import '../theme.dart';
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
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_rounded, color: Color(0xFFD97706), size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                appT(context, 'exam'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                appT(context, 'examDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.5, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 8),
              _ExamFactRow(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _start(context),
                  child: Text(appT(context, 'start')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamFactRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget fact(IconData icon, String text) => Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          fact(Icons.quiz_rounded, '$_examCount'),
          fact(Icons.schedule_rounded, '25:00'),
          fact(Icons.report_gmailerrorred_rounded, '≤ ${_examMaxErrors - 1}'),
        ],
      ),
    );
  }
}
