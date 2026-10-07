import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? role;

  const RegisterScreen({super.key, this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late String _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedRole = (widget.role == 'Department Staff') ? 'Department Staff' : 'Student';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    User? createdUser;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);

      // 1. Create Firebase Auth user
      final credential = await authRepo.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      createdUser = credential.user;
      if (createdUser != null) {
        // 2. Sync user & role to MongoDB
        final Map<String, dynamic> syncPayload = {
          'firebaseUID': createdUser.uid,
          'email': createdUser.email,
          'role': _selectedRole,
          'name': 'New $_selectedRole',
          'emailVerified': false,
        };

        try {
          await api.post('/users/sync', syncPayload);
        } catch (syncError) {
          // Rollback Firebase account if database sync fails
          try {
            await createdUser.delete();
          } catch (delErr) {
            debugPrint('Error cleaning up Firebase user on sync failure: $delErr');
          }
          rethrow;
        }

        // 3. Send email verification
        await authRepo.sendEmailVerification();

        // 4. Sign out to force manual login as per requirements
        await authRepo.signOut();

        if (!mounted) return;
        // 5. Navigate to login screen directly
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Please login to continue.'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Registration failed. Please try again.';
        if (e is DioException) {
          if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            if (data['message'] != null) {
              msg = data['message'].toString();
            }
          } else if (e.response?.statusCode == 409) {
            msg = 'An account with this email already exists in the database.';
          }
        } else if (e is FirebaseAuthException) {
          msg = e.message ?? msg;
        } else {
          msg = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        }

        setState(() {
          _errorMessage = msg;
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

  @override
  Widget build(BuildContext context) {
    final isStudent = _selectedRole == 'Student';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Account Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step Indicator
                Row(
                  children: [
                    _buildStepIndicator(step: '✓', label: 'Role', isComplete: true, isActive: false),
                    _buildStepDivider(),
                    _buildStepIndicator(step: '2', label: 'Account', isComplete: false, isActive: true),
                    _buildStepDivider(),
                    _buildStepIndicator(step: '3', label: 'Profile', isComplete: false, isActive: false),
                  ],
                ),
                const SizedBox(height: 28),

                // Selected Role Chip Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: AppRadius.r10,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isStudent ? Icons.school_outlined : Icons.badge_outlined,
                        size: 18,
                        color: context.colors.primaryNavy,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registering as $_selectedRole',
                          style: AppTextStyles.cardTitle(color: context.colors.primaryNavy).copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Change',
                          style: AppTextStyles.caption(color: context.colors.primaryAction).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Create Your Credentials',
                  style: AppTextStyles.pageTitle().copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  isStudent
                      ? 'Use your @gmail.com email address to automatically verify your student roll number.'
                      : 'Use your institutional staff email address to register for department access.',
                  style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Error Notice Banner
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

                // Email Field
                AppTextField(
                  label: isStudent ? 'Email Address' : 'Staff Institutional Email',
                  hintText: isStudent ? 'name@gmail.com' : 'name@klnce.edu',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined, size: 20, color: context.colors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.trim())) {
                      return 'Enter a valid email address';
                    }
                    if (isStudent) {
                      final email = val.trim().toLowerCase();
                      if (!email.endsWith('@gmail.com') && !email.endsWith('@klnce.edu')) {
                        return 'Student registration requires an @gmail.com or @klnce.edu email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                AppTextField(
                  label: 'Password',
                  hintText: 'Minimum 6 characters',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: context.colors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: context.colors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: context.colors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: context.colors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Create Account Button
                AppButton(
                  text: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // Return to Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.button(color: context.colors.primaryAction).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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
    required bool isActive,
    required bool isComplete,
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
