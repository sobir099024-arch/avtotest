import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../i18n.dart';
import '../theme.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showLocaleSwitch;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showLocaleSwitch = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (showLocaleSwitch) const Padding(padding: EdgeInsets.only(right: 12), child: LocaleSwitch()),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

class LocaleSwitch extends StatelessWidget {
  final Color? background;
  final Color? foreground;
  const LocaleSwitch({super.key, this.background, this.foreground});

  static const _shortLabel = {
    AppLocale.uzLatn: 'UZ',
    AppLocale.uzCyrl: 'ЎЗ',
    AppLocale.ru: 'RU',
  };

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final fg = foreground ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background ?? AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppLocale>(
          value: appState.locale,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(Icons.expand_more, size: 18, color: fg),
          dropdownColor: Colors.white,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13),
          items: AppLocale.values
              .map((l) => DropdownMenuItem(
                    value: l,
                    child: Text(_shortLabel[l]!, style: const TextStyle(color: AppColors.primary)),
                  ))
              .toList(),
          selectedItemBuilder: (context) => AppLocale.values
              .map((l) => Center(
                    child: Text(_shortLabel[l]!, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
                  ))
              .toList(),
          onChanged: (l) {
            if (l != null) appState.setLocale(l);
          },
        ),
      ),
    );
  }
}

String appT(BuildContext context, String key) {
  final locale = AppStateScope.of(context).locale;
  return t(key, locale);
}
