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
import 'package:codevault/features/sync/presentation/sync_status_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/recovery_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/windows_entry_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/user_management_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/windows_dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/splash',
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
        builder: (context, state) =>
            OfflineRecoveryScreen(companyId: state.extra! as String),
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
            path: '/sync',
            builder: (context, state) => const SyncStatusScreen(),
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
            builder: (context, state) => const PermissionAwareBackupScreen(),
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
