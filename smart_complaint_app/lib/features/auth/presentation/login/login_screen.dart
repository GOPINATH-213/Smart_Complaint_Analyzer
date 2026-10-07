import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkWebRedirect();
      });
    }
  }

  Future<void> _checkWebRedirect() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final credential = await authRepo.checkRedirectResult();
      if (credential != null && credential.user != null) {
        final user = credential.user!;
        final api = ref.read(apiServiceProvider);
        final profileRes = await api.get('/users/profile/${user.uid}');
        if (!mounted) return;
        if (profileRes.statusCode == 200) {
          final data = profileRes.data['data'] as Map<String, dynamic>;
          final isCompleted = data['isProfileCompleted'] == true;
          if (isCompleted) {
            final role = data['role'] ?? 'Student';
            if (role == 'Admin') {
              context.go('/admin-dashboard');
            } else if (role == 'Department Staff') {
              context.go('/staff-dashboard');
            } else {
              context.go('/home');
            }
          } else {
            context.push('/user-type?from=google');
          }
        }
      }
    } catch (e) {
      debugPrint('Redirect result check error: ');
    }
  }
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);

      final credential = await authRepo.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) return;

      if (!mounted) return;

      // Read saved user role and profile status from MongoDB first
      try {
        final emailQuery = user.email != null && user.email!.isNotEmpty ? '?email=${Uri.encodeComponent(user.email!)}' : '';
        final profileRes = await api.get('/users/profile/${user.uid}$emailQuery');
        if (!mounted) return;
        if (profileRes.statusCode == 200) {
          final data = profileRes.data['data'] as Map<String, dynamic>;
          final rawRole = data['role']?.toString() ?? 'Student';
          final role = rawRole.toLowerCase() == 'admin' ? 'Admin' : rawRole;
          final isCompleted = role == 'Admin' || data['isProfileCompleted'] == true;

          // Admin users bypass student email verification requirement
          if (role != 'Admin' && !user.emailVerified && user.providerData.every((p) => p.providerId == 'password')) {
            context.go('/verify-email');
            return;
          }

          if (isCompleted) {
            if (role == 'Admin') {
              context.go('/admin-dashboard');
            } else if (role == 'Department Staff') {
              context.go('/staff-dashboard');
            } else {
              context.go('/home');
            }
          } else {
            context.go('/profile-completion?role=$role');
          }
          return;
        }
      } on DioException catch (e) {
        if (!mounted) return;
        if (!user.emailVerified && user.providerData.every((p) => p.providerId == 'password')) {
          context.go('/verify-email');
          return;
        }
        if (e.response?.statusCode == 404) {
          context.go('/profile-completion');
        } else {
          context.go('/home');
        }
        return;
      } catch (_) {
        if (!mounted) return;
        if (!user.emailVerified && user.providerData.every((p) => p.providerId == 'password')) {
          context.go('/verify-email');
          return;
        }
        context.go('/profile-completion');
        return;
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        if (e is FirebaseAuthException) {
          if (e.code == 'network-request-failed') {
            msg = 'Network connection failed while reaching authentication servers. Please check your internet connection and ensure your domain/localhost is authorized in Firebase Console.';
          } else if (e.code == 'popup-closed-by-user') {
            msg = 'Google Sign-In popup was closed before completing.';
          } else if (e.message != null && e.message!.isNotEmpty) {
            msg = e.message!;
          }
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);

      final credential = await authRepo.signInWithGoogle();
      final user = credential?.user;
      if (user == null) return;

      final isNewUser = credential!.additionalUserInfo?.isNewUser ?? false;

      // If it's a completely new Firebase user, sign them out and show success
      if (isNewUser) {
        if (!mounted) return;
        await authRepo.signOut();
        setState(() {
          _successMessage = 'Google Account linked successfully. Please click "Continue with Google" again to login.';
        });
        return;
      }

      // Check existing profile in MongoDB for returning users
      try {
        final profileRes = await api.get('/users/profile/${user.uid}');
        if (!mounted) return;
        if (profileRes.statusCode == 200) {
          final data = profileRes.data['data'] as Map<String, dynamic>;
          final isCompleted = data['isProfileCompleted'] == true;
          if (isCompleted) {
            final role = data['role'] ?? 'Student';
            if (role == 'Department Staff') {
              context.go('/staff-dashboard');
            } else {
              context.go('/home');
            }
          } else {
            // Profile incomplete, go to Role Selection
            context.push('/user-type?from=google');
          }
        }
      } catch (e) {
        if (!mounted) return;
        // If 404, it means they didn't complete their profile the first time!
        // We push them to Role Selection directly
        context.push('/user-type?from=google');
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        if (e is FirebaseAuthException) {
          if (e.code == 'network-request-failed') {
            msg = 'Network connection failed while reaching authentication servers. Please check your internet connection and ensure your domain/localhost is authorized in Firebase Console.';
          } else if (e.code == 'popup-closed-by-user') {
            msg = 'Google Sign-In popup was closed before completing.';
          } else if (e.message != null && e.message!.isNotEmpty) {
            msg = e.message!;
          }
        }
        setState(() {
          _errorMessage = msg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SCA Monogram Logo
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.colors.primaryNavy,
                        borderRadius: AppRadius.r14,
                        border: Border.all(
                          color: context.colors.primaryAction.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primaryNavy.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'SCA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Brand Title
                  Text(
                    'Smart Complaint Analyzer',
                    style: AppTextStyles.pageTitle().copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to your institutional account',
                    style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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

                  // Success Notice Banner
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.successLight,
                        borderRadius: AppRadius.r8,
                        border: Border.all(color: context.colors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18, color: context.colors.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: AppTextStyles.caption(color: context.colors.success).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email Input Field
                  AppTextField(
                    label: 'Email',
                    hintText: 'name@gmail.com / @klnce.edu',
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Input Field
                  AppTextField(
                    label: 'Password',
                    hintText: 'Enter your account password',
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
                        return 'Please enter your password';
                      }
                      if (val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.caption(color: context.colors.primaryAction).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Primary Sign In Button
                  AppButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // "OR" Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: context.colors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTextStyles.caption(color: context.colors.textMuted).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: context.colors.border)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign In Button
                  OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: context.colors.surface,
                      foregroundColor: context.colors.textPrimary,
                      side: BorderSide(color: context.colors.border, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.r12),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, size: 24, color: context.colors.primaryNavy),
                              const SizedBox(width: 8),
                              Text(
                                'Sign in with Google',
                                style: AppTextStyles.button(color: context.colors.textPrimary).copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Registration Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.push('/user-type?from=register'),
                        child: Text(
                          'Create Account',
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
      ),
    );
  }
}
