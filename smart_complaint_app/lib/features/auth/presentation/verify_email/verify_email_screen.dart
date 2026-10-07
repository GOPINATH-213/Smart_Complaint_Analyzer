import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? role;
  final String? regNum;

  const VerifyEmailScreen({
    super.key,
    this.role,
    this.regNum,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  String? _message;
  String? _errorMessage;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) => _checkVerificationStatus());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() {
      _cooldownSeconds = 60;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds > 1) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final api = ref.read(apiServiceProvider);

      final isVerified = await authRepo.isEmailVerified();

      if (isVerified) {
        _checkTimer?.cancel();
        final user = authRepo.currentUser;

        if (user != null) {
          try {
            await api.put('/users/profile/${user.uid}', {
              'emailVerified': true,
            });
          } catch (_) {}
        }

        if (!mounted) return;
        final targetRole = widget.role ?? 'Student';
        context.go('/profile-completion?role=$targetRole');
      }
    } catch (e) {
      // Background poll silently fails
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_cooldownSeconds > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _message = null;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendEmailVerification();
      _startCooldownTimer();

      if (mounted) {
        setState(() {
          _message = 'A new verification link has been dispatched to your email.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authRepositoryProvider).currentUser;
    final email = user?.email ?? 'your institutional email address';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Email Verification'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: context.colors.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mail Icon Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.border, width: 1.5),
                    boxShadow: AppShadows.cardSubtle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 38,
                    color: context.colors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Verify Your Institutional Email',
                  style: AppTextStyles.pageTitle().copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                Text(
                  'A secure verification link has been dispatched to:',
                  style: AppTextStyles.bodyMedium(color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: AppRadius.r8,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Text(
                    email,
                    style: AppTextStyles.cardTitle(color: context.colors.primaryNavy).copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),

                // Success Message Banner
                if (_message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.successLight,
                      borderRadius: AppRadius.r8,
                      border: Border.all(color: context.colors.success.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _message!,
                      style: AppTextStyles.caption(color: context.colors.success).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Error Message Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.errorLight,
                      borderRadius: AppRadius.r8,
                      border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.caption(color: context.colors.error).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Guidance Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: AppRadius.r12,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: context.colors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Institutional Verification Protocol',
                            style: AppTextStyles.cardTitle(color: context.colors.textPrimary).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Check your inbox and spam/junk folders.\n2. Click the verification link to confirm ownership.\n3. Return to this screen; verification will auto-detect.',
                        style: AppTextStyles.caption(color: context.colors.textSecondary).copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),



                // Resend Link Button
                OutlinedButton(
                  onPressed: _cooldownSeconds > 0 ? null : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primaryNavy,
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.r12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isResending
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          _cooldownSeconds > 0
                              ? 'Resend Link in ${_cooldownSeconds}s'
                              : 'Resend Verification Email',
                          style: AppTextStyles.button(
                            color: _cooldownSeconds > 0 ? context.colors.textMuted : context.colors.primaryNavy,
                          ).copyWith(fontSize: 14),
                        ),
                ),
                const SizedBox(height: 20),

                // Return to Sign In
                TextButton(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  child: Text(
                    'Return to Sign In',
                    style: AppTextStyles.button(color: context.colors.primaryAction).copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
