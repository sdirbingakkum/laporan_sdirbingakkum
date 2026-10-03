import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_report_input_repository.dart';
import '../../domain/entities/report_input_entities.dart';
import '../../domain/repositories/report_input_repository.dart';
import 'reference_data_providers.dart';

final reportInputRepositoryProvider = Provider<ReportInputRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseReportInputRepository(Supabase.instance.client);
});

final reportInputCatalogProvider = FutureProvider<ReportInputCatalog>((ref) {
  return ref.watch(reportInputRepositoryProvider).getCatalog();
});
