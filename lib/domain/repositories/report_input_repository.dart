import '../entities/report_input_entities.dart';
import '../entities/reference_entities.dart';

abstract interface class ReportInputRepository {
  Future<ReportInputCatalog> getCatalog();

  Future<ReportPeriod> getOrCreateMonthlyPeriod({
    required int year,
    required int month,
  });

  Future<ReportPeriod> createPeriod({
    required DateTime periodStart,
    required DateTime periodEnd,
    required String periodLabel,
    String periodType = 'MONTH',
  });

  Future<ReportInputSubmission> submitReport({
    required String reportType,
    required String periodId,
    required String pomdamId,
    required Map<String, dynamic> payload,
  });
}
