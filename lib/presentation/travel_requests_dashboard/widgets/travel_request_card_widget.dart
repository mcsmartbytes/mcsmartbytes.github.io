import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/travel_request.dart';

class TravelRequestCardWidget extends StatelessWidget {
  final TravelRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onArchive;

  const TravelRequestCardWidget({
    super.key,
    required this.request,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onShare,
    this.onArchive,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.successLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'rejected':
      case 'cancelled':
        return AppTheme.errorLight;
      case 'draft':
        return AppTheme.lightTheme.colorScheme.outline;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.errorLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.tripName,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme.textSecondaryLight,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${request.originCity} → ${request.destinationCity}',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(request.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Travel dates and duration
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.textSecondaryLight,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${request.formattedDepartureDate} - ${request.formattedReturnDate}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${request.durationInDays} days',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Cost and priority
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'attach_money',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                        Text(
                          request.formattedTotalCost,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Priority indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(request.priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${request.priority.toUpperCase()} PRIORITY',
                        style: TextStyle(
                          color: _getPriorityColor(request.priority),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Attendees count if available
              if (request.attendees != null &&
                  request.attendees!.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'people',
                      color: AppTheme.textSecondaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${request.attendees!.length} attendees',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null && request.status == 'draft') ...[
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: CustomIconWidget(
                        iconName: 'edit',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                  if (onDuplicate != null) ...[
                    TextButton.icon(
                      onPressed: onDuplicate,
                      icon: CustomIconWidget(
                        iconName: 'content_copy',
                        color: AppTheme.textSecondaryLight,
                        size: 16,
                      ),
                      label: Text('Copy'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondaryLight,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                  if (onDelete != null && request.status == 'draft') ...[
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.errorLight,
                        size: 16,
                      ),
                      label: Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorLight,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                  TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
