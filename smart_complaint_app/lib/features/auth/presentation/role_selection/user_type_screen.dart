import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Clean enterprise Role Selection Screen
class UserTypeScreen extends ConsumerStatefulWidget {
  final String from;

  const UserTypeScreen({super.key, this.from = 'register'});

  @override
  ConsumerState<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends ConsumerState<UserTypeScreen> {
  void _handleRoleSelection(String role) {
    if (widget.from == 'google') {
      context.push('/profile-completion?role=$role');
    } else {
      context.push('/register?role=$role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Account Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Indicator
              Row(
                children: [
                  _buildStepIndicator(context: context, step: '1', label: 'Account Type', isActive: true),
                  _buildStepDivider(context),
                  _buildStepIndicator(context: context, step: '2', label: 'Details', isActive: false),
                  _buildStepDivider(context),
                  _buildStepIndicator(context: context, step: '3', label: 'Verify', isActive: false),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Select Your Role',
                style: AppTextStyles.pageTitle().copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your institutional affiliation to configure proper portal access and permissions.',
                style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Selection Cards
              _buildRoleCard(
                context,
                title: 'Student',
                description: 'Submit and track institutional complaints.',
                icon: Icons.school_outlined,
                onTap: () => _handleRoleSelection('Student'),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: 'Department Staff',
                description: 'Manage and resolve department complaints.',
                icon: Icons.badge_outlined,
                onTap: () => _handleRoleSelection('Department Staff'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required BuildContext context, required String step, required String label, required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? context.colors.primaryAction : context.colors.surfaceSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? context.colors.primaryAction : context.colors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: TextStyle(
              color: isActive ? Colors.white : context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption(
            color: isActive ? context.colors.primaryNavy : context.colors.textMuted,
          ).copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStepDivider(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        color: context.colors.border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r14,
        border: Border.all(color: context.colors.border, width: 1.2),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.r14,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r14,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: AppRadius.r12,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Icon(icon, size: 24, color: context.colors.primaryNavy),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle().copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.bodyMedium(color: context.colors.textSecondary).copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
