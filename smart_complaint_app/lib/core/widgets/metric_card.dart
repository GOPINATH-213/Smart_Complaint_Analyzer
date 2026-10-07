import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Compact enterprise Metric Summary Card optimized for mobile phones
class MetricCard extends StatelessWidget {
  final String label;
  final int count;
  final Color? accentColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const MetricCard({
    super.key,
    required this.label,
    required this.count,
    this.accentColor,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeAccentColor = accentColor ?? context.colors.primaryNavy;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r12,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeAccentColor.withValues(alpha: 0.08) : context.colors.surface,
            borderRadius: AppRadius.r12,
            border: Border.all(
              color: isSelected ? activeAccentColor : context.colors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.caption(
                      color: isSelected ? activeAccentColor : context.colors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? activeAccentColor : activeAccentColor.withValues(alpha: 0.8),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: activeAccentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: AppTextStyles.pageTitle(
                  color: isSelected ? activeAccentColor : context.colors.textPrimary,
                ).copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
