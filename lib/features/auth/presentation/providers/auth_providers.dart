import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state_provider.dart';

class AuthProviders {
  static List<SingleChildWidget> get providers => [
    ProxyProvider<DioClient, AuthRemoteDataSource>(
      update: (_, dioClient, _) => AuthRemoteDataSource(dioClient),
    ),
    ProxyProvider2<AuthRemoteDataSource, SharedPreferences, AuthRepository>(
      update: (_, remoteDataSource, prefs, _) =>
          AuthRepositoryImpl(remoteDataSource, prefs),
    ),
    ProxyProvider<AuthRepository, LoginUseCase>(
      update: (_, repo, _) => LoginUseCase(repo),
    ),
    ProxyProvider<AuthRepository, RegisterUseCase>(
      update: (_, repo, _) => RegisterUseCase(repo),
    ),
    ProxyProvider<AuthRepository, LogoutUseCase>(
      update: (_, repo, _) => LogoutUseCase(repo),
    ),
    ProxyProvider<AuthRepository, GetMeUseCase>(
      update: (_, repo, _) => GetMeUseCase(repo),
    ),
    ChangeNotifierProxyProvider4<
      LoginUseCase,
      RegisterUseCase,
      LogoutUseCase,
      GetMeUseCase,
      AuthStateProvider
    >(
      create: (context) => AuthStateProvider(context.read<SharedPreferences>()),
      update: (context, loginUseCase, registerUseCase, logoutUseCase, getMeUseCase, authState) =>
          authState!
            ..updateDependencies(
              loginUseCase,
              registerUseCase,
              logoutUseCase,
              getMeUseCase,
              context.read<DioClient>(),
            ),
    ),
  ];
}
