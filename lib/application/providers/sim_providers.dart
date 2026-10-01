import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_sim_dashboard_repository.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/sim_entities.dart';
import '../../domain/repositories/sim_dashboard_repository.dart';
import 'reference_data_providers.dart';

final simDashboardRepositoryProvider =
    Provider<SimDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseSimDashboardRepository(Supabase.instance.client);
});

final simPeriodsProvider = FutureProvider<List<ReportPeriod>>((ref) async {
  return ref.watch(simDashboardRepositoryProvider).getAvailablePeriods();
});

final simDashboardProvider = FutureProvider.autoDispose.family<
    SimDashboardSnapshot, SimDashboardQuery>((ref, query) async {
  final repository = ref.watch(simDashboardRepositoryProvider);
  final dataPoints = await repository.getDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
  );

  return SimDashboardSnapshot.fromDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
    dataPoints: dataPoints,
  );
});

final class SimDashboardQuery {
  const SimDashboardQuery({
    required this.periodId,
    this.pomdamId,
  });

  final String periodId;
  final String? pomdamId;

  @override
  bool operator ==(Object other) {
    return other is SimDashboardQuery &&
        other.periodId == periodId &&
        other.pomdamId == pomdamId;
  }

  @override
  int get hashCode => Object.hash(periodId, pomdamId);
}
