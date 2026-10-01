import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reference_entities.dart';
import 'reference_data_providers.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(referenceDataRepositoryProvider);

  final results = await Future.wait<dynamic>([
    repository.getPomdams(),
    repository.getReportTypes(),
    repository.getReportPeriods(),
  ]);

  return DashboardSummary(
    pomdamCount: (results[0] as List<Pomdam>).length,
    reportTypeCount: (results[1] as List<ReportType>).length,
    periodCount: (results[2] as List<ReportPeriod>).length,
  );
});

final class DashboardSummary {
  const DashboardSummary({
    required this.pomdamCount,
    required this.reportTypeCount,
    required this.periodCount,
  });

  final int pomdamCount;
  final int reportTypeCount;
  final int periodCount;
}
