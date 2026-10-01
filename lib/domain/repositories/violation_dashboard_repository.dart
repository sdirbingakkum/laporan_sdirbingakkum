import '../entities/reference_entities.dart';
import '../entities/violation_entities.dart';

abstract interface class ViolationDashboardRepository {
  Future<List<ReportPeriod>> getAvailablePeriods();

  Future<List<String>> getCategories();

  Future<List<ViolationDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
    String? personnelCategoryId,
  });
}
