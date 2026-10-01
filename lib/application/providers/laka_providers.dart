import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_laka_dashboard_repository.dart';
import '../../domain/entities/laka_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/laka_dashboard_repository.dart';
import 'reference_data_providers.dart';

final lakaDashboardRepositoryProvider = Provider<LakaDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }
  return SupabaseLakaDashboardRepository(Supabase.instance.client);
});

final lakaPeriodsProvider = FutureProvider<List<ReportPeriod>>((ref) async {
  return ref.watch(lakaDashboardRepositoryProvider).getAvailablePeriods();
});

final lakaDashboardProvider = FutureProvider.autoDispose.family<LakaDashboardSnapshot, LakaDashboardQuery>((ref, query) async {
  final repository = ref.watch(lakaDashboardRepositoryProvider);
  final dataPoints = await repository.getDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
  );
  return LakaDashboardSnapshot.fromDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
    dataPoints: dataPoints,
  );
});

final class LakaDashboardQuery {
  const LakaDashboardQuery({required this.periodId, this.pomdamId});
  final String periodId;
  final String? pomdamId;

  @override
  bool operator ==(Object other) =>
      other is LakaDashboardQuery &&
      other.periodId == periodId &&
      other.pomdamId == pomdamId;

  @override
  int get hashCode => Object.hash(periodId, pomdamId);
}