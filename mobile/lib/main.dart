import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/exam_start_screen.dart';

void main() {
  runApp(const AvtoTestApp());
}

class AvtoTestApp extends StatefulWidget {
  const AvtoTestApp({super.key});

  @override
  State<AvtoTestApp> createState() => _AvtoTestAppState();
}

class _AvtoTestAppState extends State<AvtoTestApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.loadLocale();
  }

  @override
  void dispose() {
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
          '/': (_) => const HomeScreen(),
          '/tickets': (_) => const TicketsScreen(),
          '/categories': (_) => const CategoriesScreen(),
          '/exam': (_) => const ExamStartScreen(),
        },
      ),
    );
  }
}
