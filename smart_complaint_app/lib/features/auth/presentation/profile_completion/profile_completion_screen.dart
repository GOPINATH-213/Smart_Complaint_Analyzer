import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  final String? role;

  const ProfileCompletionScreen({super.key, this.role});

  @override
  ConsumerState<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Student controllers
  final _registerNumController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedYear;

  // Staff controllers
  final _employeeIdController = TextEditingController();
  final _designationController = TextEditingController();

  String _userRole = 'Student';
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  String? _errorMessage;

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
    'Hostel'
  ];
  final List<String> _years = ['I Year', 'II Year', 'III Year', 'IV Year'];

  @override
  void initState() {
    super.initState();
    if (widget.role != null && widget.role!.isNotEmpty) {
      _userRole = widget.role!;
    }
    _fetchInitialProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _registerNumController.dispose();
    _employeeIdController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialProfile() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);
      final user = authRepo.currentUser;

      if (user != null) {
        if (_nameController.text.isEmpty && user.displayName != null) {
          _nameController.text = user.displayName!;
        }

        try {
          final res = await api.get('/users/profile/${user.uid}');
          if (res.statusCode == 200) {
            final data = res.data['data'] as Map<String, dynamic>;
            setState(() {
              if (data['role'] != null && data['role'].toString().isNotEmpty) {
                _userRole = data['role'];
              }
              if (data['name'] != null && data['name'].toString().isNotEmpty && data['name'] != 'New User') {
                _nameController.text = data['name'];
              }
              _phoneController.text = data['phone'] ?? '';

              if (_userRole == 'Student') {
                _registerNumController.text = data['registerNumber'] ?? '';
                if (_registerNumController.text.isEmpty && user.email != null && user.email!.endsWith('@klnce.edu')) {
                  final prefix = user.email!.split('@')[0];
                  if (RegExp(r'^\d+$').hasMatch(prefix)) {
                    _registerNumController.text = prefix;
                  }
                }
                if (_departments.contains(data['department'])) {
                  _selectedDepartment = data['department'];
                }
                if (_years.contains(data['year'])) {
                  _selectedYear = data['year'];
                }
              } else {
                _employeeIdController.text = data['employeeId'] ?? '';
                _designationController.text = data['designation'] ?? '';
                if (_departments.contains(data['department'])) {
                  _selectedDepartment = data['department'];
                }
              }
            });
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            debugPrint('No existing profile found on backend for ${user.uid}. Showing profile setup.');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching initial profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);
      final user = authRepo.currentUser;

      if (user != null) {
        // 1. Sync user record in MongoDB
        await api.post('/users/sync', {
          'firebaseUID': user.uid,
          'email': user.email,
          'role': _userRole,
          'name': _nameController.text.trim(),
          'emailVerified': user.emailVerified,
          'department': _selectedDepartment,
          if (_userRole == 'Student') 'registerNumber': _registerNumController.text.trim(),
          if (_userRole == 'Department Staff') 'employeeId': _employeeIdController.text.trim(),
        });

        final Map<String, dynamic> updateData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'department': _selectedDepartment,
          'role': _userRole,
        };

        if (_userRole == 'Student') {
          updateData['registerNumber'] = _registerNumController.text.trim();
          updateData['year'] = _selectedYear ?? 'I Year';
        } else {
          updateData['employeeId'] = _employeeIdController.text.trim();
          if (_designationController.text.trim().isNotEmpty) {
            updateData['designation'] = _designationController.text.trim();
          }
        }

        // 2. Complete profile via backend endpoint
        final res = await api.put('/users/profile/${user.uid}', updateData);
        if (res.statusCode == 200) {
          ref.invalidate(userProfileProvider);
          if (mounted) {
            if (_userRole == 'Department Staff') {
              context.go('/staff-dashboard');
            } else {
              context.go('/home');
            }
          }
        } else {
          final errorData = res.data as Map<String, dynamic>;
          setState(() {
            _errorMessage = errorData['message'] ?? 'Failed to update profile.';
          });
        }
      }
    } catch (e) {
      debugPrint('Save profile exception: $e');
      if (mounted) {
        String msg = 'Something went wrong while setting up your profile.';
        if (e is DioException && e.response?.data != null) {
          try {
            final data = e.response!.data;
            if (data is Map<String, dynamic> && data['message'] != null) {
              msg = data['message'];
            }
          } catch (_) {}
        }
        setState(() {
          _errorMessage = msg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    final isStudent = _userRole == 'Student';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step Indicator (Step 3: Profile)
                Row(
                  children: [
                    _buildStepIndicator(step: '✓', label: 'Role', isComplete: true),
                    _buildStepDivider(),
                    _buildStepIndicator(step: '✓', label: 'Account', isComplete: true),
                    _buildStepDivider(),
                    _buildStepIndicator(step: '3', label: 'Profile', isActive: true),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  'Institutional Profile',
                  style: AppTextStyles.pageTitle().copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete your profile details to route and verify submitted complaints correctly.',
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

                // Full Name Input
                AppTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full legal name',
                  controller: _nameController,
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: context.colors.textSecondary),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
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
                      'Department',
                      style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDepartment,
                      decoration: InputDecoration(
                        hintText: 'Select your department',
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
                      ),
                      dropdownColor: context.colors.surface,
                      items: _departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(dept, style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDepartment = val;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your department';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Role Specific Fields
                if (isStudent) ...[
                  AppTextField(
                    label: 'Register / Roll Number',
                    hintText: 'e.g. 910623104026',
                    controller: _registerNumController,
                    prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20, color: context.colors.textSecondary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Register number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Year',
                        style: AppTextStyles.caption(color: context.colors.textPrimary).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedYear,
                        decoration: InputDecoration(
                          hintText: 'Select academic year',
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
                        ),
                        dropdownColor: context.colors.surface,
                        items: _years.map((y) {
                          return DropdownMenuItem(
                            value: y,
                            child: Text(y, style: AppTextStyles.bodyMedium(color: context.colors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedYear = val;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your academic year';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  AppTextField(
                    label: 'Employee ID',
                    hintText: 'e.g. EMP-1042',
                    controller: _employeeIdController,
                    prefixIcon: Icon(Icons.badge_outlined, size: 20, color: context.colors.textSecondary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Employee ID is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Designation / Title',
                    hintText: 'e.g. Assistant Professor / Warden',
                    controller: _designationController,
                    prefixIcon: Icon(Icons.work_outline_rounded, size: 20, color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                ],

                // Contact Phone
                AppTextField(
                  label: 'Phone Number',
                  hintText: '10-digit mobile number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_outlined, size: 20, color: context.colors.textSecondary),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final cleaned = value.replaceAll(RegExp(r'\D'), '');
                      if (cleaned.length < 10) {
                        return 'Enter a valid 10-digit phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Save Profile Button
                AppButton(
                  text: 'Complete Setup & Enter Portal',
                  onPressed: _saveProfile,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required String step,
    required String label,
    bool isActive = false,
    bool isComplete = false,
  }) {
    Color bg = context.colors.surfaceSecondary;
    Color fg = context.colors.textSecondary;
    Color border = context.colors.border;

    if (isComplete) {
      bg = context.colors.successLight;
      fg = context.colors.success;
      border = context.colors.success.withValues(alpha: 0.5);
    } else if (isActive) {
      bg = context.colors.primaryAction;
      fg = Colors.white;
      border = context.colors.primaryAction;
    }

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption(
            color: isActive ? context.colors.primaryNavy : context.colors.textMuted,
          ).copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 1,
        color: context.colors.border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
