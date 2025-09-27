import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/supabase_expense_service.dart';
import '../theme/business_theme.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> with TickerProviderStateMixin {
  final SupabaseExpenseService _expenseService = SupabaseExpenseService();
  late TabController _tabController;
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final expenses = await _expenseService.getAllExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
        _applyFilter();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expenses: $e')),
      );
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredExpenses = _expenses.where((expense) {
        bool matchesFilter = _selectedFilter == 'All' || expense.status == _selectedFilter.toLowerCase();
        bool matchesSearch = _searchQuery.isEmpty ||
            expense.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            expense.category.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  Color _getCategoryColor(String category) {
    return BusinessTheme.getCategoryColor(category);
  }

  IconData _getCategoryIcon(String category) {
    return BusinessTheme.getCategoryIcon(category);
  }

  Color _getStatusColor(String status) {
    return BusinessTheme.getStatusColor(status);
  }

  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                bool success = await _expenseService.deleteExpense(expense.id);
                if (success) {
                  _loadExpenses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Expense deleted successfully')),
                  );
                } else {
                  throw Exception('Failed to delete expense');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting expense: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailScreen(expense: expense),
            ),
          );
          if (result == true) _loadExpenses();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(expense.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: _getCategoryColor(expense.category),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Description and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          expense.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount and status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        expense.formattedAmount,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(expense.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(expense.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // More menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(expense: expense),
                            ),
                          ).then((_) => _loadExpenses());
                          break;
                        case 'duplicate':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(
                                expense: expense.copyWith(
                                  id: _expenseService.generateNewId(),
                                  status: 'pending',
                                ),
                              ),
                            ),
                          ).then((_) => _loadExpenses());
                          break;
                        case 'delete':
                          _deleteExpense(expense);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy, size: 16),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    expense.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                    SizedBox(width: 16),
                    Icon(Icons.note, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        expense.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.receipt), text: 'Expenses'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Expenses Tab
          Column(
            children: [
              // Search and filter
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Pending', 'Approved', 'Rejected']
                            .map((filter) => Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(filter),
                                    selected: _selectedFilter == filter,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedFilter = filter;
                                        _applyFilter();
                                      });
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Expense list
              Expanded(
                child: _filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No expenses found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first expense to get started',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (context, index) {
                          return _buildExpenseCard(_filteredExpenses[index]);
                        },
                      ),
              ),
            ],
          ),
          // Analytics Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Analytics Coming Soon',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Expense reports and charts will be available here',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Profile Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Profile Settings',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'User settings and preferences',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Test Database Button
          FloatingActionButton(
            heroTag: "test",
            backgroundColor: Colors.orange,
            onPressed: () async {
              print('Testing database connection...');
              try {
                // Test basic connection via service helper
                final testResponse = await _expenseService.devTestSelectOne();
                print('Database SELECT test successful: $testResponse');
                
                // Test insert
                final testExpense = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'description': 'TEST EXPENSE - ${DateTime.now()}',
                  'category': 'Office',
                  'amount': 99.99,
                  'date': DateTime.now().toIso8601String(),
                  'status': 'pending',
                  'notes': 'This is a test expense',
                };
                
                print('Inserting test expense: $testExpense');
                final insertResponse = await _expenseService.devTestInsert(testExpense);
                print('Database INSERT test successful: $insertResponse');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Database test successful! Check console and Supabase.')),
                );
                
                _loadExpenses(); // Reload to show the test expense
              } catch (e, stackTrace) {
                print('Database test failed: $e');
                print('Stack trace: $stackTrace');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Database test failed: $e')),
                );
              }
            },
            child: Icon(Icons.science),
          ),
          SizedBox(height: 10),
          // Regular Add Button
          FloatingActionButton(
            heroTag: "add",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              );
              _loadExpenses();
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
