import 'storage.dart';

class OverallStats {
  final int totalQuestions;
  final double averagePercent;
  final int topicsCompleted;
  final int streakDays;
  final int totalAttempts;

  const OverallStats({
    required this.totalQuestions,
    required this.averagePercent,
    required this.topicsCompleted,
    required this.streakDays,
    required this.totalAttempts,
  });
}

Future<OverallStats> computeOverallStats({required int totalQuestions}) async {
  final keys = await Storage.instance.allAttemptKeys();
  var sumCorrect = 0;
  var sumTotal = 0;
  var attemptCount = 0;
  final topicsWithAttempt = <String>{};
  final days = <DateTime>{};

  for (final key in keys) {
    final list = await Storage.instance.allAttempts(key);
    if (list.isEmpty) continue;
    if (key.startsWith('category:')) topicsWithAttempt.add(key);
    for (final a in list) {
      sumCorrect += a.correct;
      sumTotal += a.total;
      attemptCount++;
      days.add(DateTime(a.finishedAt.year, a.finishedAt.month, a.finishedAt.day));
    }
  }

  return OverallStats(
    totalQuestions: totalQuestions,
    averagePercent: sumTotal == 0 ? 0 : (sumCorrect / sumTotal) * 100,
    topicsCompleted: topicsWithAttempt.length,
    streakDays: _computeStreak(days),
    totalAttempts: attemptCount,
  );
}

int _computeStreak(Set<DateTime> days) {
  if (days.isEmpty) return 0;
  final today = DateTime.now();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
