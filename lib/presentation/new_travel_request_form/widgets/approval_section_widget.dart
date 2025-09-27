import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/user_profile.dart';

class ApprovalSectionWidget extends StatelessWidget {
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onToggle;
  final String selectedManager;
  final String comments;
  final List<UserProfile> managers;
  final Function(String) onManagerChanged;
  final Function(String) onCommentsChanged;

  const ApprovalSectionWidget({
    super.key,
    required this.isExpanded,
    required this.isCompleted,
    required this.onToggle,
    required this.selectedManager,
    required this.comments,
    required this.managers,
    required this.onManagerChanged,
    required this.onCommentsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? AppTheme.successLight : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Completion indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.successLight
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                    ),
                    child: isCompleted
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            '6',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.outline,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
                      'Approval & Comments',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Expand/collapse icon
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (isExpanded) ...[
            Divider(height: 1),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Manager selection
                  Text(
                    'Select Manager for Approval',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedManager.isEmpty ? null : selectedManager,
                      decoration: InputDecoration(
                        hintText: 'Choose your manager',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: managers.map((manager) {
                        return DropdownMenuItem<String>(
                          value: manager.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                manager.fullName,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${manager.role.toUpperCase()} • ${manager.department ?? "N/A"}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onManagerChanged(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a manager for approval';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Additional comments
                  Text(
                    'Additional Comments (Optional)',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      initialValue: comments,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Add any additional notes or special requests...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: onCommentsChanged,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Info box
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Approval Process',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your selected manager will be notified and can approve or reject this request. You\'ll receive an email notification with their decision.',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
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
          ],
        ],
      ),
    );
  }
}
