import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import 'quiz_screen.dart';

const _practiceCount = 20;

const _categoryIcons = [
  Icons.rule_rounded,
  Icons.signpost_rounded,
  Icons.traffic_rounded,
  Icons.local_parking_rounded,
  Icons.speed_rounded,
  Icons.warning_amber_rounded,
  Icons.directions_car_rounded,
  Icons.medical_services_rounded,
  Icons.local_shipping_rounded,
  Icons.groups_rounded,
];

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category>? _categories;
  List<Question>? _questions;
  final Map<String, AttemptRecord?> _bestByCode = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await DataRepository.instance.loadCategories();
    final questions = await DataRepository.instance.loadQuestions();
    for (final c in categories) {
      _bestByCode[c.code] = await Storage.instance.bestAttempt('category:${c.code}');
    }
    if (mounted) {
      setState(() {
        _categories = categories;
        _questions = questions;
      });
    }
  }

  void _startPractice(Category category) {
    final indices = <int>[];
    for (var i = 0; i < _questions!.length; i++) {
      if (_questions![i].category == category.code) indices.add(i);
    }
    indices.shuffle();
    final picked = indices.take(_practiceCount).toList();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              config: QuizConfig(
                questionIndices: picked,
                resultKey: 'category:${category.code}',
                revealImmediately: true,
              ),
            ),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppStateScope.of(context).locale;
    return AppScaffold(
      title: appT(context, 'categories'),
      body: _categories == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _categories!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = _categories![i];
                final best = _bestByCode[c.code];
                final color = AppColors.forIndex(i);
                final icon = _categoryIcons[i % _categoryIcons.length];
                final ratio = best == null ? null : best.correct / best.total;
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _startPractice(c),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(icon, color: color, size: 23),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.names.get(locale),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${c.count} ${appT(context, 'questionsCount')}',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                                ),
                                if (ratio != null) ...[
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 5,
                                      backgroundColor: color.withValues(alpha: 0.12),
                                      valueColor: AlwaysStoppedAnimation(color),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (best != null)
                            Text(
                              '${best.correct}/${best.total}',
                              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                            )
                          else
                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
