import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/complaint_model.dart';

/// Clean enterprise vertical Status Timeline widget
class StatusTimelineWidget extends StatelessWidget {
  final List<StatusHistoryItem> statusHistory;
  final String currentStatus;

  const StatusTimelineWidget({
    super.key,
    required this.statusHistory,
    this.currentStatus = 'Submitted',
  });

  IconData _getStatusIcon(String status) {
    switch (status.trim().toLowerCase()) {
      case 'submitted':
        return Icons.send_rounded;
      case 'in progress':
        return Icons.pending_actions_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'closed':
        return Icons.lock_outline_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadius.r12,
          border: Border.all(color: context.colors.border),
        ),
        child: Text(
          'No timeline history recorded yet.',
          style: AppTextStyles.bodyMedium(color: context.colors.textMuted),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r14,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.linear_scale_rounded, size: 18, color: context.colors.primaryNavy),
              const SizedBox(width: 8),
              Text(
                'Status Progression',
                style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statusHistory.length,
            itemBuilder: (context, index) {
              final item = statusHistory[index];
              final isLast = index == statusHistory.length - 1;
              final color = context.colors.getStatusColor(item.status);
              final icon = _getStatusIcon(item.status);

              final dateFormatted =
                  '${item.changedAt.day.toString().padLeft(2, '0')}/${item.changedAt.month.toString().padLeft(2, '0')}/${item.changedAt.year} at ${item.changedAt.hour.toString().padLeft(2, '0')}:${item.changedAt.minute.toString().padLeft(2, '0')}';

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Node + Connecting Line
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Icon(icon, size: 15, color: color),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: context.colors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Content details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 4.0 : 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.status,
                                  style: AppTextStyles.cardTitle(color: color).copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  dateFormatted,
                                  style: AppTextStyles.caption(color: context.colors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Updated by ${item.changedBy}',
                              style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.remarks.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceSecondary,
                                  borderRadius: AppRadius.r8,
                                  border: Border.all(color: context.colors.border),
                                ),
                                child: Text(
                                  item.remarks,
                                  style: AppTextStyles.bodySmall(color: context.colors.textPrimary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
