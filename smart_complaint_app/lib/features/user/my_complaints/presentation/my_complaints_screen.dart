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
import '../../../../core/widgets/skeleton_loader.dart';
import 'package:smart_complaint_app/features/complaints/presentation/providers/complaint_provider.dart';
import 'package:smart_complaint_app/features/complaints/presentation/widgets/complaint_card.dart';
import 'package:smart_complaint_app/features/auth/providers/auth_provider.dart';

class MyComplaintsScreen extends ConsumerStatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  ConsumerState<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends ConsumerState<MyComplaintsScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  String _sortOrder = 'Newest'; // Newest or Oldest
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<String> _statusFilters = [
    'All',
    'Submitted',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(userProfileProvider);
      final role = profileAsync.asData?.value?['role'];
      if (role == 'Department Staff') {
        context.go('/staff-dashboard');
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
    final complaintsAsync = ref.watch(myComplaintsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'My Complaints',
        subtitle: 'Student History & Resolution Tracking',
      ),
      body: Column(
        children: [
          // Search & Filter Header Section
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: AppRadius.r10,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: AppTextStyles.bodyMedium(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by title or ID (e.g. SCA-2026)...',
                      hintStyle: AppTextStyles.bodyMedium(color: context.colors.textMuted),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: context.colors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Filter Chips & Sort
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _statusFilters.map((status) {
                            final isSelected = _selectedStatus == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedStatus = status;
                                  });
                                },
                                selectedColor: context.colors.primaryNavy,
                                backgroundColor: context.colors.surface,
                                labelStyle: AppTextStyles.caption(
                                  color: isSelected ? Colors.white : context.colors.textSecondary,
                                ).copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                                side: BorderSide(
                                  color: isSelected ? context.colors.primaryNavy : context.colors.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.r8,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort Toggle
                    InkWell(
                      onTap: () {
                        setState(() {
                          _sortOrder = _sortOrder == 'Newest' ? 'Oldest' : 'Newest';
                        });
                      },
                      borderRadius: AppRadius.r8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceSecondary,
                          borderRadius: AppRadius.r8,
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _sortOrder == 'Newest' ? Icons.south_rounded : Icons.north_rounded,
                              size: 13,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _sortOrder,
                              style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.border),

          // Complaints List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(myComplaintsProvider.notifier).fetchMyComplaints();
              },
              child: complaintsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: ComplaintListSkeleton(count: 4),
                ),
                error: (err, _) => ErrorState(
                  title: 'Unable to Load Complaints',
                  message: 'Failed to retrieve your complaints from the server.',
                  onRetry: () => ref.read(myComplaintsProvider.notifier).fetchMyComplaints(),
                ),
                data: (complaints) {
                  // Filter by status
                  var filtered = _selectedStatus == 'All'
                      ? complaints
                      : complaints
                          .where((c) => c.status.toLowerCase() == _selectedStatus.toLowerCase())
                          .toList();

                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((c) {
                      final titleMatch = c.title.toLowerCase().contains(_searchQuery);
                      final idMatch = c.complaintId.toLowerCase().contains(_searchQuery);
                      final deptMatch = c.department.toLowerCase().contains(_searchQuery);
                      return titleMatch || idMatch || deptMatch;
                    }).toList();
                  }

                  // Sort by createdAt
                  filtered.sort((a, b) {
                    if (_sortOrder == 'Newest') {
                      return b.createdAt.compareTo(a.createdAt);
                    } else {
                      return a.createdAt.compareTo(b.createdAt);
                    }
                  });

                  if (filtered.isEmpty) {
                    if (_searchQuery.isNotEmpty || _selectedStatus != 'All') {
                      return EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Complaints',
                        description: 'Try adjusting your search query or status filter.',
                        actionText: 'Clear Filters',
                        onAction: () {
                          _searchController.clear();
                          setState(() {
                            _selectedStatus = 'All';
                            _searchQuery = '';
                          });
                        },
                      );
                    }

                    return EmptyState(
                      icon: Icons.folder_open_rounded,
                      title: 'No Complaints Submitted',
                      description: 'You have not submitted any complaints yet.',
                      actionText: 'Submit Complaint',
                      onAction: () => context.go('/submit-complaint'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return ComplaintCard(
                        complaint: c,
                        onTap: () {
                          context.push('/complaint-detail/${c.complaintId}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
