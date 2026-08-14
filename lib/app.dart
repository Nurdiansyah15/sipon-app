import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'shared/router/app_router.dart';

class SiponApp extends StatelessWidget {
  const SiponApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = context.read<AppRouter>();
    NotificationService.instance.attachRouter(appRouter);

    return MaterialApp.router(
      title: 'Sipon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.router,
    );
  }
}
