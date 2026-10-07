import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ai_badge.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/complaint_model.dart';

/// Compact, informative enterprise Complaint Card
class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${complaint.createdAt.day.toString().padLeft(2, '0')}/${complaint.createdAt.month.toString().padLeft(2, '0')}/${complaint.createdAt.year}';

    final hasAiAnalysis = complaint.category != null && complaint.category!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r14,
        border: Border.all(color: context.colors.border, width: 1),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.r14,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r14,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: ID + AI Badge + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceSecondary,
                            borderRadius: AppRadius.r6,
                            border: Border.all(color: context.colors.border, width: 1),
                          ),
                          child: Text(
                            complaint.complaintId,
                            style: AppTextStyles.codeOrId(),
                          ),
                        ),
                        if (hasAiAnalysis) ...[
                          const SizedBox(width: 8),
                          const AiBadge(label: 'AI Analyzed'),
                        ],
                      ],
                    ),
                    StatusBadge(status: complaint.status, isCompact: true),
                  ],
                ),
                const SizedBox(height: 10),

                // Complaint Title
                Text(
                  complaint.title,
                  style: AppTextStyles.cardTitle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Metadata Bottom Row: Department + Priority + Date
                Row(
                  children: [
                    // Department
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceSecondary,
                        borderRadius: AppRadius.r6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 11,
                            color: context.colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            complaint.department,
                            style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Priority
                    PriorityBadge(priority: complaint.priority, isCompact: true),

                    const Spacer(),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: context.colors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: AppTextStyles.caption(color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
