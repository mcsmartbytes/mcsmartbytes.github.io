import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../models/expense.dart';

class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const ExpenseCardWidget({
    super.key,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Description and amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          expense.category,
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        expense.formattedAmount,
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.status.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Options menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'duplicate':
                          onDuplicate?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'edit',
                              size: 16,
                              color: AppTheme.textSecondaryLight,
                            ),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'content_copy',
                              size: 16,
                              color: AppTheme.textSecondaryLight,
                            ),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'delete',
                              size: 16,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: CustomIconWidget(
                      iconName: 'more_vert',
                      color: AppTheme.textSecondaryLight,
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Date and notes
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    size: 14,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 4),
                  Text(
                    expense.formattedDate,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                    SizedBox(width: 16),
                    CustomIconWidget(
                      iconName: 'note',
                      size: 14,
                      color: AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        expense.notes!,
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
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

  String _getCategoryIcon() {
    switch (expense.category.toLowerCase()) {
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

  Color _getCategoryColor() {
    switch (expense.category.toLowerCase()) {
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

  Color _getStatusColor() {
    switch (expense.status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}