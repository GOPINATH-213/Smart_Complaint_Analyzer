import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/register/register_screen.dart';
import '../../features/auth/presentation/role_selection/user_type_screen.dart';
import '../../features/auth/presentation/verify_email/verify_email_screen.dart';
import '../../features/auth/presentation/forgot_password/forgot_password_screen.dart';
import '../../features/auth/presentation/onboarding/onboarding_screen.dart';
import '../../features/auth/presentation/splash/splash_screen.dart';
import '../../features/auth/presentation/profile_completion/profile_completion_screen.dart';
import '../../features/profile/presentation/settings/settings_screen.dart';
import '../../features/user/dashboard/presentation/user_dashboard_screen.dart';
import '../../features/profile/presentation/profile/profile_screen.dart';
import '../../features/user/submit_complaint/presentation/submit_complaint_screen.dart';
import '../../features/user/my_complaints/presentation/my_complaints_screen.dart';
import '../../features/department_staff/dashboard/presentation/staff_dashboard_screen.dart';
import '../../features/department_staff/students/presentation/staff_students_screen.dart';
import '../../features/complaints/presentation/complaint_details/complaint_detail_screen.dart';
import '../../features/admin/dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/admin/students/presentation/admin_students_screen.dart';
import '../../features/admin/staff/presentation/admin_staff_screen.dart';
import '../../features/admin/departments/presentation/admin_departments_screen.dart';
import '../../features/admin/complaints/presentation/admin_complaints_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.read(authRepositoryProvider);

  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authRepo.currentUser;
      final path = state.uri.path;

      // Allow unrestricted access to these public routes
      final isPublicRoute = [
        '/',
        '/login',
        '/register',
        '/forgot-password',
        '/onboarding',
        '/user-type',
      ].contains(path);

      if (user == null) {
        return isPublicRoute ? null : '/login';
      }

      // Read profile synchronously if available for role-based route protection
      final profileAsync = ref.read(userProfileProvider);
      final profileData = (profileAsync is AsyncData) ? profileAsync.value : null;
      final rawRole = profileData?['role']?.toString();
      final role = rawRole?.toLowerCase() == 'admin' ? 'Admin' : rawRole;
      final isAdminRoute = path.startsWith('/admin') || path == '/admin-dashboard';

      final isAuthRoute = path == '/login' || path == '/register' || path == '/user-type';

      if (role != 'Admin' && !isAdminRoute && !isAuthRoute && !user.emailVerified && user.providerData.every((p) => p.providerId == 'password') && path != '/verify-email') {
        return '/verify-email';
      }

      if (profileData != null) {
        final isCompleted = role == 'Admin' || profileData['isProfileCompleted'] == true;

        if (isCompleted) {
          final isStaffRoute = path == '/staff-dashboard' || path == '/staff/students';
          final isStudentRoute = ['/home', '/submit-complaint', '/my-complaints'].contains(path);

          if (role == 'Admin') {
            if (isPublicRoute || isStudentRoute || isStaffRoute) {
              return '/admin-dashboard';
            }
          } else if (role == 'Department Staff') {
            if (isPublicRoute || isAdminRoute || isStudentRoute) {
              return '/staff-dashboard';
            }
          } else if (role == 'Student') {
            if (isPublicRoute || isAdminRoute || isStaffRoute) {
              return '/home';
            }
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/user-type',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? 'register';
          return UserTypeScreen(from: from);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'Student';
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'Student';
          final regNum = state.uri.queryParameters['regNum'] ?? '';
          return VerifyEmailScreen(role: role, regNum: regNum);
        },
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return ProfileCompletionScreen(role: role);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const UserDashboardScreen(initialTab: 0),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/submit-complaint',
        builder: (context, state) => const SubmitComplaintScreen(),
      ),
      GoRoute(
        path: '/my-complaints',
        builder: (context, state) => const MyComplaintsScreen(),
      ),
      GoRoute(
        path: '/staff-dashboard',
        builder: (context, state) => const StaffDashboardScreen(),
      ),
      GoRoute(
        path: '/staff/students',
        builder: (context, state) => const StaffStudentsScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: '/admin/staff',
        builder: (context, state) => const AdminStaffScreen(),
      ),
      GoRoute(
        path: '/admin/departments',
        builder: (context, state) => const AdminDepartmentsScreen(),
      ),
      GoRoute(
        path: '/admin/complaints',
        builder: (context, state) {
          final dept = state.uri.queryParameters['dept'];
          return AdminComplaintsScreen(initialDept: dept);
        },
      ),
      GoRoute(
        path: '/complaint-detail/:id',
        builder: (context, state) {
          final complaintId = state.pathParameters['id'] ?? state.uri.queryParameters['id'] ?? '';
          return ComplaintDetailScreen(complaintId: complaintId);
        },
      ),
      GoRoute(
        path: '/complaint-detail',
        builder: (context, state) {
          final complaintId = state.uri.queryParameters['id'] ?? '';
          return ComplaintDetailScreen(complaintId: complaintId);
        },
      ),
    ],
  );

  // Listen to auth state changes and trigger router refresh
  ref.listen(authStateProvider, (previous, next) {
    router.refresh();
  });

  return router;
});

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    ],
  );
}

