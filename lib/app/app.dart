import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers/reference_data_providers.dart';
import '../presentation/router/app_router.dart';
import '../presentation/theme/app_theme.dart';

class LaporanSdirbinGakkumApp extends ConsumerWidget {
  const LaporanSdirbinGakkumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final theme = AppTheme.light();

    if (!config.isConfigured) {
      return MaterialApp(
        title: 'Laporan Sdirbin Gakkum',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const _ConfigurationRequiredPage(),
      );
    }

    return MaterialApp.router(
      title: 'Laporan Sdirbin Gakkum',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

class _ConfigurationRequiredPage extends StatelessWidget {
  const _ConfigurationRequiredPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings_outlined, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      'Konfigurasi aplikasi belum lengkap',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Berikan SUPABASE_PUBLISHABLE_KEY melalui dart-define atau konfigurasi deployment.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
