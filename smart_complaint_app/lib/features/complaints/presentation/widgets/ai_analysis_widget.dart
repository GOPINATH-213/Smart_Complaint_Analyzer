import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ai_badge.dart';
import '../../data/models/complaint_model.dart';

/// Signature Gemini AI Analysis Display Widget
class AiAnalysisWidget extends StatelessWidget {
  final ComplaintModel complaint;
  final bool isStaff;
  final VoidCallback? onReanalyze;
  final bool isReanalyzing;

  const AiAnalysisWidget({
    super.key,
    required this.complaint,
    required this.isStaff,
    this.onReanalyze,
    this.isReanalyzing = false,
  });

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment.trim().toLowerCase()) {
      case 'frustrated':
      case 'angry':
        return Icons.mood_bad_rounded;
      case 'negative':
        return Icons.sentiment_dissatisfied_rounded;
      case 'positive':
        return Icons.sentiment_very_satisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = complaint.analysisStatus;

    // 1. Processing / Re-analyzing State
    if (status == 'Processing' || isReanalyzing) {
      return Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: context.colors.aiAccentSubtle,
          borderRadius: AppRadius.r14,
          border: Border.all(color: context.colors.aiAccent.withValues(alpha: 0.3)),
          boxShadow: AppShadows.cardSubtle,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(context.colors.aiAccent),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyzing Complaint with Gemini AI...',
                    style: AppTextStyles.cardTitle(color: context.colors.primaryNavy).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Classifying category, priority, sentiment & suggested response...',
                    style: AppTextStyles.caption(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Failed State
    if (status == 'Failed') {
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
                Icon(Icons.info_outline_rounded, color: context.colors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis Unavailable',
                  style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Automated AI analysis is temporarily unavailable for this complaint.',
              style: AppTextStyles.bodySmall(color: context.colors.textSecondary),
            ),
            if (isStaff && onReanalyze != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onReanalyze,
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Retry Analysis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primaryAction,
                    side: BorderSide(color: context.colors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // 3. Pending State
    if (status == 'Pending' || complaint.category == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadius.r14,
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: context.colors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI Analysis Scheduled',
                style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
              ),
            ),
            if (isStaff && onReanalyze != null)
              TextButton.icon(
                onPressed: onReanalyze,
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Analyze Now'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      );
    }

    // 4. Completed State
    final category = complaint.category ?? 'Other';
    final aiPriority = complaint.aiPriority ?? 'Medium';
    final urgency = complaint.urgency ?? 'Medium';
    final sentiment = complaint.sentiment ?? 'Neutral';
    final summary = complaint.aiSummary ?? 'No summary available.';
    final suggestedResponse = complaint.suggestedResponse ?? '';
    final confidence = complaint.aiConfidence;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r14,
        border: Border.all(color: context.colors.aiAccent.withValues(alpha: 0.4), width: 1.2),
        boxShadow: AppShadows.aiSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.aiAccentSubtle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(color: context.colors.aiAccent.withValues(alpha: 0.2), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: context.colors.aiAccent),
                    const SizedBox(width: 8),
                    Text(
                      'AI Analysis',
                      style: AppTextStyles.cardTitle(color: context.colors.primaryNavy).copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const AiBadge(label: 'Powered by Gemini'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4 Attribute Cards (Category, AI Priority, Urgency, Sentiment)
                Row(
                  children: [
                    Expanded(
                      child: _buildAttributeBox(
                        context: context,
                        label: 'Category',
                        value: category,
                        color: context.colors.primaryNavy,
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAttributeBox(
                        context: context,
                        label: 'AI Priority',
                        value: aiPriority,
                        color: context.colors.getPriorityColor(aiPriority),
                        icon: Icons.flag_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildAttributeBox(
                        context: context,
                        label: 'Urgency',
                        value: urgency,
                        color: context.colors.getUrgencyColor(urgency),
                        icon: Icons.speed_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAttributeBox(
                        context: context,
                        label: 'Sentiment',
                        value: sentiment,
                        color: context.colors.getSentimentColor(sentiment),
                        icon: _getSentimentIcon(sentiment),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // AI Summary
                Text(
                  'AI SUMMARY',
                  style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: AppRadius.r8,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Text(
                    summary,
                    style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(
                      height: 1.45,
                    ),
                  ),
                ),

                // Suggested Response (for staff or informational for student)
                if (suggestedResponse.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUGGESTED RESPONSE',
                        style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isStaff)
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: suggestedResponse));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Draft response copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: AppRadius.r6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 12, color: context.colors.primaryAction),
                                const SizedBox(width: 4),
                                Text(
                                  'Copy Draft',
                                  style: AppTextStyles.caption(color: context.colors.primaryAction).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceSecondary,
                      borderRadius: AppRadius.r8,
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Text(
                      suggestedResponse,
                      style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],

                // Staff Footer: Confidence Score & Re-analyze Action
                if (isStaff) ...[
                  const SizedBox(height: 16),
                  Divider(color: context.colors.border),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_outlined, size: 14, color: context.colors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            confidence != null
                                ? 'Model Confidence: ${(confidence * 100).toStringAsFixed(0)}%'
                                : 'Analysis Confidence: High',
                            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (onReanalyze != null)
                        TextButton.icon(
                          onPressed: onReanalyze,
                          icon: const Icon(Icons.refresh_rounded, size: 14),
                          label: const Text('Re-analyze'),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.primaryNavy,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeBox({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: AppRadius.r8,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: context.colors.textMuted),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.cardTitle(color: color).copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
