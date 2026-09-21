import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../i18n.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AppLocale>(
                  value: appState.locale,
                  items: AppLocale.values
                      .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                      .toList(),
                  onChanged: (l) {
                    if (l != null) appState.setLocale(l);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

String appT(BuildContext context, String key) {
  final locale = AppStateScope.of(context).locale;
  return t(key, locale);
}
