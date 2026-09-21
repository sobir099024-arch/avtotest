import 'package:flutter/material.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';
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
                childAspectRatio: 0.95,
              ),
              itemCount: _variants!.length,
              itemBuilder: (context, i) {
                final v = _variants![i];
                final best = _bestByNumber[v.number];
                final color = AppColors.forIndex(v.number);
                final ratio = best == null ? 0.0 : best.correct / best.total;
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 46,
                            height: 46,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 46,
                                  height: 46,
                                  child: CircularProgressIndicator(
                                    value: best == null ? 1 : ratio,
                                    strokeWidth: 3,
                                    backgroundColor: color.withValues(alpha: 0.12),
                                    valueColor: AlwaysStoppedAnimation(
                                      best == null ? color.withValues(alpha: 0.18) : color,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${v.number}',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${v.questionIndices.length} ${appT(context, 'questionsCount')}',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          ),
                          if (best != null)
                            Text(
                              '${best.correct}/${best.total}',
                              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11.5),
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
