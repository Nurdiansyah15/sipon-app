import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
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
      ...DashboardProviders.providers,
      // Depends on AuthStateProvider, registered by AuthProviders above.
      Provider<AppRouter>(
        create: (context) => AppRouter(context.read<AuthStateProvider>()),
      ),
    ];
  }
}
