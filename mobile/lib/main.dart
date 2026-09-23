import 'package:flutter/material.dart';
import 'ad_manager.dart';
import 'app_state.dart';
import 'cloud_sync.dart';
import 'theme.dart';
import 'screens/root_shell.dart';
import 'screens/tickets_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/exam_start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  AdManager.instance.init();
  runApp(const AvtoTestApp());
}

class AvtoTestApp extends StatefulWidget {
  const AvtoTestApp({super.key});

  @override
  State<AvtoTestApp> createState() => _AvtoTestAppState();
}

class _AvtoTestAppState extends State<AvtoTestApp> with WidgetsBindingObserver {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.loadLocale();
    _appState.initAuth();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => AdManager.instance.maybeShow());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdManager.instance.maybeShow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'AvtoTest',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const RootShell(),
          '/tickets': (_) => const TicketsScreen(),
          '/categories': (_) => const CategoriesScreen(),
          '/exam': (_) => const ExamStartScreen(),
        },
      ),
    );
  }
}
