
import '../entities/provos_entities.dart';
import '../entities/reference_entities.dart';

abstract interface class ProvosDashboardRepository {
  Future<List<ReportPeriod>> getAvailablePeriods();

  Future<List<ProvosDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  });
}
