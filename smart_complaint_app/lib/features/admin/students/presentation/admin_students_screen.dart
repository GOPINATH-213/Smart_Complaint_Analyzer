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

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  ConsumerState<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
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
    final studentsAsync = ref.watch(adminStudentsProvider((search: _activeSearchQuery, department: _selectedDepartment)));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Student Directory',
        subtitle: 'All Registered Students',
      ),
      body: Column(
        children: [
          // Filter & Search Controls Header
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by student name, reg number, email...',
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

          // Students List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminStudentsProvider);
              },
              child: studentsAsync.when(
                data: (students) {
                  if (students.isEmpty) {
                    return const EmptyState(
                      title: 'No Students Found',
                      description: 'No student accounts match the specified department or search criteria.',
                      icon: Icons.school_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentCard(context, student);
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
                  message: 'Failed to load students directory',
                  onRetry: () => ref.refresh(adminStudentsProvider((search: _activeSearchQuery, department: _selectedDepartment))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> student) {
    final name = student['name'] ?? 'Student User';
    final email = student['email'] ?? 'No Email';
    final regNum = student['registerNumber'] ?? student['regNum'] ?? 'N/A';
    final dept = student['department'] ?? 'Not Assigned';
    final year = student['year'] ?? '';
    final isCompleted = student['isProfileCompleted'] == true;

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
          onTap: () => _showStudentDetailsModal(context, student),
          borderRadius: AppRadius.r14,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar Badge
                CircleAvatar(
                  radius: 22,
                  backgroundColor: context.colors.infoLight,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: TextStyle(
                      color: context.colors.info,
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
                              isCompleted ? 'Profile Complete' : 'Pending Setup',
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
                            text: 'Reg: $regNum',
                          ),
                          _buildDetailChip(
                            context,
                            icon: Icons.business_outlined,
                            text: dept,
                          ),
                          if (year.isNotEmpty)
                            _buildDetailChip(
                              context,
                              icon: Icons.calendar_today_outlined,
                              text: year,
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

  void _showStudentDetailsModal(BuildContext context, Map<String, dynamic> student) {
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
                    'Student Profile Record',
                    style: AppTextStyles.cardTitle().copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildModalDetailRow(context, 'Full Name', student['name'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Email Address', student['email'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Register Number', student['registerNumber'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Department', student['department'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Year of Study', student['year'] ?? 'N/A'),
              _buildModalDetailRow(context, 'Role', student['role'] ?? 'Student'),
              _buildModalDetailRow(context, 'Firebase UID', student['firebaseUID'] ?? 'N/A'),
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
