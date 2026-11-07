import 'package:flutter/material.dart';
import 'package:my_expense/page/auth/login/login_view_model.dart';
import 'package:my_expense/page/auth/register/register_view_model.dart';
import 'package:my_expense/page/dashboard/dashboard_view_model.dart';
import 'package:my_expense/page/landing.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Expense',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3D2C8D),
      ),
      home: const LandingPage(),
    );
  }
}
