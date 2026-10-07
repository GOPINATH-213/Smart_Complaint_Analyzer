import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// Minimal Enterprise Splash Screen for Smart Complaint Analyzer
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
    final authRepo = ref.read(authRepositoryProvider);
    final api = ref.read(apiServiceProvider);
    final user = authRepo.currentUser;

    if (user != null) {
      try {
        final emailQuery = user.email != null && user.email!.isNotEmpty ? '?email=${Uri.encodeComponent(user.email!)}' : '';
        final profileRes = await api.get('/users/profile/${user.uid}$emailQuery');
        if (!mounted) return;
        
        if (profileRes.statusCode == 200) {
          final data = profileRes.data['data'] as Map<String, dynamic>;
          final rawRole = data['role']?.toString() ?? 'Student';
          final role = rawRole.toLowerCase() == 'admin' ? 'Admin' : rawRole;
          final isCompleted = role == 'Admin' || data['isProfileCompleted'] == true;
          
          if (role != 'Admin' && !user.emailVerified && user.providerData.every((p) => p.providerId == 'password')) {
            context.go('/verify-email');
          } else if (isCompleted) {
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
        } else {
          // If no profile exists (404), go to login
          context.go('/login');
        }
      } catch (e) {
        if (!mounted) return;
        // On network error or other issue, default to login
        context.go('/login');
      }
    } else {
      if (onboardingSeen) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enterprise SCA Monogram Logo
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: context.colors.primaryNavy,
                    borderRadius: AppRadius.r16,
                    border: Border.all(
                      color: context.colors.primaryAction.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primaryNavy.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'SCA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Application Title
                Text(
                  'Smart Complaint Analyzer',
                  style: AppTextStyles.pageTitle().copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Enterprise Positioning Subtitle
                Text(
                  'AI-Powered Complaint Management',
                  style: AppTextStyles.bodyMedium(color: context.colors.textSecondary).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Subtle Progress Indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(context.colors.primaryAction),
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
