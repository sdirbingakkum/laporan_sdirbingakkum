import '../entities/gakkum_entities.dart';
import '../entities/reference_entities.dart';

abstract interface class GakkumDashboardRepository {
  Future<List<ReportPeriod>> getAvailablePeriods();

  Future<List<GakkumDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  });
}
