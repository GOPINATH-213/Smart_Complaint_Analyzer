import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_complaint_app/core/theme/app_colors.dart';
import 'package:smart_complaint_app/core/theme/app_radius.dart';
import 'package:smart_complaint_app/core/theme/app_shadows.dart';
import 'package:smart_complaint_app/core/theme/app_text_styles.dart';
import 'package:smart_complaint_app/core/widgets/app_top_navbar.dart';
import 'package:smart_complaint_app/core/widgets/error_state.dart';
import 'package:smart_complaint_app/core/widgets/metric_card.dart';
import 'package:smart_complaint_app/core/widgets/skeleton_loader.dart';
import 'package:smart_complaint_app/features/admin/presentation/providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'System Administration',
        subtitle: 'Institutional Oversight Portal',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primaryNavy,
                      context.colors.primaryAction,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.r16,
                  boxShadow: AppShadows.cardSubtle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppRadius.r10,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Administrator Control Desk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Manage institutional departments, user directories, and assign complaints across department teams.',
                      style: AppTextStyles.bodyMedium(color: Colors.white.withValues(alpha: 0.9)).copyWith(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Metrics Overview Section
              Text(
                'Institutional Overview',
                style: AppTextStyles.cardTitle().copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),

              statsAsync.when(
                data: (stats) {
                  final totalStudents = (stats['totalStudents'] as num?)?.toInt() ?? 0;
                  final totalStaff = (stats['totalStaff'] as num?)?.toInt() ?? 0;
                  final totalDepartments = (stats['totalDepartments'] as num?)?.toInt() ?? 0;
                  final totalComplaints = (stats['totalComplaints'] as num?)?.toInt() ?? 0;

                  return Column(
                    children: [
                      // Primary Grid Cards
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          MetricCard(
                            label: 'Students',
                            count: totalStudents,
                            accentColor: context.colors.info,
                            icon: Icons.school_outlined,
                            onTap: () => context.push('/admin/students'),
                          ),
                          MetricCard(
                            label: 'Staff',
                            count: totalStaff,
                            accentColor: context.colors.primaryNavy,
                            icon: Icons.badge_outlined,
                            onTap: () => context.push('/admin/staff'),
                          ),
                          MetricCard(
                            label: 'Departments',
                            count: totalDepartments,
                            accentColor: context.colors.textSecondary,
                            icon: Icons.business_outlined,
                            onTap: () => context.push('/admin/departments'),
                          ),
                          MetricCard(
                            label: 'Complaints',
                            count: totalComplaints,
                            accentColor: context.colors.primaryAction,
                            icon: Icons.assignment_outlined,
                            onTap: () => context.push('/admin/complaints'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Secondary Status Distribution Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStatTile(
                              context,
                              label: 'Submitted',
                              value: '${stats['submitted'] ?? 0}',
                              color: context.colors.info,
                              icon: Icons.new_releases_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniStatTile(
                              context,
                              label: 'In Progress',
                              value: '${stats['inProgress'] ?? 0}',
                              color: context.colors.warning,
                              icon: Icons.pending_actions_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniStatTile(
                              context,
                              label: 'Resolved',
                              value: '${stats['resolved'] ?? 0}',
                              color: context.colors.success,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniStatTile(
                              context,
                              label: 'Urgent',
                              value: '${stats['urgent'] ?? 0}',
                              color: context.colors.error,
                              icon: Icons.local_fire_department_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(child: SkeletonBox(height: 100)),
                        SizedBox(width: 12),
                        Expanded(child: SkeletonBox(height: 100)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: SkeletonBox(height: 100)),
                        SizedBox(width: 12),
                        Expanded(child: SkeletonBox(height: 100)),
                      ],
                    ),
                  ],
                ),
                error: (err, stack) => ErrorState(
                  message: 'Failed to load system metrics',
                  onRetry: () => ref.refresh(adminDashboardStatsProvider),
                ),
              ),
              const SizedBox(height: 28),

              // Quick Administration Hub Section
              Text(
                'Administrative Directories & Queue',
                style: AppTextStyles.cardTitle().copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),

              _buildAdminNavTile(
                context,
                title: 'Student Directory',
                subtitle: 'View, search, and filter all registered students across departments.',
                icon: Icons.people_outline_rounded,
                iconBg: context.colors.infoLight,
                iconColor: context.colors.info,
                onTap: () => context.push('/admin/students'),
              ),
              const SizedBox(height: 12),

              _buildAdminNavTile(
                context,
                title: 'Department Staff Directory',
                subtitle: 'View staff members, designations, and assigned department teams.',
                icon: Icons.groups_outlined,
                iconBg: context.colors.primaryNavy.withValues(alpha: 0.1),
                iconColor: context.colors.primaryNavy,
                onTap: () => context.push('/admin/staff'),
              ),
              const SizedBox(height: 12),

              _buildAdminNavTile(
                context,
                title: 'Department Management',
                subtitle: 'Overview of department workload, student/staff allocation, and active queues.',
                icon: Icons.domain_rounded,
                iconBg: context.colors.surfaceSecondary,
                iconColor: context.colors.textSecondary,
                onTap: () => context.push('/admin/departments'),
              ),
              const SizedBox(height: 12),

              _buildAdminNavTile(
                context,
                title: 'All Complaints & Department Assignment',
                subtitle: 'View institutional complaints, examine AI recommendations, and reassign departments.',
                icon: Icons.rule_folder_rounded,
                iconBg: context.colors.primaryAction.withValues(alpha: 0.1),
                iconColor: context.colors.primaryAction,
                onTap: () => context.push('/admin/complaints'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r12,
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNavTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: AppRadius.r12,
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle().copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium(color: context.colors.textSecondary).copyWith(
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
