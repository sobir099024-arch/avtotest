import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data_repository.dart';
import '../models.dart';
import '../stats.dart';
import '../storage.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  OverallStats? _stats;
  List<Category>? _categories;
  final Map<String, AttemptRecord?> _bestByCategory = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final questions = await DataRepository.instance.loadQuestions();
    final categories = await DataRepository.instance.loadCategories();
    final stats = await computeOverallStats(totalQuestions: questions.length);
    for (final c in categories) {
      _bestByCategory[c.code] = await Storage.instance.bestAttempt('category:${c.code}');
    }
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppStateScope.of(context).locale;
    final stats = _stats;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(appT(context, 'navStats'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (stats == null)
              const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
            else ...[
              Text(appT(context, 'statsOverall'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _BigStat(
                      icon: Icons.insights_rounded,
                      color: const Color(0xFF7C3AED),
                      value: '${stats.averagePercent.round()}%',
                      label: appT(context, 'statAverageLabel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigStat(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                      value: '${stats.streakDays}',
                      label: appT(context, 'statStreakLabel'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _BigStat(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.warning,
                      value: '${stats.topicsCompleted}/${_categories?.length ?? 0}',
                      label: appT(context, 'statTopicsLabel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigStat(
                      icon: Icons.fact_check_rounded,
                      color: AppColors.secondary,
                      value: '${stats.totalAttempts}',
                      label: appT(context, 'totalAttempts'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(appT(context, 'statsByTopic'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 10),
              if (_categories == null || _categories!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(appT(context, 'noAttemptsYet'), style: TextStyle(color: Colors.grey.shade500)),
                )
              else
                for (var i = 0; i < _categories!.length; i++) _categoryRow(context, locale, i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(BuildContext context, dynamic locale, int i) {
    final c = _categories![i];
    final best = _bestByCategory[c.code];
    final color = AppColors.forIndex(i);
    final ratio = best == null ? 0.0 : best.correct / best.total;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.names.get(locale), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            best == null ? '—' : '${best.correct}/${best.total}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _BigStat({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
