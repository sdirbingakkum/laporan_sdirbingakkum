import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_criminal_offense_dashboard_repository.dart';
import '../../domain/entities/criminal_offense_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/criminal_offense_dashboard_repository.dart';
import 'reference_data_providers.dart';

final criminalOffenseDashboardRepositoryProvider =
    Provider<CriminalOffenseDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseCriminalOffenseDashboardRepository(
    Supabase.instance.client,
  );
});

final criminalOffensePeriodsProvider =
    FutureProvider<List<ReportPeriod>>((ref) async {
  return ref
      .watch(criminalOffenseDashboardRepositoryProvider)
      .getAvailablePeriods();
});

final criminalOffenseSourcePeriodsProvider =
    FutureProvider.autoDispose.family<List<String>, String>(
  (ref, periodId) async {
    return ref
        .watch(criminalOffenseDashboardRepositoryProvider)
        .getAvailableSourcePeriods(periodId: periodId);
  },
);

final criminalOffenseDashboardProvider = FutureProvider.autoDispose.family<
    CriminalOffenseDashboardSnapshot,
    CriminalOffenseDashboardQuery>((ref, query) async {
  final repository = ref.watch(criminalOffenseDashboardRepositoryProvider);
  return repository.getDashboard(
    periodId: query.periodId,
    sourcePeriod: query.sourcePeriod,
    pomdamId: query.pomdamId,
    personnelCategoryId: query.personnelCategoryId,
  );
});

final class CriminalOffenseDashboardQuery {
  const CriminalOffenseDashboardQuery({
    required this.periodId,
    required this.sourcePeriod,
    this.pomdamId,
    this.personnelCategoryId,
  });

  final String periodId;
  final String sourcePeriod;
  final String? pomdamId;
  final String? personnelCategoryId;

  @override
  bool operator ==(Object other) {
    return other is CriminalOffenseDashboardQuery &&
        other.periodId == periodId &&
        other.sourcePeriod == sourcePeriod &&
        other.pomdamId == pomdamId &&
        other.personnelCategoryId == personnelCategoryId;
  }

  @override
  int get hashCode =>
      Object.hash(periodId, sourcePeriod, pomdamId, personnelCategoryId);
}
