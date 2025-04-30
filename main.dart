import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/billing_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Initialize sqflite for web
  databaseFactory = databaseFactoryFfiWeb;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillingProvider(),
      child: MaterialApp(
        title: 'TATA Retail Solutions',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.orange,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
