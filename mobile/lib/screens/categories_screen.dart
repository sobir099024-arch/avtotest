import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../widgets/app_scaffold.dart';
import 'quiz_screen.dart';

const _practiceCount = 20;

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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = _categories![i];
                final best = _bestByCode[c.code];
                return Card(
                  child: ListTile(
                    title: Text(c.names.get(locale)),
                    subtitle: Text('${c.count} ${appT(context, 'questionsCount')}'),
                    trailing: best != null
                        ? Text(
                            '${best.correct}/${best.total}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: () => _startPractice(c),
                  ),
                );
              },
            ),
    );
  }
}
