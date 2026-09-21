import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class Storage {
  Storage._();
  static final Storage instance = Storage._();

  static const _localeKey = 'avtotest:locale';
  static const _attemptsPrefix = 'avtotest:attempts:';

  Future<AppLocale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null) return AppLocale.uzLatn;
    return AppLocaleCode.fromCode(code);
  }

  Future<void> setLocale(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.code);
  }

  Future<void> recordAttempt(String key, AttemptRecord attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_attemptsPrefix$key');
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
            .toList()
        : <AttemptRecord>[];
    list.add(attempt);
    final trimmed = list.length > 20 ? list.sublist(list.length - 20) : list;
    await prefs.setString(
      '$_attemptsPrefix$key',
      jsonEncode(trimmed.map((a) => a.toJson()).toList()),
    );
  }

  Future<AttemptRecord?> bestAttempt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_attemptsPrefix$key');
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    if (list.isEmpty) return null;
    return list.reduce((best, a) => a.correct > best.correct ? a : best);
  }
}
