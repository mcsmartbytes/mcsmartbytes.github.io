import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class SupabaseExpenseService {
  static final SupabaseExpenseService _instance = SupabaseExpenseService._internal();
  factory SupabaseExpenseService() => _instance;
  SupabaseExpenseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    try {
      print('Fetching expenses from Supabase...');
      final response = await _supabase
          .from('expenses')
          .select()
          .order('date', ascending: false);
      
      print('Supabase fetch response: $response');
      print('Response type: ${response.runtimeType}');
      print('Response length: ${(response as List).length}');
      
      return (response as List)
          .map((data) => Expense.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching expenses: $e');
      print('Error details: ${e.runtimeType}');
      return [];
    }
  }

  // Get expenses by status
  Future<List<Expense>> getExpensesByStatus(String status) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('status', status)
          .order('date', ascending: false);
      
      return (response as List)
          .map((data) => Expense.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching expenses by status: $e');
      return [];
    }
  }

  // Add new expense
  Future<bool> addExpense(Expense expense) async {
    try {
      print('=== ADDING EXPENSE START ===');
      print('Expense data: ${expense.toMap()}');
      print('Supabase client status: ${_supabase.toString()}');
      
      final response = await _supabase
          .from('expenses')
          .insert(expense.toMap())
          .select();
      
      print('Insert successful! Response: $response');
      print('=== ADDING EXPENSE SUCCESS ===');
      return true;
    } catch (e, stackTrace) {
      print('=== ADDING EXPENSE ERROR ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      print('=== ADDING EXPENSE ERROR END ===');
      return false;
    }
  }

  // Update existing expense
  Future<bool> updateExpense(Expense updatedExpense) async {
    try {
      await _supabase
          .from('expenses')
          .update(updatedExpense.toMap())
          .eq('id', updatedExpense.id);
      return true;
    } catch (e) {
      print('Error updating expense: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      await _supabase
          .from('expenses')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(String id) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('id', id)
          .single();
      
      return Expense.fromMap(response);
    } catch (e) {
      print('Error fetching expense by ID: $e');
      return null;
    }
  }

  // Generate new ID (UUID)
  String generateNewId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get available categories
  List<String> getCategories() {
    return [
      'Meals',
      'Transportation', 
      'Office',
      'Travel',
      'Equipment',
      'Software',
      'Training',
      'Marketing',
      'Other',
    ];
  }

  // Get total expenses
  Future<double> getTotalAmount() async {
    try {
      final response = await _supabase
          .from('expenses')
          .select('amount');
      
      double total = 0;
      for (var expense in response) {
        total += (expense['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error calculating total: $e');
      return 0;
    }
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String())
          .order('date', ascending: false);
      
      return (response as List)
          .map((data) => Expense.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching expenses by date range: $e');
      return [];
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('category', category)
          .order('date', ascending: false);
      
      return (response as List)
          .map((data) => Expense.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching expenses by category: $e');
      return [];
    }
  }

  // Get monthly summary
  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      
      final expenses = await getExpensesByDateRange(startDate, endDate);
      Map<String, double> summary = {};
      
      for (var expense in expenses) {
        summary[expense.category] = (summary[expense.category] ?? 0) + expense.amount;
      }
      
      return summary;
    } catch (e) {
      print('Error fetching monthly summary: $e');
      return {};
    }
  }

  // ===== Development helpers (no private field access from UI) =====
  Future<dynamic> devTestSelectOne() async {
    return await _supabase.from('expenses').select().limit(1);
  }

  Future<dynamic> devTestInsert(Map<String, dynamic> data) async {
    return await _supabase.from('expenses').insert(data).select();
  }
}
