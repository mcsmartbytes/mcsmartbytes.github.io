import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';

class ExpenseDetailView extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailView({
    super.key,
    required this.expense,
  });

  @override
  State<ExpenseDetailView> createState() => _ExpenseDetailViewState();
}

class _ExpenseDetailViewState extends State<ExpenseDetailView> {
  final ExpenseService _expenseService = ExpenseService.instance;
  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  Color _getCategoryColor() {
    switch (_expense.category.toLowerCase()) {
      case 'meals':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'office':
        return Colors.green;
      case 'travel':
        return Colors.purple;
      case 'equipment':
        return Colors.indigo;
      case 'software':
        return Colors.cyan;
      case 'training':
        return Colors.teal;
      case 'marketing':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryIcon() {
    switch (_expense.category.toLowerCase()) {
      case 'meals':
        return 'restaurant';
      case 'transportation':
        return 'directions_car';
      case 'office':
        return 'business';
      case 'travel':
        return 'flight';
      case 'equipment':
        return 'computer';
      case 'software':
        return 'apps';
      case 'training':
        return 'school';
      case 'marketing':
        return 'campaign';
      default:
        return 'receipt';
    }
  }

  Color _getStatusColor() {
    switch (_expense.status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Edit Expense'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.newExpenseForm,
                  arguments: _expense,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Duplicate Expense'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.newExpenseForm,
                  arguments: _expense.copyWith(
                    id: '',
                    status: 'draft',
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Colors.red,
                size: 24,
              ),
              title: Text(
                'Delete Expense',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await _expenseService.deleteExpense(_expense.id);
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Expense deleted successfully'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete expense: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Expense Details',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          IconButton(
            onPressed: _showEditOptions,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main expense card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Category icon and amount
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CustomIconWidget(
                            iconName: _getCategoryIcon(),
                            color: _getCategoryColor(),
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _expense.formattedAmount,
                                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.lightTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor().withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _expense.status.toUpperCase(),
                                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Description
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                              color: AppTheme.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _expense.description,
                            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Details card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Details',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Category
                    _buildDetailRow(
                      'Category',
                      _expense.category,
                      'category',
                    ),

                    SizedBox(height: 12),

                    // Date
                    _buildDetailRow(
                      'Date',
                      _expense.formattedDate,
                      'calendar_today',
                    ),

                    SizedBox(height: 12),

                    // Created date
                    _buildDetailRow(
                      'Created',
                      '${_expense.createdAt.day}/${_expense.createdAt.month}/${_expense.createdAt.year}',
                      'schedule',
                    ),

                    if (_expense.updatedAt != _expense.createdAt) ...[
                      SizedBox(height: 12),
                      _buildDetailRow(
                        'Last Updated',
                        '${_expense.updatedAt.day}/${_expense.updatedAt.month}/${_expense.updatedAt.year}',
                        'update',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Notes card (if notes exist)
            if (_expense.notes != null && _expense.notes!.isNotEmpty) ...[
              SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'note',
                            color: AppTheme.textSecondaryLight,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _expense.notes!,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Receipt card (if receipt exists)
            if (_expense.receipt != null) ...[
              SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'receipt',
                            color: AppTheme.textSecondaryLight,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Receipt',
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'image',
                              color: AppTheme.textSecondaryLight,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Receipt Image',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap to view full size',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.textSecondaryLight,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}