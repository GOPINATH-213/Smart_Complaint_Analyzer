import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_permanent_footer.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'package:smart_complaint_app/features/auth/providers/auth_provider.dart';
import 'package:smart_complaint_app/features/complaints/presentation/providers/complaint_provider.dart';
import 'package:smart_complaint_app/features/user/my_complaints/presentation/my_complaints_screen.dart';
import 'package:smart_complaint_app/features/user/submit_complaint/presentation/submit_complaint_screen.dart';
import 'package:smart_complaint_app/features/complaints/presentation/widgets/complaint_card.dart';
import 'package:smart_complaint_app/features/profile/presentation/profile/profile_screen.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const UserDashboardScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _checkStatusAndLoadProfile();
  }

  Future<void> _checkStatusAndLoadProfile() async {
    final router = GoRouter.of(context);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);
      final user = authRepo.currentUser;

      if (user == null) {
        router.go('/login');
        return;
      }

      if (!user.emailVerified) {
        final verified = await authRepo.isEmailVerified();
        if (!verified) {
          router.go('/verify-email');
          return;
        }
      }

      final res = await api.get('/users/profile/${user.uid}');

      if (res.statusCode == 200) {
        final data = res.data['data'] as Map<String, dynamic>;
        final role = data['role'] ?? 'Student';
        final isCompleted = data['isProfileCompleted'] == true;

        final hasName =
            data['name'] != null && data['name'].toString().trim().isNotEmpty && data['name'] != 'New User';
        final hasDept = data['department'] != null && data['department'] != 'Not Assigned';

        bool isRoleProfileComplete = false;
        if (role == 'Student') {
          final hasRegNum =
              data['registerNumber'] != null && data['registerNumber'].toString().trim().isNotEmpty;
          final hasYear = data['year'] != null && data['year'].toString().trim().isNotEmpty;
          isRoleProfileComplete = isCompleted || (hasName && hasDept && hasRegNum && hasYear);
        } else {
          final hasEmpId =
              data['employeeId'] != null && data['employeeId'].toString().trim().isNotEmpty;
          isRoleProfileComplete = isCompleted || (hasName && hasDept && hasEmpId);
        }

        if (!isRoleProfileComplete) {
          router.go('/profile-completion?role=$role');
          return;
        }

        if (role == 'Department Staff') {
          router.go('/staff-dashboard');
          return;
        }

        if (mounted) {
          setState(() {
            _userProfile = data;
          });
        }
      } else if (res.statusCode == 404) {
        router.go('/profile-completion');
        return;
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load profile. Backend status: ${res.statusCode}';
          });
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        router.go('/profile-completion');
        return;
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong while connecting to the server. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: const AppTopNavbar(title: 'Dashboard'),
        body: ErrorState(
          title: 'Connection Error',
          message: _errorMessage!,
          onRetry: () {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _checkStatusAndLoadProfile();
          },
        ),
      );
    }

    // 4 destinations matching AppPermanentFooter:
    // 0: Home Dashboard
    // 1: My Complaints
    // 2: Submit Complaint
    // 3: Profile
    final pages = [
      _buildStudentDashboardView(context),
      const MyComplaintsScreen(),
      const SubmitComplaintScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: IndexedStack(
        index: _currentIndex.clamp(0, pages.length - 1),
        children: pages,
      ),
      bottomNavigationBar: AppPermanentFooter(
        currentRoute: '/home',
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStudentDashboardView(BuildContext context) {
    final myComplaintsAsync = ref.watch(myComplaintsProvider);
    final userName = _userProfile?['name'] ?? 'Student';
    final dept = _userProfile?['department'] ?? 'Department';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppTopNavbar(
        title: 'Student Dashboard',
        subtitle: dept,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(myComplaintsProvider.notifier).fetchMyComplaints();
          await _checkStatusAndLoadProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, $userName',
                      style: AppTextStyles.pageTitle().copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Here's your complaint overview.",
                      style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Metric Cards
              myComplaintsAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: const [
                      Expanded(child: MetricCardSkeleton()),
                      SizedBox(width: 8),
                      Expanded(child: MetricCardSkeleton()),
                      SizedBox(width: 8),
                      Expanded(child: MetricCardSkeleton()),
                      SizedBox(width: 8),
                      Expanded(child: MetricCardSkeleton()),
                    ],
                  ),
                ),
                error: (err, stack) => const SizedBox.shrink(),
                data: (complaints) {
                  final total = complaints.length;
                  final submitted = complaints.where((c) => c.status == 'Submitted').length;
                  final inProgress = complaints.where((c) => c.status == 'In Progress').length;
                  final resolved = complaints.where((c) => c.status == 'Resolved').length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                label: 'Total',
                                count: total,
                                accentColor: context.colors.primaryNavy,
                                icon: Icons.folder_outlined,
                                onTap: () => setState(() => _currentIndex = 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricCard(
                                label: 'Submitted',
                                count: submitted,
                                accentColor: context.colors.primaryAction,
                                icon: Icons.send_rounded,
                                onTap: () => setState(() => _currentIndex = 1),
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
                                count: inProgress,
                                accentColor: context.colors.warning,
                                icon: Icons.pending_actions_rounded,
                                onTap: () => setState(() => _currentIndex = 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricCard(
                                label: 'Resolved',
                                count: resolved,
                                accentColor: context.colors.success,
                                icon: Icons.check_circle_rounded,
                                onTap: () => setState(() => _currentIndex = 1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action CTA: "+ Submit Complaint"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AppButton(
                  text: 'Submit New Complaint',
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(height: 28),

              // Recent Complaints Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Complaints',
                      style: AppTextStyles.sectionHeading().copyWith(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _currentIndex = 1),
                      child: Text(
                        'View All',
                        style: AppTextStyles.caption(color: context.colors.primaryAction).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Recent Complaints List
              myComplaintsAsync.when(
                loading: () => const ComplaintListSkeleton(count: 3),
                error: (err, _) => ErrorState(
                  title: 'Unable to Load Complaints',
                  message: 'Could not fetch your recent complaints.',
                  onRetry: () => ref.read(myComplaintsProvider.notifier).fetchMyComplaints(),
                ),
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No Complaints Yet',
                      description: "You haven't submitted any complaints.",
                      actionText: 'Submit Complaint',
                      onAction: () => setState(() => _currentIndex = 2),
                    );
                  }

                  final recent = complaints.take(4).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      final c = recent[index];
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
            ],
          ),
        ),
      ),
    );
  }
}
