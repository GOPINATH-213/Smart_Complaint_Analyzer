import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_navbar.dart';
import 'package:smart_complaint_app/features/auth/providers/auth_provider.dart';
import 'package:smart_complaint_app/features/complaints/data/models/complaint_model.dart';
import 'package:smart_complaint_app/features/complaints/presentation/providers/complaint_provider.dart';

class SubmitComplaintScreen extends ConsumerStatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  ConsumerState<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends ConsumerState<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedDepartment;
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;
  String? _errorMessage;

  // Holds newly created complaint for the professional success receipt state
  ComplaintModel? _submittedComplaint;

  final List<String> _departments = [
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

  final List<String> _priorities = ['Low', 'Medium', 'High'];

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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = authRepo.currentUser;

      if (user == null) {
        context.go('/login');
        return;
      }

      final complaintRepo = ref.read(complaintRepositoryProvider);
      final createdComplaint = await complaintRepo.submitComplaint(
        firebaseUID: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        department: _selectedDepartment!,
        priority: _selectedPriority,
      );

      // Refresh student's complaint list in Riverpod
      ref.read(myComplaintsProvider.notifier).fetchMyComplaints();

      if (!mounted) return;

      setState(() {
        _submittedComplaint = createdComplaint;
        _isSubmitting = false;
      });
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to submit complaint. Please try again.';
        if (e is DioException) {
          if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            if (data['message'] != null) {
              msg = data['message'].toString();
            }
          }
        }
        setState(() {
          _errorMessage = msg;
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDepartment = null;
      _selectedPriority = 'Medium';
      _submittedComplaint = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedComplaint != null) {
      return _buildSuccessReceiptView();
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Submit Complaint',
        subtitle: 'Official Institutional Grievance Intake',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Prompt
                Text(
                  'Submit Complaint',
                  style: AppTextStyles.pageTitle().copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tell us what happened. We'll help route your complaint to the relevant department.",
                  style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Error Message Notice
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.errorLight,
                      borderRadius: AppRadius.r8,
                      border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 18, color: context.colors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.caption(color: context.colors.error).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Complaint Title
                AppTextField(
                  label: 'Complaint Title',
                  hintText: 'e.g. Water supply outage in Block C',
                  controller: _titleController,
                  maxLength: 80,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a clear title for your complaint';
                    }
                    if (value.trim().length < 5) {
                      return 'Title must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Department',
                      style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDepartment,
                      decoration: InputDecoration(
                        hintText: 'Select relevant department',
                        hintStyle: AppTextStyles.bodyMedium(color: context.colors.textMuted),
                        filled: true,
                        fillColor: context.colors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                          borderSide: BorderSide(color: context.colors.borderFocused, width: 1.5),
                        ),
                      ),
                      dropdownColor: context.colors.surface,
                      items: _departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(
                            dept,
                            style: AppTextStyles.bodyMedium(color: context.colors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDepartment = val;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a target department';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Priority Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Initial Priority',
                      style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: _priorities.map((p) {
                        final isSelected = _selectedPriority == p;
                        final color = context.colors.getPriorityColor(p);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPriority = p;
                                });
                              },
                              borderRadius: AppRadius.r10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: isSelected ? color.withValues(alpha: 0.1) : context.colors.surface,
                                  borderRadius: AppRadius.r10,
                                  border: Border.all(
                                    color: isSelected ? color : context.colors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  p,
                                  style: AppTextStyles.badge(
                                    color: isSelected ? color : context.colors.textSecondary,
                                  ).copyWith(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description Field
                AppTextField(
                  label: 'Detailed Description',
                  hintText: 'Describe your complaint clearly with relevant details (location, context, timing)...',
                  controller: _descriptionController,
                  maxLines: 6,
                  minLines: 4,
                  maxLength: 600,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a detailed description of the issue';
                    }
                    if (value.trim().length < 15) {
                      return 'Description must be at least 15 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  text: 'Submit Complaint',
                  icon: Icons.send_rounded,
                  onPressed: _handleSubmit,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessReceiptView() {
    final complaint = _submittedComplaint!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const AppTopNavbar(
        title: 'Submission Receipt',
        showActions: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: AppRadius.r16,
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.colors.successLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.success.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: context.colors.success,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Complaint Submitted',
                    style: AppTextStyles.pageTitle().copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your complaint has been successfully registered and queued for Gemini AI classification.',
                    style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Receipt ID Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceSecondary,
                      borderRadius: AppRadius.r10,
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'COMPLAINT REFERENCE ID',
                          style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.complaintId,
                          style: AppTextStyles.codeOrId().copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Actions
                  AppButton(
                    text: 'View Complaint',
                    icon: Icons.visibility_outlined,
                    onPressed: () {
                      context.push('/complaint-detail/${complaint.complaintId}');
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primaryNavy,
                      side: BorderSide(color: context.colors.border),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.r12),
                    ),
                    child: Text(
                      'Submit Another Complaint',
                      style: AppTextStyles.button(color: context.colors.primaryNavy).copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
