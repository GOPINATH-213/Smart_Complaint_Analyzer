import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable subtle AI indicator badge
class AiBadge extends StatelessWidget {
  final String label;
  final bool isGlowing;

  const AiBadge({
    super.key,
    this.label = 'Powered by Gemini',
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.aiAccentSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.aiAccent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 11,
            color: context.colors.aiAccent,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.badge(color: const Color(0xFF0E7490)).copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
