import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable enterprise Status Badge
/// Combines semantic color, meaningful icon, and clear text label
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  IconData _getStatusIcon(String s) {
    switch (s.trim().toLowerCase()) {
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
    final color = context.colors.getStatusColor(status);
    final lightColor = context.colors.getStatusLightColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isCompact ? 11 : 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
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
