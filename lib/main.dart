import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/supabase_service.dart';

// Import our clean expense tracker screens
import 'expense_app/screens/expense_list_screen.dart';
import 'expense_app/models/expense.dart';
import 'expense_app/services/expense_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using --dart-define-from-file=env.json
  // Requires SUPABASE_URL and SUPABASE_ANON_KEY in env.json
  try {
    await SupabaseService.initialize();
    // Optional: simple ping can be added here if needed
  } catch (e) {
    // If keys are missing or invalid, log the error; app can still run for in-memory mode
    // But Supabase calls will fail until configured
    // ignore: avoid_print
    print('Supabase initialization error: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyExpenseApp());
}

class MyExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[600],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
      ),
      home: ExpenseListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
