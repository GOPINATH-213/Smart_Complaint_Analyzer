import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'package:smart_complaint_app/features/admin/presentation/providers/admin_provider.dart';

class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends ConsumerState<AdminStaffScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _activeSearchQuery = '';
  String _selectedDepartment = 'All';

  final List<String> _departments = [
    'All',
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'IT',
    'CIVIL',
    'MBA',
    'MCA',
    'Office',
    'Hostel',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && _activeSearchQuery != value) {
        setState(() {
          _activeSearchQuery = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(adminStaffProvider((search: _activeSearchQuery, department: _selectedDepartment)));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Staff Directory',
        subtitle: 'Department Personnel',
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by staff name, employee ID, email...',
                    hintStyle: AppTextStyles.bodyMedium(color: context.colors.textMuted),
                    prefixIcon: Icon(Icons.search_rounded, color: context.colors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: context.colors.surfaceSecondary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.r12,
                      borderSide: BorderSide(color: context.colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.r12,
                      borderSide: BorderSide(color: context.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.r12,
                      borderSide: BorderSide(color: context.colors.primaryAction, width: 1.5),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),

                // Department Filter Dropdown Row
                Row(
                  children: [
                    Text(
                      'Department Filter:',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceSecondary,
                          borderRadius: AppRadius.r10,
                          border: Border.all(color: context.colors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _departments.contains(_selectedDepartment) ? _selectedDepartment : 'All',
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.textSecondary),
                            style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(fontSize: 13),
                            dropdownColor: context.colors.surface,
                            items: _departments.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept,
                                child: Text(
                                  dept,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDepartment = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Staff List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminStaffProvider);
              },
              child: staffAsync.when(
                data: (staffMembers) {
                  if (staffMembers.isEmpty) {
                    return const EmptyState(
                      title: 'No Department Staff Found',
                      description: 'No staff records match the specified department or search criteria.',
                      icon: Icons.badge_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: staffMembers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final staff = staffMembers[index];
                      return _buildStaffCard(context, staff);
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => const SkeletonBox(height: 90),
                ),
                error: (err, stack) => ErrorState(
                  message: 'Failed to load department staff directory',
                  onRetry: () => ref.refresh(adminStaffProvider((search: _activeSearchQuery, department: _selectedDepartment))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, Map<String, dynamic> staff) {
    final name = staff['name'] ?? 'Staff Member';
    final email = staff['email'] ?? 'No Email';
    final empId = staff['employeeId'] ?? staff['empId'] ?? 'N/A';
    final dept = staff['department'] ?? 'Not Assigned';
    final designation = staff['designation'] ?? 'Staff Member';
    final isCompleted = staff['isProfileCompleted'] == true;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r14,
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.r14,
        child: InkWell(
          onTap: () => _showStaffDetailsModal(context, staff),
          borderRadius: AppRadius.r14,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar Badge
                CircleAvatar(
                  radius: 22,
                  backgroundColor: context.colors.primaryNavy.withValues(alpha: 0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: TextStyle(
                      color: context.colors.primaryNavy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.cardTitle().copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? context.colors.successLight
                                  : context.colors.warningLight,
                              borderRadius: AppRadius.r8,
                            ),
                            child: Text(
                              isCompleted ? 'Verified Staff' : 'Pending Setup',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? context.colors.success
                                    : context.colors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTextStyles.caption(color: context.colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildDetailChip(
                            context,
                            icon: Icons.badge_outlined,
                            text: 'Emp ID: $empId',
                          ),
                          _buildDetailChip(
                            context,
                            icon: Icons.business_outlined,
                            text: dept,
                          ),
                          _buildDetailChip(
                            context,
                            icon: Icons.work_outline_rounded,
                            text: designation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, {required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: AppRadius.r6,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: context.colors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showStaffDetailsModal(BuildContext context, Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Department Staff Profile',
                    style: AppTextStyles.cardTitle().copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildModalDetailRow(context, 'Full Name', staff['name'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Email Address', staff['email'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Employee ID', staff['employeeId'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Assigned Department', staff['department'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Designation', staff['designation'] ?? 'Department Staff'),
              _buildModalDetailRow(context, 'Role', staff['role'] ?? 'Department Staff'),
              _buildModalDetailRow(context, 'Firebase UID', staff['firebaseUID'] ?? 'N/A'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
