
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_provos_dashboard_repository.dart';
import '../../domain/entities/provos_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/provos_dashboard_repository.dart';
import 'reference_data_providers.dart';

final provosDashboardRepositoryProvider =
    Provider<ProvosDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseProvosDashboardRepository(Supabase.instance.client);
});

final provosPeriodsProvider = FutureProvider<List<ReportPeriod>>((ref) async {
  return ref.watch(provosDashboardRepositoryProvider).getAvailablePeriods();
});

final provosDashboardProvider = FutureProvider.autoDispose.family<
    ProvosDashboardSnapshot, ProvosDashboardQuery>((ref, query) async {
  final repository = ref.watch(provosDashboardRepositoryProvider);
  final dataPoints = await repository.getDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
  );

  return ProvosDashboardSnapshot.fromDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
    dataPoints: dataPoints,
  );
});

final class ProvosDashboardQuery {
  const ProvosDashboardQuery({
    required this.periodId,
    this.pomdamId,
  });

  final String periodId;
  final String? pomdamId;

  @override
  bool operator ==(Object other) {
    return other is ProvosDashboardQuery &&
        other.periodId == periodId &&
        other.pomdamId == pomdamId;
  }

  @override
  int get hashCode => Object.hash(periodId, pomdamId);
}
