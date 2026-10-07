import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../widgets/ai_analysis_widget.dart';
import '../widgets/status_timeline_widget.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({
    super.key,
    required this.complaintId,
  });

  @override
  ConsumerState<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  ComplaintModel? _complaint;
  bool _isUpdating = false;
  bool _isReanalyzingAi = false;
  String _userRole = 'Student';

  @override
  void initState() {
    super.initState();
    _loadComplaintDetails();
  }

  Future<void> _loadComplaintDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(complaintRepositoryProvider);
      final api = ref.read(apiServiceProvider);
      final user = ref.read(authRepositoryProvider).currentUser;
      final uid = user?.uid ?? '';

      // 1. Fetch user role
      try {
        final profileRes = await api.get('/users/profile/$uid');
        if (profileRes.statusCode == 200) {
          final role = profileRes.data['data']['role'] ?? 'Student';
          _userRole = role;
        }
      } catch (_) {}

      // 2. Fetch complaint details
      final complaint = await repo.getComplaintById(widget.complaintId, uid);
      if (mounted) {
        setState(() {
          _complaint = complaint;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleReanalyzeAi() async {
    if (_complaint == null || _isReanalyzingAi) return;

    setState(() {
      _isReanalyzingAi = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(complaintRepositoryProvider);
      final user = ref.read(authRepositoryProvider).currentUser;
      final uid = user?.uid ?? '';

      final updated = await repo.analyzeComplaint(_complaint!.complaintId, uid);
      if (mounted) {
        setState(() {
          _complaint = updated;
          _isReanalyzingAi = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gemini AI analysis refreshed successfully'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReanalyzingAi = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('AI analysis failed: ${e.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showUpdateStatusDialog() async {
    if (_complaint == null || _userRole != 'Department Staff') return;

    final currentStatus = _complaint!.status;
    final availableStatuses = <String>[];
    if (currentStatus == 'Submitted') {
      availableStatuses.addAll(['In Progress', 'Resolved', 'Closed']);
    } else if (currentStatus == 'In Progress') {
      availableStatuses.addAll(['Resolved', 'Closed']);
    } else if (currentStatus == 'Resolved') {
      availableStatuses.add('Closed');
    }

    if (availableStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint is already closed and cannot be modified.')),
      );
      return;
    }

    String selectedStatus = availableStatuses.first;
    final remarksController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Update Complaint Status',
                      style: AppTextStyles.pageTitle().copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select the new status and document your action remarks.',
                      style: AppTextStyles.bodySmall(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Current Status Pill
                    Row(
                      children: [
                        Text('Current Status:', style: AppTextStyles.caption(color: context.colors.textSecondary)),
                        const SizedBox(width: 8),
                        StatusBadge(status: currentStatus, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    Text(
                      'New Status',
                      style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.colors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.r10,
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.r10,
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                      ),
                      dropdownColor: context.colors.surface,
                      items: availableStatuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              StatusBadge(status: status, isCompact: true),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedStatus = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Remarks Field
                    Text(
                      'Status / Resolution Remarks',
                      style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: remarksController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: selectedStatus == 'Resolved' || selectedStatus == 'Closed'
                            ? 'Explain how this grievance was resolved...'
                            : 'Enter operational remarks or next steps...',
                        filled: true,
                        fillColor: context.colors.surface,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.r10,
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.r10,
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                      ),
                      validator: (value) {
                        if ((selectedStatus == 'Resolved' || selectedStatus == 'Closed') &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Resolution remarks are required when closing or resolving';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Confirm Status Update',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      setState(() {
        _isUpdating = true;
      });

      try {
        final repo = ref.read(complaintRepositoryProvider);
        final user = ref.read(authRepositoryProvider).currentUser;
        final uid = user?.uid ?? '';

        final updatedComplaint = await repo.updateComplaintStatus(
          complaintId: _complaint!.complaintId,
          firebaseUID: uid,
          status: selectedStatus,
          remarks: remarksController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _complaint = updatedComplaint;
            _isUpdating = false;
          });
          messenger.showSnackBar(
            SnackBar(
              content: Text('Status updated to $selectedStatus successfully'),
              backgroundColor: context.colors.success,
            ),
          );
        }

        // Refresh department complaints list
        ref.read(departmentComplaintsProvider.notifier).fetchDepartmentComplaints();
      } catch (e) {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to update status: ${e.toString()}'),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = _userRole == 'Department Staff';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppTopNavbar(title: 'Complaint Details'),
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    if (_errorMessage != null || _complaint == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: const AppTopNavbar(title: 'Complaint Details'),
        body: ErrorState(
          title: 'Unable to Load Complaint',
          message: _errorMessage ?? 'Complaint record not found.',
          onRetry: _loadComplaintDetails,
        ),
      );
    }

    final c = _complaint!;
    final canStaffUpdate = isStaff && c.status != 'Closed';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppTopNavbar(
        title: c.complaintId,
        subtitle: '${c.department} Department',
      ),
      bottomNavigationBar: canStaffUpdate
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.border)),
                boxShadow: AppShadows.bottomBar,
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  text: 'Update Complaint Status',
                  icon: Icons.edit_note_rounded,
                  onPressed: () => _showUpdateStatusDialog(),
                  isLoading: _isUpdating,
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadComplaintDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Complaint Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: AppRadius.r14,
                  border: Border.all(color: context.colors.border),
                  boxShadow: AppShadows.cardSubtle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceSecondary,
                            borderRadius: AppRadius.r6,
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Text(
                            c.complaintId,
                            style: AppTextStyles.codeOrId(),
                          ),
                        ),
                        StatusBadge(status: c.status),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      c.title,
                      style: AppTextStyles.pageTitle().copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 14),

                    // Quick Attributes Row
                    Row(
                      children: [
                        _buildDetailChip(label: 'Dept', value: c.department, icon: Icons.business_outlined),
                        const SizedBox(width: 8),
                        PriorityBadge(priority: c.priority),
                        const Spacer(),
                        Text(
                          _formatDate(c.createdAt),
                          style: AppTextStyles.caption(color: context.colors.textMuted),
                        ),
                      ],
                    ),

                    if (isStaff && c.studentName.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Divider(color: context.colors.border),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.school_outlined, size: 14, color: context.colors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'Student: ${c.studentName}',
                            style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (c.studentRegisterNumber.isNotEmpty) ...[
                            Text(
                              ' (${c.studentRegisterNumber})',
                              style: AppTextStyles.caption(color: context.colors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Complaint Description Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: AppRadius.r14,
                  border: Border.all(color: context.colors.border),
                  boxShadow: AppShadows.cardSubtle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESCRIPTION',
                      style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.description,
                      style: AppTextStyles.bodyLarge().copyWith(
                        height: 1.5,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Signature Gemini AI Analysis Section
              AiAnalysisWidget(
                complaint: c,
                isStaff: isStaff,
                onReanalyze: _handleReanalyzeAi,
                isReanalyzing: _isReanalyzingAi,
              ),
              const SizedBox(height: 16),

              // 4. Status Progression Timeline Card
              StatusTimelineWidget(
                statusHistory: c.statusHistory,
                currentStatus: c.status,
              ),

              // Bottom padding if action button is present
              if (canStaffUpdate) const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: AppRadius.r6,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
