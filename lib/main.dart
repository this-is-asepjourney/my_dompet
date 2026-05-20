// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/transaction/add_transaction_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/budget/budget_screen.dart';
import 'features/gamification/gamification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => DashboardScreen()),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => AddTransactionScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => AnalyticsScreen(),
      ),
      GoRoute(path: '/budget', builder: (context, state) => BudgetScreen()),
      GoRoute(
        path: '/gamification',
        builder: (context, state) => GamificationScreen(),
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Dompet Pandu',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: _router,
    );
  }
}
