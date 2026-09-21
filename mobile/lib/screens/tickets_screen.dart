import 'package:flutter/material.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../widgets/app_scaffold.dart';
import 'quiz_screen.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<Variant>? _variants;
  final Map<int, AttemptRecord?> _bestByNumber = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final variants = await DataRepository.instance.loadVariants();
    for (final v in variants) {
      _bestByNumber[v.number] = await Storage.instance.bestAttempt('variant:${v.number}');
    }
    if (mounted) setState(() => _variants = variants);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: appT(context, 'tickets'),
      body: _variants == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _variants!.length,
              itemBuilder: (context, i) {
                final v = _variants![i];
                final best = _bestByNumber[v.number];
                return Card(
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            config: QuizConfig(
                              questionIndices: v.questionIndices,
                              resultKey: 'variant:${v.number}',
                              revealImmediately: true,
                            ),
                          ),
                        ),
                      );
                      _load();
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${appT(context, 'ticket')} ${v.number}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${v.questionIndices.length} ${appT(context, 'questionsCount')}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          if (best != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${best.correct}/${best.total}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
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
