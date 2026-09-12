import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/admin_tasks_screen.dart';
import '../../features/dashboard/presentation/screens/document_verification_screen.dart';
import '../../features/dashboard/presentation/screens/notifications_screen.dart';
import '../../features/dashboard/presentation/screens/schedule_screen.dart';
import '../../features/kesantrian/presentation/screens/admission_screen.dart';
import '../../features/kesantrian/presentation/screens/admission_timeline_screen.dart';
import '../../features/kesantrian/presentation/screens/documents_screen.dart';
import '../../features/keuangan/presentation/screens/finance_screen.dart';
import '../../features/keuangan/presentation/screens/payment_upload_screen.dart';
import '../../features/keuangan/presentation/screens/payment_history_screen.dart';
import '../../features/keuangan/presentation/screens/invoice_detail_screen.dart';

class AppRouter {
  final AuthStateProvider authStateProvider;

  AppRouter(this.authStateProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authStateProvider,
    redirect: (context, state) {
      final isAuthenticated = authStateProvider.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceScreen(),
      ),
      GoRoute(
        path: '/payment-upload',
        builder: (context, state) => PaymentUploadScreen(
          invoiceId: state.uri.queryParameters['invoiceId'],
        ),
      ),
      GoRoute(
        path: '/payment-history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/invoice/:id',
        builder: (context, state) =>
            InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin-tasks',
        builder: (context, state) => const AdminTasksScreen(),
      ),
      GoRoute(
        path: '/document-verification',
        builder: (context, state) => const DocumentVerificationScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
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
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/admission',
        builder: (context, state) => const AdmissionScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/admission-timeline',
        builder: (context, state) => const AdmissionTimelineScreen(),
      ),
    ],
  );
}
