import 'reference_entities.dart';

final class CriminalOffenseDataPoint {
  const CriminalOffenseDataPoint({
    required this.recordId,
    required this.periodId,
    required this.pomdamId,
    required this.offenseVersionId,
    required this.personnelCategoryId,
    required this.offenseId,
    required this.canonicalKey,
    required this.canonicalName,
    required this.sourceNumber,
    required this.sourceLabel,
    required this.sourcePeriod,
    required this.displayOrder,
    required this.value,
    required this.dataStatus,
    required this.sourceCellId,
    required this.notes,
  });

  final String recordId;
  final String periodId;
  final String pomdamId;
  final String offenseVersionId;
  final String personnelCategoryId;
  final String offenseId;
  final String canonicalKey;
  final String canonicalName;
  final int sourceNumber;
  final String sourceLabel;
  final String? sourcePeriod;
  final int displayOrder;
  final int? value;
  final DataStatus dataStatus;
  final String? sourceCellId;
  final String? notes;
}

final class CriminalOffenseMetric {
  const CriminalOffenseMetric({
    required this.offenseVersionId,
    required this.offenseId,
    required this.canonicalKey,
    required this.canonicalName,
    required this.sourceNumber,
    required this.sourceLabel,
    required this.sourcePeriod,
    required this.displayOrder,
    required this.validTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedTotal,
    required this.estimatedCount,
    required this.missingValueCount,
  });

  final String offenseVersionId;
  final String offenseId;
  final String canonicalKey;
  final String canonicalName;
  final int sourceNumber;
  final String sourceLabel;
  final String? sourcePeriod;
  final int displayOrder;
  final int validTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedTotal;
  final int estimatedCount;
  final int missingValueCount;

  int get recordCount =>
      validCount + notReportedCount + invalidSourceCount + estimatedCount;

  int get issueCount =>
      notReportedCount +
      invalidSourceCount +
      estimatedCount +
      missingValueCount;
}

final class CriminalOffenseDashboardSnapshot {
  const CriminalOffenseDashboardSnapshot({
    required this.periodId,
    required this.pomdamId,
    required this.personnelCategoryId,
    required this.sourcePeriod,
    required this.recordCount,
    required this.validTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedTotal,
    required this.estimatedCount,
    required this.missingValueCount,
    required this.metrics,
  });

  final String periodId;
  final String? pomdamId;
  final String? personnelCategoryId;
  final String sourcePeriod;
  final int recordCount;
  final int validTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedTotal;
  final int estimatedCount;
  final int missingValueCount;
  final List<CriminalOffenseMetric> metrics;

  factory CriminalOffenseDashboardSnapshot.fromDataPoints({
    required String periodId,
    required String? pomdamId,
    required String? personnelCategoryId,
    required String sourcePeriod,
    required List<CriminalOffenseDataPoint> dataPoints,
  }) {
    final selected = dataPoints.where(
      (point) => point.sourcePeriod == sourcePeriod,
    );

    final grouped = <String, _MetricAccumulator>{};

    for (final point in selected) {
      final accumulator = grouped.putIfAbsent(
        point.offenseVersionId,
        () => _MetricAccumulator(
          offenseVersionId: point.offenseVersionId,
          offenseId: point.offenseId,
          canonicalKey: point.canonicalKey,
          canonicalName: point.canonicalName,
          sourceNumber: point.sourceNumber,
          sourceLabel: point.sourceLabel,
          sourcePeriod: point.sourcePeriod,
          displayOrder: point.displayOrder,
        ),
      );
      accumulator.add(point);
    }

    final metrics = grouped.values
        .map((value) => value.toMetric())
        .toList(growable: false)
      ..sort((a, b) {
        final order = a.displayOrder.compareTo(b.displayOrder);
        if (order != 0) return order;
        return a.sourceNumber.compareTo(b.sourceNumber);
      });

    var validTotal = 0;
    var validCount = 0;
    var notReportedCount = 0;
    var invalidSourceCount = 0;
    var estimatedTotal = 0;
    var estimatedCount = 0;
    var missingValueCount = 0;

    for (final metric in metrics) {
      validTotal += metric.validTotal;
      validCount += metric.validCount;
      notReportedCount += metric.notReportedCount;
      invalidSourceCount += metric.invalidSourceCount;
      estimatedTotal += metric.estimatedTotal;
      estimatedCount += metric.estimatedCount;
      missingValueCount += metric.missingValueCount;
    }

    return CriminalOffenseDashboardSnapshot(
      periodId: periodId,
      pomdamId: pomdamId,
      personnelCategoryId: personnelCategoryId,
      sourcePeriod: sourcePeriod,
      recordCount: selected.length,
      validTotal: validTotal,
      validCount: validCount,
      notReportedCount: notReportedCount,
      invalidSourceCount: invalidSourceCount,
      estimatedTotal: estimatedTotal,
      estimatedCount: estimatedCount,
      missingValueCount: missingValueCount,
      metrics: metrics,
    );
  }
}

final class _MetricAccumulator {
  _MetricAccumulator({
    required this.offenseVersionId,
    required this.offenseId,
    required this.canonicalKey,
    required this.canonicalName,
    required this.sourceNumber,
    required this.sourceLabel,
    required this.sourcePeriod,
    required this.displayOrder,
  });

  final String offenseVersionId;
  final String offenseId;
  final String canonicalKey;
  final String canonicalName;
  final int sourceNumber;
  final String sourceLabel;
  final String? sourcePeriod;
  final int displayOrder;

  int validTotal = 0;
  int validCount = 0;
  int notReportedCount = 0;
  int invalidSourceCount = 0;
  int estimatedTotal = 0;
  int estimatedCount = 0;
  int missingValueCount = 0;

  void add(CriminalOffenseDataPoint point) {
    switch (point.dataStatus) {
      case DataStatus.valid:
        validCount++;
        if (point.value == null) {
          missingValueCount++;
        } else {
          validTotal += point.value!;
        }
      case DataStatus.notReported:
        notReportedCount++;
      case DataStatus.invalidSource:
        invalidSourceCount++;
      case DataStatus.estimated:
        estimatedCount++;
        if (point.value == null) {
          missingValueCount++;
        } else {
          estimatedTotal += point.value!;
        }
    }
  }

  CriminalOffenseMetric toMetric() {
    return CriminalOffenseMetric(
      offenseVersionId: offenseVersionId,
      offenseId: offenseId,
      canonicalKey: canonicalKey,
      canonicalName: canonicalName,
      sourceNumber: sourceNumber,
      sourceLabel: sourceLabel,
      sourcePeriod: sourcePeriod,
      displayOrder: displayOrder,
      validTotal: validTotal,
      validCount: validCount,
      notReportedCount: notReportedCount,
      invalidSourceCount: invalidSourceCount,
      estimatedTotal: estimatedTotal,
      estimatedCount: estimatedCount,
      missingValueCount: missingValueCount,
    );
  }
}
