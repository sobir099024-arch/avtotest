import 'package:flutter/widgets.dart';
import 'models.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  AppLocale locale = AppLocale.uzLatn;

  Future<void> loadLocale() async {
    locale = await Storage.instance.getLocale();
    notifyListeners();
  }

  Future<void> setLocale(AppLocale l) async {
    locale = l;
    notifyListeners();
    await Storage.instance.setLocale(l);
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}
