import '../models/expense.dart';

class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  // In-memory storage (replace with database/API calls)
  final List<Expense> _expenses = [
    Expense(
      id: '1',
      description: 'Office supplies',
      category: 'Office',
      amount: 45.99,
      date: DateTime.now().subtract(Duration(days: 2)),
      status: 'pending',
      notes: 'Pens, paper, and notebooks for the team',
    ),
    Expense(
      id: '2',
      description: 'Client lunch meeting',
      category: 'Meals',
      amount: 89.50,
      date: DateTime.now().subtract(Duration(days: 5)),
      status: 'approved',
      notes: 'Lunch with Johnson & Associates',
    ),
    Expense(
      id: '3',
      description: 'Gas for company car',
      category: 'Transportation',
      amount: 65.00,
      date: DateTime.now().subtract(Duration(days: 1)),
      status: 'pending',
      notes: 'Fuel for client visits downtown',
    ),
    Expense(
      id: '4',
      description: 'Software subscription',
      category: 'Software',
      amount: 29.99,
      date: DateTime.now().subtract(Duration(days: 7)),
      status: 'approved',
      notes: 'Monthly Adobe Creative Suite license',
    ),
    Expense(
      id: '5',
      description: 'Conference tickets',
      category: 'Training',
      amount: 299.00,
      date: DateTime.now().subtract(Duration(days: 3)),
      status: 'pending',
      notes: 'Tech conference for professional development',
    ),
  ];

  // Get all expenses
  List<Expense> getAllExpenses() {
    return List.from(_expenses)..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get expenses by status
  List<Expense> getExpensesByStatus(String status) {
    return _expenses.where((e) => e.status == status).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Add new expense
  void addExpense(Expense expense) {
    _expenses.add(expense);
  }

  // Update existing expense
  void updateExpense(Expense updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
    }
  }

  // Delete expense
  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
  }

  // Get expense by ID
  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Generate new ID
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
  double getTotalAmount() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((e) => 
      e.date.isAfter(start.subtract(Duration(days: 1))) && 
      e.date.isBefore(end.add(Duration(days: 1)))
    ).toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}