import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

/// Reusable enterprise button component with variants, loading state, and icon support
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 48.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = context.colors.primaryAction;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = context.colors.surfaceSecondary;
        fg = context.colors.textPrimary;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = context.colors.primaryNavy;
        side = BorderSide(color: context.colors.border, width: 1.2);
        break;
      case AppButtonVariant.danger:
        bg = context.colors.error;
        fg = Colors.white;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: isEnabled ? fg : context.colors.textMuted),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.button(
              color: isEnabled ? fg : context.colors.textMuted,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        text,
        style: AppTextStyles.button(
          color: isEnabled ? fg : context.colors.textMuted,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: variant == AppButtonVariant.outline
              ? Colors.transparent
              : context.colors.surfaceSecondary,
          disabledForegroundColor: context.colors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r12,
            side: side,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: content,
      ),
    );
  }
}
