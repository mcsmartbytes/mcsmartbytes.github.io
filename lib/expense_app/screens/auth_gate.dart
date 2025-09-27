import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_list_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SupabaseClient _supabase;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    // Small delay to ensure Supabase is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = _supabase.auth.currentSession;
    return StreamBuilder<AuthState>(
      stream: _supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // If signed in, show the app
        final isSignedIn = _supabase.auth.currentSession != null;
        if (isSignedIn) {
          return ExpenseListScreen();
        }
        // Else show login
        return const LoginScreen();
      },
    );
  }
}

