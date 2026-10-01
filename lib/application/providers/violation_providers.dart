import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_violation_dashboard_repository.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/violation_entities.dart';
import '../../domain/repositories/violation_dashboard_repository.dart';
import 'reference_data_providers.dart';

final violationDashboardRepositoryProvider =
    Provider<ViolationDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseViolationDashboardRepository(Supabase.instance.client);
});

final violationPeriodsProvider = FutureProvider<List<ReportPeriod>>((ref) async {
  return ref.watch(violationDashboardRepositoryProvider).getAvailablePeriods();
});

final violationCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(violationDashboardRepositoryProvider).getCategories();
});

final violationDashboardProvider = FutureProvider.autoDispose.family<
    ViolationDashboardSnapshot, ViolationDashboardQuery>((ref, query) async {
  final repository = ref.watch(violationDashboardRepositoryProvider);
  final dataPoints = await repository.getDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
    personnelCategoryId: query.personnelCategoryId,
  );

  return ViolationDashboardSnapshot.fromDataPoints(
    periodId: query.periodId,
    pomdamId: query.pomdamId,
    personnelCategoryId: query.personnelCategoryId,
    category: query.category,
    dataPoints: dataPoints,
  );
});

final class ViolationDashboardQuery {
  const ViolationDashboardQuery({
    required this.periodId,
    this.pomdamId,
    this.personnelCategoryId,
    this.category,
  });

  final String periodId;
  final String? pomdamId;
  final String? personnelCategoryId;
  final String? category;

  @override
  bool operator ==(Object other) {
    return other is ViolationDashboardQuery &&
        other.periodId == periodId &&
        other.pomdamId == pomdamId &&
        other.personnelCategoryId == personnelCategoryId &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(
        periodId,
        pomdamId,
        personnelCategoryId,
        category,
      );
}
