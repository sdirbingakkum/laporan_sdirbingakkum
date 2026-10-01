import '../entities/laka_entities.dart';
import '../entities/reference_entities.dart';

abstract interface class LakaDashboardRepository {
  Future<List<ReportPeriod>> getAvailablePeriods();

  Future<List<LakaDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  });
}