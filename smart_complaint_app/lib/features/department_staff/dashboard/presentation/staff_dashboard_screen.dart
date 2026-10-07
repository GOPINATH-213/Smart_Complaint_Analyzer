import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'package:smart_complaint_app/features/complaints/data/models/complaint_model.dart';
import 'package:smart_complaint_app/features/complaints/presentation/providers/complaint_provider.dart';
import 'package:smart_complaint_app/features/complaints/presentation/widgets/complaint_card.dart';
import '../../../auth/providers/auth_provider.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<String> _statusFilters = [
    'All',
    'Submitted',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  final List<String> _priorityFilters = [
    'All',
    'High',
    'Medium',
    'Low',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(userProfileProvider);
      final role = profileAsync.asData?.value?['role'];
      if (role == 'Student') {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deptDataAsync = ref.watch(departmentComplaintsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Department Operations',
        subtitle: 'Institutional Staff Queue',
      ),
      body: deptDataAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: MetricCardSkeleton()),
                  SizedBox(width: 8),
                  Expanded(child: MetricCardSkeleton()),
                ],
              ),
              SizedBox(height: 16),
              ComplaintListSkeleton(count: 4),
            ],
          ),
        ),
        error: (err, _) => ErrorState(
          title: 'Unable to Load Department Queue',
          message: 'Could not connect to the operations service.',
          onRetry: () {
            ref.read(departmentComplaintsProvider.notifier).fetchDepartmentComplaints();
          },
        ),
        data: (deptMap) {
          final department = deptMap['department'] as String? ?? 'Assigned Department';
          final stats = deptMap['stats'] as DepartmentStats? ??
              DepartmentStats(total: 0, submitted: 0, inProgress: 0, resolved: 0, closed: 0);
          final complaints = deptMap['complaints'] as List<ComplaintModel>? ?? [];

          // Attention Required: High priority or critical complaints that are active
          final attentionRequired = complaints.where((c) {
            final isHighPriority = c.priority.toLowerCase() == 'high';
            final isCritical = c.urgency?.toLowerCase() == 'critical';
            final isActive = c.status == 'Submitted' || c.status == 'In Progress';
            return (isHighPriority || isCritical) && isActive;
          }).toList();

          // Filtering
          var filteredComplaints = complaints;
          if (_selectedStatus != 'All') {
            filteredComplaints = filteredComplaints
                .where((c) => c.status.toLowerCase() == _selectedStatus.toLowerCase())
                .toList();
          }
          if (_selectedPriority != 'All') {
            filteredComplaints = filteredComplaints
                .where((c) => c.priority.toLowerCase() == _selectedPriority.toLowerCase())
                .toList();
          }
          if (_searchQuery.isNotEmpty) {
            filteredComplaints = filteredComplaints.where((c) {
              final titleMatch = c.title.toLowerCase().contains(_searchQuery);
              final idMatch = c.complaintId.toLowerCase().contains(_searchQuery);
              final studentMatch = c.studentName.toLowerCase().contains(_searchQuery);
              return titleMatch || idMatch || studentMatch;
            }).toList();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(departmentComplaintsProvider.notifier).fetchDepartmentComplaints();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Department Overview Header Banner
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: context.colors.primaryNavy,
                      borderRadius: AppRadius.r14,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primaryNavy.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: AppRadius.r10,
                          ),
                          child: const Icon(Icons.corporate_fare_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEPARTMENT OVERVIEW',
                                style: AppTextStyles.caption(color: Colors.white70).copyWith(
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                department,
                                style: AppTextStyles.pageTitle(color: Colors.white).copyWith(fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: context.colors.primaryNavy,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
                          ),
                          icon: const Icon(Icons.people_alt_outlined, size: 16),
                          label: const Text('My Students', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => context.push('/staff/students'),
                        ),
                      ],
                    ),
                  ),

                  // 2. Summary Metric Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                label: 'Total',
                                count: stats.total,
                                accentColor: context.colors.primaryNavy,
                                icon: Icons.folder_outlined,
                                isSelected: _selectedStatus == 'All',
                                onTap: () => setState(() => _selectedStatus = 'All'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricCard(
                                label: 'Submitted',
                                count: stats.submitted,
                                accentColor: context.colors.primaryAction,
                                icon: Icons.send_rounded,
                                isSelected: _selectedStatus == 'Submitted',
                                onTap: () => setState(() => _selectedStatus = 'Submitted'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                label: 'In Progress',
                                count: stats.inProgress,
                                accentColor: context.colors.warning,
                                icon: Icons.pending_actions_rounded,
                                isSelected: _selectedStatus == 'In Progress',
                                onTap: () => setState(() => _selectedStatus = 'In Progress'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricCard(
                                label: 'Resolved',
                                count: stats.resolved,
                                accentColor: context.colors.success,
                                icon: Icons.check_circle_rounded,
                                isSelected: _selectedStatus == 'Resolved',
                                onTap: () => setState(() => _selectedStatus = 'Resolved'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricCard(
                                label: 'Closed',
                                count: stats.closed,
                                accentColor: context.colors.textSecondary,
                                icon: Icons.lock_outline_rounded,
                                isSelected: _selectedStatus == 'Closed',
                                onTap: () => setState(() => _selectedStatus = 'Closed'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Attention Required Section (if any urgent complaints exist)
                  if (attentionRequired.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: context.colors.errorLight,
                          borderRadius: AppRadius.r12,
                          border: Border.all(color: context.colors.error.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: context.colors.error, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ATTENTION REQUIRED',
                                    style: AppTextStyles.caption(color: context.colors.error).copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${attentionRequired.length} high priority or critical grievance(s) require prompt triage.',
                                    style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 4. Search & Filter Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: AppRadius.r12,
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceSecondary,
                            borderRadius: AppRadius.r8,
                            border: Border.all(color: context.colors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: AppTextStyles.bodyMedium(color: context.colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search complaints or student...',
                              hintStyle: AppTextStyles.bodyMedium(color: context.colors.textMuted),
                              prefixIcon: Icon(Icons.search_rounded, size: 18, color: context.colors.textSecondary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Status Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _statusFilters.map((st) {
                              final isSel = _selectedStatus == st;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: ChoiceChip(
                                  label: Text(st),
                                  selected: isSel,
                                  onSelected: (_) => setState(() => _selectedStatus = st),
                                  selectedColor: context.colors.primaryNavy,
                                  backgroundColor: context.colors.surface,
                                  labelStyle: AppTextStyles.caption(
                                    color: isSel ? Colors.white : context.colors.textSecondary,
                                  ).copyWith(fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                                  side: BorderSide(
                                    color: isSel ? context.colors.primaryNavy : context.colors.border,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Priority Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text(
                                'Priority:',
                                style: AppTextStyles.caption(color: context.colors.textMuted).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ..._priorityFilters.map((pr) {
                                final isSel = _selectedPriority == pr;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: ChoiceChip(
                                    label: Text(pr),
                                    selected: isSel,
                                    onSelected: (_) => setState(() => _selectedPriority = pr),
                                    selectedColor: context.colors.primaryAction,
                                    backgroundColor: context.colors.surface,
                                    labelStyle: AppTextStyles.caption(
                                      color: isSel ? Colors.white : context.colors.textSecondary,
                                    ).copyWith(fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                                    side: BorderSide(
                                      color: isSel ? context.colors.primaryAction : context.colors.border,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Department Queue Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Complaints Queue (${filteredComplaints.length})',
                          style: AppTextStyles.sectionHeading().copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 6. Complaints List
                  if (filteredComplaints.isEmpty)
                    EmptyState(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'No Assigned Complaints',
                      description: _searchQuery.isNotEmpty || _selectedStatus != 'All' || _selectedPriority != 'All'
                          ? 'No complaints match the selected filter criteria.'
                          : 'All grievances assigned to your department are currently resolved.',
                      actionText: _searchQuery.isNotEmpty || _selectedStatus != 'All' || _selectedPriority != 'All'
                          ? 'Reset Filters'
                          : null,
                      onAction: () {
                        _searchController.clear();
                        setState(() {
                          _selectedStatus = 'All';
                          _selectedPriority = 'All';
                          _searchQuery = '';
                        });
                      },
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredComplaints.length,
                      itemBuilder: (context, index) {
                        final c = filteredComplaints[index];
                        return ComplaintCard(
                          complaint: c,
                          onTap: () {
                            context.push('/complaint-detail/${c.complaintId}');
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
