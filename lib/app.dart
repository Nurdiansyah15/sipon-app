import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'shared/router/app_router.dart';

class SiponApp extends StatelessWidget {
  const SiponApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read once, not watch — avoids recreating GoRouter on every auth change.
    final appRouter = context.read<AppRouter>().router;

    return MaterialApp.router(
      title: 'Sipon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
