import 'package:flutter/material.dart';
import '../data_repository.dart';
import '../stats.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/user_menu.dart';

class _HomeCard {
  final String route;
  final String titleKey;
  final String descKey;
  final String illustration;
  final IconData chipIcon;
  final LinearGradient gradient;
  final Color arrowColor;
  const _HomeCard(
    this.route,
    this.titleKey,
    this.descKey,
    this.illustration,
    this.chipIcon,
    this.gradient,
    this.arrowColor,
  );
}

const _cards = [
  _HomeCard(
    '/tickets',
    'tickets',
    'ticketsDesc',
    'assets/images/ui/ill_tickets.png',
    Icons.description_rounded,
    AppColors.ticketsGradient,
    Color(0xFF2563EB),
  ),
  _HomeCard(
    '/categories',
    'categories',
    'categoriesDesc',
    'assets/images/ui/ill_topics.png',
    Icons.menu_book_rounded,
    AppColors.categoriesGradient,
    Color(0xFF16A34A),
  ),
  _HomeCard(
    '/exam',
    'exam',
    'examDesc',
    'assets/images/ui/ill_exam.png',
    Icons.timer_rounded,
    AppColors.examGradient,
    Color(0xFFEA7317),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OverallStats? _stats;
  int _ticketCount = 0;
  int _ticketQuestionCount = 0;
  int _categoryCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final questions = await DataRepository.instance.loadQuestions();
    final variants = await DataRepository.instance.loadVariants();
    final categories = await DataRepository.instance.loadCategories();
    final stats = await computeOverallStats(totalQuestions: questions.length);
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _ticketCount = variants.length;
      _ticketQuestionCount = variants.fold(0, (s, v) => s + v.questionIndices.length);
      _categoryCount = categories.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Hero(),
          Transform.translate(
            offset: const Offset(0, -30),
            child: Column(
              children: [
                _StatsCard(stats: _stats),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final card in _cards)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _FeatureCard(card: card, chip: _chipFor(context, card)),
                        ),
                      const _GoalBanner(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _chipFor(BuildContext context, _HomeCard card) {
    switch (card.route) {
      case '/tickets':
        return '$_ticketCount ${appT(context, 'ticket').toLowerCase()} • $_ticketQuestionCount ${appT(context, 'questionsCount')}';
      case '/categories':
        return '$_categoryCount ${appT(context, 'categories').toLowerCase()} • ${appT(context, 'theoryAndPractice')}';
      default:
        return '20 ${appT(context, 'questionsCount')} • 25 ${appT(context, 'minutes')}';
    }
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 306,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/ui/hero_bg.png', fit: BoxFit.cover, alignment: const Alignment(0.55, 0.75)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A8A).withValues(alpha: 0.55),
                  const Color(0xFF3B4FC4).withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const UserMenu(foreground: Colors.white),
                      const SizedBox(width: 8),
                      LocaleSwitch(background: Colors.white.withValues(alpha: 0.22), foreground: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: appT(context, 'appTitlePrefix'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: appT(context, 'appTitleSuffix'),
                          style: const TextStyle(color: Color(0xFF7DD3FC)),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      shadows: [Shadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 2))],
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 230,
                    child: Text(
                      appT(context, 'heroSubtitle'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(color: Color(0x55000000), blurRadius: 8)],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFC53D), size: 20),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 168,
                          child: Text(
                            appT(context, 'heroBanner'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final OverallStats? stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = stats;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF16A34A),
                  bg: const Color(0xFFDCFCE7),
                  value: s == null ? '—' : '${s.totalQuestions}',
                  label: appT(context, 'statQuestionsLabel'),
                ),
              ),
              const _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFEDE9FE),
                  value: s == null ? '—' : '${s.averagePercent.round()}%',
                  label: appT(context, 'statAverageLabel'),
                ),
              ),
              const _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.track_changes_rounded,
                  color: const Color(0xFFEA580C),
                  bg: const Color(0xFFFFEDD5),
                  value: s == null ? '—' : '${s.topicsCompleted}',
                  label: appT(context, 'statTopicsLabel'),
                ),
              ),
              const _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFDBEAFE),
                  value: s == null ? '—' : '${s.streakDays}',
                  label: appT(context, 'statStreakLabel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, margin: const EdgeInsets.symmetric(vertical: 4), color: const Color(0xFFEEF1F6));
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String value;
  final String label;
  const _StatTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 9),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, height: 1.2, color: Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _HomeCard card;
  final String chip;
  const _FeatureCard({required this.card, required this.chip});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: card.gradient, borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(card.route),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -10,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(card.chipIcon, size: 132, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 14, 14),
                child: Row(
                  children: [
                    SizedBox(width: 104, height: 104, child: Image.asset(card.illustration, fit: BoxFit.contain)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appT(context, card.titleKey),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appT(context, card.descKey),
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.28),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.26),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(card.chipIcon, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    chip,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.chevron_right_rounded, color: card.arrowColor, size: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalBanner extends StatelessWidget {
  const _GoalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE6FA)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
            child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFFDC2626), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appT(context, 'goalTitle'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(appT(context, 'goalSubtitle'),
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6C2D6)),
        ],
      ),
    );
  }
}
