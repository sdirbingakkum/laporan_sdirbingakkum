import '../entities/reference_entities.dart';
import '../entities/sim_entities.dart';

abstract interface class SimDashboardRepository {
  Future<List<ReportPeriod>> getAvailablePeriods();

  Future<List<SimDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  });
}
