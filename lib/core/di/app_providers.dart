import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/providers/security_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/notification/presentation/providers/notification_provider.dart';
import '../../features/akademik/presentation/providers/akademik_provider.dart';
import '../../features/keuangan/presentation/providers/keuangan_provider.dart';
import '../../features/kesantrian/presentation/providers/psb_provider.dart';
import '../../shared/router/app_router.dart';
import '../network/dio_client.dart';

class AppProviders {
  static List<SingleChildWidget> get _coreProviders => [
    Provider<DioClient>(
      create: (context) => DioClient(context.read<SharedPreferences>()),
    ),
  ];

  static List<SingleChildWidget> getProviders(SharedPreferences prefs) {
    return [
      Provider<SharedPreferences>.value(value: prefs),
      ..._coreProviders,
      ...AuthProviders.providers,
      ChangeNotifierProvider<SecurityProvider>(
        create: (context) => SecurityProvider(context.read<DioClient>()),
      ),
      ...DashboardProviders.providers,
      ChangeNotifierProvider<NotificationProvider>(
        create: (context) => NotificationProvider(context.read<DioClient>()),
      ),
      ChangeNotifierProvider<AkademikProvider>(
        create: (context) => AkademikProvider(context.read<DioClient>()),
      ),
      ChangeNotifierProvider<KeuanganProvider>(
        create: (context) => KeuanganProvider(context.read<DioClient>()),
      ),
      ChangeNotifierProvider<PsbProvider>(
        create: (context) => PsbProvider(context.read<DioClient>()),
      ),
      // Depends on AuthStateProvider, registered by AuthProviders above.
      Provider<AppRouter>(
        create: (context) => AppRouter(context.read<AuthStateProvider>()),
      ),
    ];
  }
}
