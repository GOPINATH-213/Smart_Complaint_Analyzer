import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Section 1: Account
          Text(
            'ACCOUNT',
            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.r14,
              side: BorderSide(color: context.colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline_rounded, color: context.colors.textSecondary, size: 20),
                  title: Text('Account Profile', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  subtitle: Text('Manage your registered details', style: AppTextStyles.caption(color: context.colors.textSecondary)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
                  onTap: () => context.push('/profile'),
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.lock_reset_rounded, color: context.colors.textSecondary, size: 20),
                  title: Text('Reset Password', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  subtitle: Text('Request password recovery link', style: AppTextStyles.caption(color: context.colors.textSecondary)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
                  onTap: () => context.push('/forgot-password'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Preferences
          Text(
            'PREFERENCES',
            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.r14,
              side: BorderSide(color: context.colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: context.colors.textSecondary, size: 20),
                  title: Text('Interface Theme', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  subtitle: Text(
                    themeMode == ThemeMode.system
                        ? 'System Default'
                        : themeMode == ThemeMode.dark
                            ? 'Dark Theme'
                            : 'Light Theme',
                    style: AppTextStyles.caption(color: context.colors.textSecondary),
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox.shrink(),
                    dropdownColor: context.colors.surface,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light', style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark', style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) themeNotifier.setThemeMode(val);
                    },
                  ),
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.notifications_none_rounded, color: context.colors.textSecondary, size: 20),
                  title: Text('Notifications', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  subtitle: Text(
                    'In-app grievance status updates enabled',
                    style: AppTextStyles.caption(color: context.colors.textSecondary),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: AppTextStyles.badge(color: context.colors.success).copyWith(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: About
          Text(
            'ABOUT APPLICATION',
            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.r14,
              side: BorderSide(color: context.colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: context.colors.textSecondary, size: 20),
                  title: Text('Application Version', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  trailing: Text(
                    'v1.0.0 (Build 1)',
                    style: AppTextStyles.caption(color: context.colors.textMuted),
                  ),
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.policy_outlined, color: context.colors.textSecondary, size: 20),
                  title: Text('Institutional Guidelines', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: context.colors.surface,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
                        title: const Text('Institutional Guidelines'),
                        content: const Text(
                          'Smart Complaint Analyzer is an automated grievance classification and prioritization platform. All submitted grievances are routed through college department channels and audited under institutional guidelines.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.description_outlined, color: context.colors.textSecondary, size: 20),
                  title: Text('Terms of Use & Privacy', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: context.colors.surface,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
                        title: const Text('Privacy & Terms'),
                        content: const Text(
                          'Student and staff data are strictly maintained for institutional complaint resolution and quality audits. No data is distributed to unauthorized external third parties.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
