import '../entities/reporting_entities.dart';

abstract interface class ReportingRepository {
  Future<List<ReportSummary>> getReportSummaries();

  Future<List<ReportProvenance>> getProvenance({
    required ReportSelection selection,
    int limit,
  });
}
