import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

typedef AttemptListener = void Function(String key, List<AttemptRecord> list);

class Storage {
  Storage._();
  static final Storage instance = Storage._();

  static const _localeKey = 'avtotest:locale';
  static const _attemptsPrefix = 'avtotest:attempts:';
  static const _favoritesKey = 'avtotest:favorites';

  /// Cloud sync registers here to learn about every new local attempt.
  AttemptListener? _listener;
  void setAttemptListener(AttemptListener? fn) => _listener = fn;

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

  Future<List<AttemptRecord>> _read(SharedPreferences prefs, String key) async {
    final raw = prefs.getString('$_attemptsPrefix$key');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(SharedPreferences prefs, String key, List<AttemptRecord> list) async {
    await prefs.setString('$_attemptsPrefix$key', jsonEncode(list.map((a) => a.toJson()).toList()));
  }

  Future<void> recordAttempt(String key, AttemptRecord attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _read(prefs, key);
    list.add(attempt);
    final trimmed = list.length > 20 ? list.sublist(list.length - 20) : list;
    await _write(prefs, key, trimmed);
    _listener?.call(key, trimmed);
  }

  /// Merges a list pulled from the cloud into local storage (used right
  /// after login, so progress made on another device isn't lost).
  Future<void> mergeAttempts(String key, List<AttemptRecord> incoming) async {
    final prefs = await SharedPreferences.getInstance();
    final local = await _read(prefs, key);
    final byTime = {for (final a in local) a.finishedAt.toIso8601String(): a};
    for (final a in incoming) {
      byTime[a.finishedAt.toIso8601String()] = a;
    }
    final merged = byTime.values.toList()..sort((a, b) => a.finishedAt.compareTo(b.finishedAt));
    final trimmed = merged.length > 20 ? merged.sublist(merged.length - 20) : merged;
    await _write(prefs, key, trimmed);
  }

  Future<AttemptRecord?> bestAttempt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _read(prefs, key);
    if (list.isEmpty) return null;
    return list.reduce((best, a) => a.correct > best.correct ? a : best);
  }

  Future<List<AttemptRecord>> allAttempts(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs, key);
  }

  Future<List<String>> allAttemptKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((k) => k.startsWith(_attemptsPrefix)).map((k) => k.substring(_attemptsPrefix.length)).toList();
  }

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
  }

  Future<Set<String>> toggleFavorite(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_favoritesKey) ?? const []).toSet();
    if (!set.remove(questionId)) set.add(questionId);
    await prefs.setStringList(_favoritesKey, set.toList());
    return set;
  }
}
