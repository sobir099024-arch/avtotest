import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'cloud_sync.dart';
import 'models.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  AppLocale locale = AppLocale.uzLatn;
  User? user;
  bool authLoading = firebaseEnabled;
  StreamSubscription<User?>? _authSub;

  Future<void> loadLocale() async {
    locale = await Storage.instance.getLocale();
    notifyListeners();
  }

  Future<void> setLocale(AppLocale l) async {
    locale = l;
    notifyListeners();
    await Storage.instance.setLocale(l);
  }

  void initAuth() {
    if (!firebaseEnabled) return;
    _authSub = CloudSync.instance.userChanges.listen((u) async {
      user = u;
      authLoading = false;
      notifyListeners();
      await CloudSync.instance.onUserChanged(u);
    });
  }

  Future<void> signIn() => CloudSync.instance.signInWithGoogle();

  Future<void> signOut() => CloudSync.instance.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
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
