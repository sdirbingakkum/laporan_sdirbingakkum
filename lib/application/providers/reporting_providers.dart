import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_reporting_repository.dart';
import '../../domain/entities/reporting_entities.dart';
import '../../domain/repositories/reporting_repository.dart';
import 'reference_data_providers.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseReportingRepository(Supabase.instance.client);
});

final reportAuditSummaryProvider = FutureProvider<List<ReportSummary>>((ref) {
  return ref.watch(reportingRepositoryProvider).getReportSummaries();
});

final reportProvenanceProvider = FutureProvider.autoDispose
    .family<List<ReportProvenance>, ReportSelection>((ref, selection) {
  return ref
      .watch(reportingRepositoryProvider)
      .getProvenance(selection: selection, limit: 25);
});
