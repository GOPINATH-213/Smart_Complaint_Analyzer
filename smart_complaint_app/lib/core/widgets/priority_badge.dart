import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable enterprise Priority Badge
class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  IconData _getPriorityIcon(String p) {
    switch (p.trim().toLowerCase()) {
      case 'high':
        return Icons.arrow_upward_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'low':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.getPriorityColor(priority);
    final lightColor = context.colors.getPriorityLightColor(priority);
    final icon = _getPriorityIcon(priority);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 9,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isCompact ? 10 : 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority,
            style: AppTextStyles.badge(color: color).copyWith(
              fontSize: isCompact ? 10.5 : 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
