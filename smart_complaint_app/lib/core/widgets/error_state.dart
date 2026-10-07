import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Clean enterprise Error State widget
/// Prevents exposing raw server or database stack traces to end users
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Unable to Load Data',
    this.message = 'Something went wrong while communicating with the server. Please try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colors.errorLight,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.error.withValues(alpha: 0.2), width: 1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Retry',
                  style: AppTextStyles.button(color: context.colors.primaryNavy).copyWith(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primaryNavy,
                  side: BorderSide(color: context.colors.border, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.r10),
                  minimumSize: const Size(0, 42),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
