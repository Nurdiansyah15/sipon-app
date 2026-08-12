import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../../core/network/dio_client.dart';
import '../../../article/data/datasources/article_remote_data_source.dart';
import '../../../article/data/repositories/article_repository_impl.dart';
import '../../../article/domain/repositories/article_repository.dart';
import '../../../article/domain/usecases/get_recent_articles_usecase.dart';
import '../../../kesantrian/data/datasources/kesantrian_remote_data_source.dart';
import '../../../kesantrian/data/repositories/kesantrian_repository_impl.dart';
import '../../../kesantrian/domain/repositories/kesantrian_repository.dart';
import '../../../kesantrian/domain/usecases/get_my_santri_profile_usecase.dart';
import '../../../keuangan/data/datasources/keuangan_remote_data_source.dart';
import '../../../keuangan/data/repositories/keuangan_repository_impl.dart';
import '../../../keuangan/domain/repositories/keuangan_repository.dart';
import '../../../keuangan/domain/usecases/get_my_billing_summary_usecase.dart';
import 'dashboard_provider.dart';

class DashboardProviders {
  static List<SingleChildWidget> get providers => [
    // Artikel
    ProxyProvider<DioClient, ArticleRemoteDataSource>(
      update: (_, dioClient, _) => ArticleRemoteDataSource(dioClient),
    ),
    ProxyProvider<ArticleRemoteDataSource, ArticleRepository>(
      update: (_, remoteDataSource, _) => ArticleRepositoryImpl(remoteDataSource),
    ),
    ProxyProvider<ArticleRepository, GetRecentArticlesUseCase>(
      update: (_, repo, _) => GetRecentArticlesUseCase(repo),
    ),

    // Kesantrian
    ProxyProvider<DioClient, KesantrianRemoteDataSource>(
      update: (_, dioClient, _) => KesantrianRemoteDataSource(dioClient),
    ),
    ProxyProvider<KesantrianRemoteDataSource, KesantrianRepository>(
      update: (_, remoteDataSource, _) => KesantrianRepositoryImpl(remoteDataSource),
    ),
    ProxyProvider<KesantrianRepository, GetMySantriProfileUseCase>(
      update: (_, repo, _) => GetMySantriProfileUseCase(repo),
    ),

    // Keuangan
    ProxyProvider<DioClient, KeuanganRemoteDataSource>(
      update: (_, dioClient, _) => KeuanganRemoteDataSource(dioClient),
    ),
    ProxyProvider<KeuanganRemoteDataSource, KeuanganRepository>(
      update: (_, remoteDataSource, _) => KeuanganRepositoryImpl(remoteDataSource),
    ),
    ProxyProvider<KeuanganRepository, GetMyBillingSummaryUseCase>(
      update: (_, repo, _) => GetMyBillingSummaryUseCase(repo),
    ),

    ChangeNotifierProxyProvider3<
      GetRecentArticlesUseCase,
      GetMySantriProfileUseCase,
      GetMyBillingSummaryUseCase,
      DashboardProvider
    >(
      create: (context) => DashboardProvider(
        context.read<GetRecentArticlesUseCase>(),
        context.read<GetMySantriProfileUseCase>(),
        context.read<GetMyBillingSummaryUseCase>(),
      ),
      update: (_, _, _, _, provider) => provider!,
    ),
  ];
}
