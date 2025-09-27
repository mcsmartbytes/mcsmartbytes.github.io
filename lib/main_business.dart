import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_app/screens/expense_list_screen.dart';
import 'expense_app/theme/business_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ombumarftwodjuwzmhea.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tYnVtYXJmdHdvZGp1d3ptaGVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNzk1NDEsImV4cCI6MjA3Mjg1NTU0MX0.f-AKwRvIwGY1WYTVYGKXIZHPuzGbywj7Hey5GeSfX9U',
  );

  runApp(MyBusinessExpenseApp());
}

class MyBusinessExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Expense Tracker',
      theme: BusinessTheme.lightTheme,
      home: ExpenseListScreen(), // Supabase mode enabled
      debugShowCheckedModeBanner: false,
    );
  }
}