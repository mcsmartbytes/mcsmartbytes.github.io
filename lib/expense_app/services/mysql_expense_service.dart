import 'dart:convert';
import 'dart:io';
import '../models/expense.dart';

class MySQLExpenseService {
  static final MySQLExpenseService _instance = MySQLExpenseService._internal();
  factory MySQLExpenseService() => _instance;
  MySQLExpenseService._internal();

  // Your Hostinger database configuration
  static const String _baseUrl = 'YOUR_DOMAIN.com/api'; // Your Hostinger domain
  static const String _apiKey = 'YOUR_API_KEY'; // For security

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$_baseUrl/expenses.php'));
      request.headers.set('Authorization', 'Bearer $_apiKey');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(responseBody);
        return data.map((item) => Expense.fromMap(item)).toList();
      } else {
        print('Error fetching expenses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }

  // Add new expense
  Future<bool> addExpense(Expense expense) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$_baseUrl/add_expense.php'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      
      final body = json.encode(expense.toMap());
      request.add(utf8.encode(body));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  // Update existing expense
  Future<bool> updateExpense(Expense updatedExpense) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$_baseUrl/update_expense.php'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      
      final body = json.encode(updatedExpense.toMap());
      request.add(utf8.encode(body));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating expense: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$_baseUrl/delete_expense.php'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      
      final body = json.encode({'id': id});
      request.add(utf8.encode(body));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
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

  // Generate new ID
  String generateNewId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get total expenses
  Future<double> getTotalAmount() async {
    try {
      final expenses = await getAllExpenses();
      return expenses.fold(0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      print('Error calculating total: $e');
      return 0;
    }
  }
}