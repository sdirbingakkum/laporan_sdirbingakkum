import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_gakkum_dashboard_repository.dart';
import '../../domain/entities/gakkum_entities.dart';
import '../../domain/repositories/gakkum_dashboard_repository.dart';
import 'reference_data_providers.dart';

final gakkumDashboardRepositoryProvider =
    Provider<GakkumDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseGakkumDashboardRepository(Supabase.instance.client);
});

final gakkumPeriodsProvider = FutureProvider<List<ReportPeriod>>((ref) async {
  return ref.watch(gakkumDashboardRepositoryProvider).getAvailablePeriods();
});

final gakkumDashboardProvider = FutureProvider.autoDispose.family<
    GakkumDashboardSnapshot, GakkumDashboardQuery>((ref, query) async {
  final repository = ref.watch(gakkumDashboardRepositoryProvider);
  final dataPoints = await repository.getDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
  );

  return GakkumDashboardSnapshot.fromDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
    level: query.level,
    dataPoints: dataPoints,
  );
});

final class GakkumDashboardQuery {
  const GakkumDashboardQuery({
    required this.periodId,
    required this.level,
    this.pomdamId,
  });

  final String periodId;
  final String? pomdamId;
  final int level;

  @override
  bool operator ==(Object other) {
    return other is GakkumDashboardQuery &&
        other.periodId == periodId &&
        other.pomdamId == pomdamId &&
        other.level == level;
  }

  @override
  int get hashCode => Object.hash(periodId, pomdamId, level);
}
