import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Account Profile',
        subtitle: 'Institutional User Credentials',
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
        error: (err, _) => ErrorState(
          title: 'Unable to Load Profile',
          message: 'Failed to retrieve your profile information.',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('No profile records found.'));
          }

          final role = userProfile['role'] ?? 'Student';
          final isStudent = role == 'Student';
          final name = userProfile['name'] ?? 'User';
          final email = userProfile['email'] ?? '';
          final department = userProfile['department'] ?? 'Not Assigned';
          final phone = userProfile['phone']?.toString() ?? 'Not Provided';
          final regNum = userProfile['registerNumber']?.toString() ?? '';
          final year = userProfile['year']?.toString() ?? '';
          final employeeId = userProfile['employeeId']?.toString() ?? '';
          final designation = userProfile['designation']?.toString() ?? '';

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userProfileProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. User Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: AppRadius.r16,
                        border: Border.all(color: context.colors.border),
                        boxShadow: AppShadows.cardSubtle,
                      ),
                      child: Row(
                        children: [
                          // Avatar Monogram
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.colors.primaryNavy,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.primaryAction.withValues(alpha: 0.3)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(fontSize: 17),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  email,
                                  style: AppTextStyles.caption(color: context.colors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                // Role Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isStudent ? context.colors.infoLight : context.colors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isStudent
                                          ? context.colors.primaryAction.withValues(alpha: 0.3)
                                          : context.colors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isStudent ? Icons.school_outlined : Icons.badge_outlined,
                                        size: 11,
                                        color: isStudent ? context.colors.primaryAction : context.colors.primaryNavy,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        role,
                                        style: AppTextStyles.caption(
                                          color: isStudent ? context.colors.primaryAction : context.colors.primaryNavy,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Profile Details Section
                    Text(
                      'INSTITUTIONAL INFORMATION',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: AppRadius.r14,
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Column(
                        children: [
                          _buildProfileRow(
                            context: context,
                            icon: Icons.business_outlined,
                            label: 'Department',
                            value: department,
                          ),
                          Divider(height: 1, color: context.colors.border),

                          if (isStudent && regNum.isNotEmpty) ...[
                            _buildProfileRow(
                              context: context,
                              icon: Icons.confirmation_number_outlined,
                              label: 'Register Number',
                              value: regNum,
                            ),
                            Divider(height: 1, color: context.colors.border),
                          ],

                          if (isStudent && year.isNotEmpty) ...[
                            _buildProfileRow(
                              context: context,
                              icon: Icons.calendar_today_outlined,
                              label: 'Academic Year',
                              value: year,
                            ),
                            Divider(height: 1, color: context.colors.border),
                          ],

                          if (!isStudent && employeeId.isNotEmpty) ...[
                            _buildProfileRow(
                              context: context,
                              icon: Icons.badge_outlined,
                              label: 'Employee ID',
                              value: employeeId,
                            ),
                            Divider(height: 1, color: context.colors.border),
                          ],

                          if (!isStudent && designation.isNotEmpty) ...[
                            _buildProfileRow(
                              context: context,
                              icon: Icons.work_outline_rounded,
                              label: 'Designation',
                              value: designation,
                            ),
                            Divider(height: 1, color: context.colors.border),
                          ],

                          _buildProfileRow(
                            context: context,
                            icon: Icons.phone_outlined,
                            label: 'Contact Phone',
                            value: phone.isNotEmpty ? phone : 'Not Provided',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Account Actions
                    Text(
                      'ACCOUNT ACTIONS',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

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
                            leading: Icon(Icons.edit_outlined, color: context.colors.textSecondary, size: 20),
                            title: Text('Edit Profile Details', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
                            onTap: () => context.push('/profile-completion?role=$role'),
                          ),
                          Divider(height: 1, color: context.colors.border),
                          ListTile(
                            leading: Icon(Icons.settings_outlined, color: context.colors.textSecondary, size: 20),
                            title: Text('Settings & Preferences', style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.textMuted),
                            onTap: () => context.push('/settings'),
                          ),
                          Divider(height: 1, color: context.colors.border),
                          ListTile(
                            leading: Icon(Icons.logout_rounded, color: context.colors.error, size: 20),
                            title: Text(
                              'Sign Out',
                              style: AppTextStyles.bodyMedium(color: context.colors.error).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () async {
                              await ref.read(authRepositoryProvider).signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.textSecondary),
          const SizedBox(width: 14),
          Text(
            label,
            style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
