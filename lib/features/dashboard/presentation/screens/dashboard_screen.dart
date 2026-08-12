import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_logo_mark.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/article_section.dart';
import '../widgets/billing_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/santri_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogoMark(size: 28),
            const SizedBox(width: 8),
            const Text('Ikhlas', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthStateProvider>().logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  user?.displayName ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: dashboard.loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HeroBanner(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, ${user?.displayName ?? ''}!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ArticleSection(
                      isLoading: dashboard.isLoadingArticles,
                      articles: dashboard.articles,
                      error: dashboard.articlesError,
                    ),
                    const SizedBox(height: 16),
                    SantriCard(
                      isLoading: dashboard.isLoadingSantri,
                      profile: dashboard.santriProfile,
                      error: dashboard.santriError,
                    ),
                    const SizedBox(height: 16),
                    BillingCard(
                      isLoading: dashboard.isLoadingBilling,
                      summary: dashboard.billingSummary,
                      error: dashboard.billingError,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
