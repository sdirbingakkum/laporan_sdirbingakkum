import 'reference_entities.dart';

final class SimDataPoint {
  const SimDataPoint({
    required this.recordId,
    required this.periodId,
    required this.pomdamId,
    required this.simTypeId,
    required this.simCode,
    required this.simDisplayName,
    required this.sourceLabel,
    required this.displayOrder,
    required this.value,
    required this.dataStatus,
    required this.sourceCellId,
    required this.notes,
  });

  final String recordId;
  final String periodId;
  final String pomdamId;
  final String simTypeId;
  final String simCode;
  final String simDisplayName;
  final String? sourceLabel;
  final int displayOrder;
  final int? value;
  final DataStatus dataStatus;
  final String? sourceCellId;
  final String? notes;
}

final class SimMetric {
  const SimMetric({
    required this.simTypeId,
    required this.simCode,
    required this.simDisplayName,
    required this.sourceLabel,
    required this.displayOrder,
    required this.validTotal,
    required this.estimatedTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedCount,
    required this.missingValueCount,
  });

  final String simTypeId;
  final String simCode;
  final String simDisplayName;
  final String? sourceLabel;
  final int displayOrder;
  final int validTotal;
  final int estimatedTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
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

final class SimDashboardSnapshot {
  const SimDashboardSnapshot({
    required this.periodId,
    required this.pomdamId,
    required this.recordCount,
    required this.validTotal,
    required this.estimatedTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedCount,
    required this.missingValueCount,
    required this.metrics,
  });

  final String periodId;
  final String? pomdamId;
  final int recordCount;
  final int validTotal;
  final int estimatedTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedCount;
  final int missingValueCount;
  final List<SimMetric> metrics;

  int get nonConfirmedCount =>
      notReportedCount + invalidSourceCount + estimatedCount;

  factory SimDashboardSnapshot.fromDataPoints({
    required String periodId,
    required String? pomdamId,
    required List<SimDataPoint> dataPoints,
  }) {
    final grouped = <String, _SimMetricAccumulator>{};

    for (final point in dataPoints) {
      final accumulator = grouped.putIfAbsent(
        point.simTypeId,
        () => _SimMetricAccumulator(
          simTypeId: point.simTypeId,
          simCode: point.simCode,
          simDisplayName: point.simDisplayName,
          sourceLabel: point.sourceLabel,
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
        return a.simCode.compareTo(b.simCode);
      });

    var validTotal = 0;
    var estimatedTotal = 0;
    var validCount = 0;
    var notReportedCount = 0;
    var invalidSourceCount = 0;
    var estimatedCount = 0;
    var missingValueCount = 0;

    for (final metric in metrics) {
      validTotal += metric.validTotal;
      estimatedTotal += metric.estimatedTotal;
      validCount += metric.validCount;
      notReportedCount += metric.notReportedCount;
      invalidSourceCount += metric.invalidSourceCount;
      estimatedCount += metric.estimatedCount;
      missingValueCount += metric.missingValueCount;
    }

    return SimDashboardSnapshot(
      periodId: periodId,
      pomdamId: pomdamId,
      recordCount: dataPoints.length,
      validTotal: validTotal,
      estimatedTotal: estimatedTotal,
      validCount: validCount,
      notReportedCount: notReportedCount,
      invalidSourceCount: invalidSourceCount,
      estimatedCount: estimatedCount,
      missingValueCount: missingValueCount,
      metrics: metrics,
    );
  }
}

final class _SimMetricAccumulator {
  _SimMetricAccumulator({
    required this.simTypeId,
    required this.simCode,
    required this.simDisplayName,
    required this.sourceLabel,
    required this.displayOrder,
  });

  final String simTypeId;
  final String simCode;
  final String simDisplayName;
  final String? sourceLabel;
  final int displayOrder;

  int validTotal = 0;
  int estimatedTotal = 0;
  int validCount = 0;
  int notReportedCount = 0;
  int invalidSourceCount = 0;
  int estimatedCount = 0;
  int missingValueCount = 0;

  void add(SimDataPoint point) {
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

  SimMetric toMetric() {
    return SimMetric(
      simTypeId: simTypeId,
      simCode: simCode,
      simDisplayName: simDisplayName,
      sourceLabel: sourceLabel,
      displayOrder: displayOrder,
      validTotal: validTotal,
      estimatedTotal: estimatedTotal,
      validCount: validCount,
      notReportedCount: notReportedCount,
      invalidSourceCount: invalidSourceCount,
      estimatedCount: estimatedCount,
      missingValueCount: missingValueCount,
    );
  }
}
