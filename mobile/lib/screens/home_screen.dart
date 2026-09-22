import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/user_menu.dart';

class _HomeCard {
  final String route;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final Color color;
  const _HomeCard(this.route, this.titleKey, this.descKey, this.icon, this.color);
}

const _cards = [
  _HomeCard('/tickets', 'tickets', 'ticketsDesc', Icons.confirmation_number_rounded, Color(0xFF2563EB)),
  _HomeCard('/categories', 'categories', 'categoriesDesc', Icons.menu_book_rounded, Color(0xFF16A34A)),
  _HomeCard('/exam', 'exam', 'examDesc', Icons.timer_rounded, Color(0xFFD97706)),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Hero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  for (final card in _cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _FeatureCard(card: card),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    appT(context, 'dataSource'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const UserMenu(foreground: Colors.white),
              const SizedBox(width: 8),
              LocaleSwitch(background: Colors.white.withValues(alpha: 0.16), foreground: Colors.white),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appT(context, 'appTitle'),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appT(context, 'heroSubtitle'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _HomeCard card;
  const _FeatureCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).pushNamed(card.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(card.icon, color: card.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appT(context, card.titleKey), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(
                      appT(context, card.descKey),
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
