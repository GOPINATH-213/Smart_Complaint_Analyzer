import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Professional Enterprise Top Navbar
class AppTopNavbar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onProfileTap;
  final bool showActions;

  const AppTopNavbar({
    super.key,
    this.title = 'Smart Complaint Analyzer',
    this.subtitle,
    this.onProfileTap,
    this.showActions = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final role = profileAsync.asData?.value?['role'] ?? 'Student';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: AppShadows.navbar,
        border: Border(
          bottom: BorderSide(
            color: context.colors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            children: [
              // SCA Brand Monogram
              InkWell(
                onTap: () {
                  final currentRoute = GoRouterState.of(context).uri.toString();
                  if (role == 'Admin') {
                    if (currentRoute != '/admin-dashboard') {
                      context.go('/admin-dashboard');
                    }
                  } else if (role == 'Department Staff') {
                    if (currentRoute != '/staff-dashboard') {
                      context.go('/staff-dashboard');
                    }
                  } else {
                    if (currentRoute != '/home') {
                      context.go('/home');
                    }
                  }
                },
                borderRadius: AppRadius.r10,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.colors.primaryNavy,
                    borderRadius: AppRadius.r10,
                    border: Border.all(
                      color: context.colors.primaryAction.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'SCA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption(color: context.colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Action Buttons
              if (showActions)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_outline_rounded, size: 20),
                      tooltip: 'Profile',
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        foregroundColor: context.colors.textSecondary,
                      ),
                      onPressed: () {
                        if (onProfileTap != null) {
                          onProfileTap!();
                        } else {
                          context.push('/profile');
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      tooltip: 'Settings',
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        foregroundColor: context.colors.textSecondary,
                      ),
                      onPressed: () => context.push('/settings'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      tooltip: 'Sign Out',
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        foregroundColor: context.colors.error,
                      ),
                      onPressed: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r16,
          side: BorderSide(color: context.colors.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: context.colors.error, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: AppTextStyles.cardTitle(color: context.colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.textPrimary,
              side: BorderSide(color: context.colors.border),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.r10),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.r10),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authRepositoryProvider).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
