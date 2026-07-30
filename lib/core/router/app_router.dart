import 'package:codevault/features/authentication/presentation/login_screen.dart';
import 'package:codevault/features/administration/presentation/administration_screen.dart';
import 'package:codevault/features/authentication/presentation/change_password_screen.dart';
import 'package:codevault/features/authentication/presentation/splash_screen.dart';
import 'package:codevault/features/authentication/presentation/forgot_password_screen.dart';
import 'package:codevault/features/labels/presentation/label_studio_screen.dart';
import 'package:codevault/features/backup/presentation/backup_screen.dart';
import 'package:codevault/features/billing/presentation/billing_screen.dart';
import 'package:codevault/features/dashboard/presentation/app_shell.dart';
import 'package:codevault/features/dashboard/presentation/dashboard_screen.dart';
import 'package:codevault/features/settings/presentation/about_screen.dart';
import 'package:codevault/features/settings/presentation/profile_screen.dart';
import 'package:codevault/features/support/presentation/support_screen.dart';
import 'package:codevault/features/printers/presentation/android_printer_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/recovery_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/windows_entry_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/user_management_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/windows_dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isWindows = PlatformCapabilities.current().isWindows;
      final path = state.uri.path;

      if (isWindows) {
        if (path == '/splash') return null;
        if (!path.startsWith('/windows')) {
          return '/windows';
        }
        return null;
      }

      final session = ref.read(sessionProvider);
      final isAuth = session.authenticated;

      final isAuthRoute = path == '/login' ||
          path == '/forgot-password' ||
          path == '/splash';

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      if (isAuth && isAuthRoute && path != '/splash') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/windows',
        builder: (context, state) => const WindowsEntryScreen(),
      ),
      GoRoute(
        path: '/windows/recovery',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OfflineRecoveryScreen(
            companyId: extra['companyId'] as String? ?? '',
            prefillUsername: extra['username'] as String? ?? '',
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/printers',
            builder: (context, state) => const AndroidPrinterScreen(),
          ),
          GoRoute(
            path: '/studio',
            builder: (context, state) => const LabelStudioScreen(),
          ),
          GoRoute(
            path: '/web/print',
            builder: (context, state) => const LabelStudioScreen(),
          ),
          GoRoute(
            path: '/windows/operations',
            builder: (context, state) => const LabelStudioScreen(),
          ),
          GoRoute(
            path: '/windows/dashboard',
            builder: (context, state) => const WindowsDashboardScreen(),
          ),
          GoRoute(
            path: '/windows/users',
            builder: (context, state) => const WindowsUserManagementScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/administration',
            builder: (context, state) => const AdministrationScreen(),
          ),
          GoRoute(
            path: '/billing',
            builder: (context, state) => const BillingScreen(),
          ),
          GoRoute(
            path: '/backup',
            builder: (context, state) => const BackupScreen(),
          ),
          GoRoute(
            path: '/support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  ),
);
