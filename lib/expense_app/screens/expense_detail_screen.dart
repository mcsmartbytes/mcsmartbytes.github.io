import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;

  ExpenseDetailScreen({required this.expense});

  @override
  _ExpenseDetailScreenState createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  Color _getCategoryColor() {
    switch (_expense.category.toLowerCase()) {
      case 'meals': return Colors.orange;
      case 'transportation': return Colors.blue;
      case 'office': return Colors.green;
      case 'travel': return Colors.purple;
      case 'equipment': return Colors.indigo;
      case 'software': return Colors.cyan;
      case 'training': return Colors.teal;
      case 'marketing': return Colors.pink;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (_expense.category.toLowerCase()) {
      case 'meals': return Icons.restaurant;
      case 'transportation': return Icons.directions_car;
      case 'office': return Icons.business;
      case 'travel': return Icons.flight;
      case 'equipment': return Icons.computer;
      case 'software': return Icons.apps;
      case 'training': return Icons.school;
      case 'marketing': return Icons.campaign;
      default: return Icons.receipt;
    }
  }

  Color _getStatusColor() {
    switch (_expense.status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              title: Text('Edit Expense'),
              onTap: () {
                Navigator.pop(context);
                _editExpense();
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy, color: Theme.of(context).primaryColor),
              title: Text('Duplicate Expense'),
              onTap: () {
                Navigator.pop(context);
                _duplicateExpense();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Expense', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteExpense();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _editExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: _expense),
      ),
    );
    if (result != null) {
      // Refresh the expense data
      final updatedExpense = _expenseService.getExpenseById(_expense.id);
      if (updatedExpense != null) {
        setState(() {
          _expense = updatedExpense;
        });
      }
      Navigator.pop(context, true); // Return to list with refresh
    }
  }

  void _duplicateExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          expense: _expense.copyWith(
            id: _expenseService.generateNewId(),
            status: 'pending',
          ),
        ),
      ),
    );
    Navigator.pop(context, true); // Return to list with refresh
  }

  void _deleteExpense() {
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
            onPressed: () {
              _expenseService.deleteExpense(_expense.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to list with refresh
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Expense deleted successfully')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _showActionsBottomSheet,
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
                    // Amount and status row
                    Row(
                      children: [
                        // Category icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(),
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
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _expense.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
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
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _expense.description,
                            style: TextStyle(
                              fontSize: 16,
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
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildDetailRow(
                      'Category',
                      _expense.category,
                      _getCategoryIcon(),
                    ),

                    _buildDetailRow(
                      'Date',
                      _expense.formattedDate,
                      Icons.calendar_today,
                    ),

                    _buildDetailRow(
                      'ID',
                      _expense.id,
                      Icons.fingerprint,
                    ),
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
                          Icon(Icons.note, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 18,
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
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _expense.notes!,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editExpense,
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _duplicateExpense,
                    icon: Icon(Icons.content_copy),
                    label: Text('Duplicate'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}