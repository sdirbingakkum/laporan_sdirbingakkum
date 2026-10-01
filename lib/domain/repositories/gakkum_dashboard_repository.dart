import '../entities/gakkum_entities.dart';

abstract interface class GakkumDashboardRepository {
  Future<List<GakkumDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  });
}
