import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class _HomeCard {
  final String route;
  final String titleKey;
  final String descKey;
  final IconData icon;
  const _HomeCard(this.route, this.titleKey, this.descKey, this.icon);
}

const _cards = [
  _HomeCard('/tickets', 'tickets', 'ticketsDesc', Icons.confirmation_number_outlined),
  _HomeCard('/categories', 'categories', 'categoriesDesc', Icons.menu_book_outlined),
  _HomeCard('/exam', 'exam', 'examDesc', Icons.timer_outlined),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: appT(context, 'appTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final card in _cards)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(card.icon, size: 32, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  appT(context, card.titleKey),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(appT(context, card.descKey)),
                ),
                onTap: () => Navigator.of(context).pushNamed(card.route),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              appT(context, 'dataSource'),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
