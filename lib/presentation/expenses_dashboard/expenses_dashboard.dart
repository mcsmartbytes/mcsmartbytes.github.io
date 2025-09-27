import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/expense_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/expense_card_widget.dart';

class ExpensesDashboard extends StatefulWidget {
  const ExpensesDashboard({super.key});

  @override
  State<ExpensesDashboard> createState() => _ExpensesDashboardState();
}

class _ExpensesDashboardState extends State<ExpensesDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final ExpenseService _expenseService = ExpenseService.instance;
  final AuthService _authService = AuthService.instance;

  List<String> activeFilters = ['Recent'];
  bool isLoading = true;
  String lastSyncTime = '';
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _loadExpenses();
    _updateLastSyncTime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() => isLoading = true);
      final expenseList = await _expenseService.getUserExpenses();
      setState(() {
        expenses = expenseList;
        isLoading = false;
        _applyFilters();
      });
      _updateLastSyncTime();
    } catch (error) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load expenses: $error');
    }
  }

  void _applyFilters() {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        // Filter by status
        bool matchesStatus = activeFilters.isEmpty ||
            activeFilters.contains('All') ||
            activeFilters.contains('Recent') ||
            activeFilters.any((filter) =>
                expense.status.toLowerCase() == filter.toLowerCase());

        // Filter by search query
        bool matchesSearch = searchQuery.isEmpty ||
            expense.description.toLowerCase().contains(searchQuery) ||
            expense.category.toLowerCase().contains(searchQuery) ||
            expense.amount.toString().contains(searchQuery);

        return matchesStatus && matchesSearch;
      }).toList();

      // Sort by date (most recent first)
      filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _updateLastSyncTime() {
    setState(() {
      lastSyncTime =
          'Last synced: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _handleRefresh() async {
    await _loadExpenses();
  }

  void _removeFilter(String filter) {
    setState(() {
      activeFilters.remove(filter);
      _applyFilters();
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'All',
                'Recent',
                'Pending',
                'Approved',
                'Rejected',
              ]
                  .map((status) => FilterChip(
                        label: Text(status),
                        selected: activeFilters.contains(status),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (!activeFilters.contains(status)) {
                                activeFilters.add(status);
                              }
                            } else {
                              activeFilters.remove(status);
                            }
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  Future<void> _handleDelete(Expense expense) async {
    try {
      await _expenseService.deleteExpense(expense.id);
      _showSuccessSnackBar('Expense deleted successfully');
      _loadExpenses();
    } catch (error) {
      _showErrorSnackBar('Failed to delete expense: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search and filter
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.borderLight,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search expenses...',
                              prefixIcon: CustomIconWidget(
                                iconName: 'search',
                                color: AppTheme.textSecondaryLight,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showFilterOptions,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'filter_list',
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'receipt',
                              color: _tabController.index == 0
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textSecondaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Expenses'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'analytics',
                              color: _tabController.index == 1
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textSecondaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Analytics'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'person',
                              color: _tabController.index == 2
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textSecondaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Profile'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            if (activeFilters.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: activeFilters
                        .map((filter) => FilterChipWidget(
                              label: filter,
                              count: expenses
                                  .where((expense) =>
                                      expense.status.toLowerCase() ==
                                      filter.toLowerCase())
                                  .length,
                              onRemove: () => _removeFilter(filter),
                            ))
                        .toList(),
                  ),
                ),
              ),

            // Last sync time
            if (lastSyncTime.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  lastSyncTime,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Expenses Tab
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : filteredExpenses.isEmpty
                          ? EmptyStateWidget(
                              onCreateExpense: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.newExpenseForm);
                              },
                            )
                          : RefreshIndicator(
                              key: _refreshIndicatorKey,
                              onRefresh: _handleRefresh,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredExpenses.length,
                                itemBuilder: (context, index) {
                                  final expense = filteredExpenses[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: ExpenseCardWidget(
                                      expense: expense,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.expenseDetailView,
                                          arguments: expense,
                                        );
                                      },
                                      onEdit: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.newExpenseForm,
                                          arguments: expense,
                                        );
                                      },
                                      onDuplicate: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.newExpenseForm,
                                          arguments: expense.copyWith(
                                            id: '',
                                            status: 'pending',
                                          ),
                                        );
                                      },
                                      onDelete: () {
                                        _showDeleteConfirmation(expense);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                  // Analytics Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'analytics',
                          color: AppTheme.textSecondaryLight,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Analytics View',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Expense reports and charts coming soon',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Profile Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.textSecondaryLight,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Profile Settings',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.profileSettings);
                          },
                          child: Text('Open Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.newExpenseForm);
        },
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(expense);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}