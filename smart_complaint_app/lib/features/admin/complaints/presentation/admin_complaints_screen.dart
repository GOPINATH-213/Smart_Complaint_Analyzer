import 'dart:async';
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
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../complaints/data/models/complaint_model.dart';
import 'package:smart_complaint_app/features/admin/presentation/providers/admin_provider.dart';

class AdminComplaintsScreen extends ConsumerStatefulWidget {
  final String? initialDept;

  const AdminComplaintsScreen({super.key, this.initialDept});

  @override
  ConsumerState<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends ConsumerState<AdminComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _activeSearchQuery = '';
  late String _selectedDepartment;
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

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

  final List<String> _statuses = ['All', 'Submitted', 'In Progress', 'Resolved', 'Closed'];
  final List<String> _priorities = ['All', 'Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.initialDept ?? 'All';
  }

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
    final complaintsAsync = ref.watch(
      adminComplaintsProvider((
        search: _activeSearchQuery,
        department: _selectedDepartment,
        status: _selectedStatus,
        priority: _selectedPriority,
        category: null,
      )),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Institutional Complaints',
        subtitle: 'All Tickets & Department Assignment',
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search complaint ID, title, student name...',
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

                // Multi-Filter Dropdowns Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Department Dropdown
                      _buildFilterDropdown(
                        context,
                        label: 'Dept:',
                        value: _departments.contains(_selectedDepartment) ? _selectedDepartment : 'All',
                        items: _departments,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDepartment = val);
                        },
                      ),
                      const SizedBox(width: 10),

                      // Status Dropdown
                      _buildFilterDropdown(
                        context,
                        label: 'Status:',
                        value: _selectedStatus,
                        items: _statuses,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                      const SizedBox(width: 10),

                      // Priority Dropdown
                      _buildFilterDropdown(
                        context,
                        label: 'Priority:',
                        value: _selectedPriority,
                        items: _priorities,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPriority = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Complaints List Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminComplaintsProvider);
              },
              child: complaintsAsync.when(
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return const EmptyState(
                      title: 'No Complaints Found',
                      description: 'No complaints match the specified department, status, or search filters.',
                      icon: Icons.assignment_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: complaints.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      return _buildAdminComplaintCard(context, ref, complaint);
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => const SkeletonBox(height: 130),
                ),
                error: (err, stack) => ErrorState(
                  message: 'Failed to load complaints queue',
                  onRetry: () => ref.refresh(
                    adminComplaintsProvider((
                      search: _activeSearchQuery,
                      department: _selectedDepartment,
                      status: _selectedStatus,
                      priority: _selectedPriority,
                      category: null,
                    )),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: AppRadius.r10,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.colors.textSecondary),
              style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
              ),
              dropdownColor: context.colors.surface,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminComplaintCard(BuildContext context, WidgetRef ref, ComplaintModel complaint) {
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
          onTap: () => context.push('/complaint-detail/${complaint.complaintId}'),
          borderRadius: AppRadius.r14,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: ID, Badges
                Row(
                  children: [
                    Text(
                      complaint.complaintId,
                      style: AppTextStyles.caption(color: context.colors.primaryNavy).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: complaint.status),
                    const SizedBox(width: 6),
                    PriorityBadge(priority: complaint.priority),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  complaint.title,
                  style: AppTextStyles.cardTitle().copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Student & Department Info
                Text(
                  'Submitted by: ${complaint.studentName} (${complaint.studentRegisterNumber.isNotEmpty ? complaint.studentRegisterNumber : "No Reg"})',
                  style: AppTextStyles.caption(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 10),

                // Department & AI Category Banner
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: AppRadius.r10,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Department:',
                              style: AppTextStyles.caption(color: context.colors.textMuted).copyWith(
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              complaint.department,
                              style: AppTextStyles.caption(color: context.colors.primaryNavy).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (complaint.assignedStaffName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Staff: ${complaint.assignedStaffName}',
                                style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (complaint.category != null && complaint.category!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'AI Category: ${complaint.category}',
                                style: AppTextStyles.caption(color: context.colors.primaryAction).copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Reassign Action Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primaryAction,
                          side: BorderSide(color: context.colors.primaryAction.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                        label: const Text('Assign Dept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () => _showAssignDepartmentDialog(context, ref, complaint),
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

  void _showAssignDepartmentDialog(BuildContext context, WidgetRef ref, ComplaintModel complaint) {
    String selectedDept = complaint.department;
    String? selectedStaffUID;
    String? selectedStaffName;
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: context.colors.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.r16,
                side: BorderSide(color: context.colors.border),
              ),
              title: Row(
                children: [
                  Icon(Icons.assignment_ind_rounded, color: context.colors.primaryAction, size: 22),
                  const SizedBox(width: 8),
                  Text('Assign Department', style: AppTextStyles.cardTitle()),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaint ID: ${complaint.complaintId}',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint.title,
                      style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // AI Suggestion Banner
                    if (complaint.category != null && complaint.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: context.colors.infoLight,
                          borderRadius: AppRadius.r10,
                          border: Border.all(color: context.colors.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: context.colors.info, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI Suggested Category: ${complaint.category}',
                                style: TextStyle(
                                  color: context.colors.info,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Text(
                      'Select Target Department:',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceSecondary,
                        borderRadius: AppRadius.r10,
                        border: Border.all(color: context.colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDept,
                          isExpanded: true,
                          style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(fontSize: 13),
                          dropdownColor: context.colors.surface,
                          items: _departments.where((d) => d != 'All').map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept,
                              child: Text(dept, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null && val != selectedDept) {
                              setDialogState(() {
                                selectedDept = val;
                                selectedStaffUID = null;
                                selectedStaffName = null;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Select Staff Member (Optional):',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Consumer(
                      builder: (context, ref, child) {
                        final staffAsync = ref.watch(adminStaffProvider((search: null, department: selectedDept)));
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceSecondary,
                            borderRadius: AppRadius.r10,
                            border: Border.all(color: context.colors.border),
                          ),
                          child: staffAsync.when(
                            data: (staffList) {
                              if (staffList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Text('No staff available in $selectedDept', 
                                    style: AppTextStyles.caption(color: context.colors.error)
                                  ),
                                );
                              }
                              return DropdownButtonHideUnderline(
                                child: DropdownButton<String?>(
                                  value: selectedStaffUID,
                                  isExpanded: true,
                                  hint: Text('Assign to specific staff...', style: AppTextStyles.caption(color: context.colors.textMuted)),
                                  style: AppTextStyles.bodyMedium(color: context.colors.textPrimary).copyWith(fontSize: 13),
                                  dropdownColor: context.colors.surface,
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: const Text('General Department Queue'),
                                    ),
                                    ...staffList.map((staff) {
                                      return DropdownMenuItem<String?>(
                                        value: staff['firebaseUID'] as String?,
                                        child: Text('${staff['name']} - ${staff['designation'] ?? 'Staff'}', overflow: TextOverflow.ellipsis),
                                        onTap: () {
                                          selectedStaffName = staff['name'] as String?;
                                        },
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setDialogState(() {
                                      selectedStaffUID = val;
                                      if (val == null) {
                                        selectedStaffName = null;
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Loading staff members...'),
                            ),
                            error: (err, stack) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text('Failed to load staff', style: AppTextStyles.caption(color: context.colors.error)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Assignment Remarks (Optional):',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarksController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter reason or notes for department staff...',
                        hintStyle: AppTextStyles.caption(color: context.colors.textMuted),
                        filled: true,
                        fillColor: context.colors.surfaceSecondary,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.r10,
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    side: BorderSide(color: context.colors.border),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryAction,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final adminRepo = ref.read(adminRepositoryProvider);
                      await adminRepo.assignDepartment(
                        complaint.complaintId,
                        selectedDept,
                        assignedStaffUID: selectedStaffUID,
                        assignedStaffName: selectedStaffName,
                        remarks: remarksController.text,
                      );
                      ref.invalidate(adminComplaintsProvider);
                      ref.invalidate(adminDashboardStatsProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(selectedStaffName != null 
                              ? 'Complaint assigned to $selectedStaffName in $selectedDept!'
                              : 'Complaint assigned to $selectedDept successfully!'),
                            backgroundColor: context.colors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to assign department: $e'),
                            backgroundColor: context.colors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Assignment'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
