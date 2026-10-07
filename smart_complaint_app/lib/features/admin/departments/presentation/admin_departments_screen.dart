import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'package:smart_complaint_app/features/admin/presentation/providers/admin_provider.dart';

class AdminDepartmentsScreen extends ConsumerWidget {
  const AdminDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(adminDepartmentsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Departments Overview',
        subtitle: 'Institutional Operational Units',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDepartmentsProvider);
        },
        child: departmentsAsync.when(
          data: (departments) {
            if (departments.isEmpty) {
              return const EmptyState(
                title: 'No Departments Found',
                description: 'No departments registered in system.',
                icon: Icons.business_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: departments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dept = departments[index];
                return _buildDepartmentCard(context, dept);
              },
            );
          },
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => const SkeletonBox(height: 110),
          ),
          error: (err, stack) => ErrorState(
            message: 'Failed to load department overview',
            onRetry: () => ref.refresh(adminDepartmentsProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, Map<String, dynamic> dept) {
    final name = dept['department'] ?? 'Unnamed Department';
    final studentCount = dept['studentCount'] ?? 0;
    final staffCount = dept['staffCount'] ?? 0;
    final totalComplaints = dept['totalComplaints'] ?? 0;
    final pendingComplaints = dept['pendingComplaints'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r16,
        border: Border.all(color: context.colors.border, width: 1.2),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: AppRadius.r12,
                  ),
                  child: Icon(
                    Icons.domain_rounded,
                    color: context.colors.primaryNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.cardTitle().copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Academic / Institutional Unit',
                        style: AppTextStyles.caption(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onPressed: () {
                    context.push('/admin/complaints?dept=$name');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Students',
                    value: '$studentCount',
                    icon: Icons.school_outlined,
                    color: context.colors.info,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Staff',
                    value: '$staffCount',
                    icon: Icons.badge_outlined,
                    color: context.colors.primaryNavy,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Total Tickets',
                    value: '$totalComplaints',
                    icon: Icons.assignment_outlined,
                    color: context.colors.primaryAction,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Pending',
                    value: '$pendingComplaints',
                    icon: Icons.pending_actions_rounded,
                    color: context.colors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
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
    );
  }
}
