import '../models/expense.dart';

class ExpenseService {
  static ExpenseService? _instance;
  static ExpenseService get instance => _instance ??= ExpenseService._();
  
  ExpenseService._();

  // Temporary implementation - replace with actual Supabase calls
  Future<List<Expense>> getUserExpenses() async {
    // TODO: Replace with actual Supabase query
    // For now, return mock data
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    
    return [
      Expense(
        id: '1',
        userId: 'user123',
        description: 'Office supplies',
        category: 'Office',
        amount: 45.99,
        date: DateTime.now().subtract(Duration(days: 2)),
        status: 'pending',
        notes: 'Pens, paper, and notebooks',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Expense(
        id: '2',
        userId: 'user123',
        description: 'Client lunch',
        category: 'Meals',
        amount: 89.50,
        date: DateTime.now().subtract(Duration(days: 5)),
        status: 'approved',
        notes: 'Lunch with potential client',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      Expense(
        id: '3',
        userId: 'user123',
        description: 'Gas for company car',
        category: 'Transportation',
        amount: 65.00,
        date: DateTime.now().subtract(Duration(days: 1)),
        status: 'pending',
        notes: 'Fuel for client visit',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  Future<void> createExpense(Map<String, dynamic> expenseData) async {
    // TODO: Implement Supabase creation logic
    await Future.delayed(Duration(milliseconds: 300));
    print('Creating expense: $expenseData');
  }

  Future<void> updateExpense(String id, Map<String, dynamic> expenseData) async {
    // TODO: Implement Supabase update logic
    await Future.delayed(Duration(milliseconds: 300));
    print('Updating expense $id: $expenseData');
  }

  Future<void> deleteExpense(String id) async {
    // TODO: Implement Supabase deletion logic
    await Future.delayed(Duration(milliseconds: 300));
    print('Deleting expense: $id');
  }

  List<String> getExpenseCategories() {
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
}