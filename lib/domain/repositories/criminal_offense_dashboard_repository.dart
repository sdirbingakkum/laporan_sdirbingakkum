import '../entities/criminal_offense_entities.dart';
import '../entities/reference_entities.dart';

abstract interface class CriminalOffenseDashboardRepository {
  Future<List<ReportPeriod>> getAvailablePeriods();

  Future<List<String>> getAvailableSourcePeriods({
    required String periodId,
  });

  Future<CriminalOffenseDashboardSnapshot> getDashboard({
    required String periodId,
    required String sourcePeriod,
    String? pomdamId,
    String? personnelCategoryId,
  });
}
