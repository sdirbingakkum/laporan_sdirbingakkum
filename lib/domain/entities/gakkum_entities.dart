import 'reference_entities.dart';

final class GakkumDataPoint {
  const GakkumDataPoint({
    required this.recordId,
    required this.periodId,
    required this.pomdamId,
    required this.activityVersionId,
    required this.activityCode,
    required this.activityName,
    required this.sourceLabel,
    required this.level,
    required this.displayOrder,
    required this.taxonomyVersion,
    required this.value,
    required this.dataStatus,
    required this.notes,
  });

  final String recordId;
  final String periodId;
  final String pomdamId;
  final String activityVersionId;
  final String activityCode;
  final String activityName;
  final String sourceLabel;
  final int level;
  final int displayOrder;
  final String taxonomyVersion;
  final int? value;
  final DataStatus dataStatus;
  final String? notes;
}

final class GakkumActivityMetric {
  const GakkumActivityMetric({
    required this.activityVersionId,
    required this.activityCode,
    required this.activityName,
    required this.sourceLabel,
    required this.level,
    required this.displayOrder,
    required this.taxonomyVersion,
    required this.validTotal,
    required this.estimatedTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedCount,
    required this.missingValueCount,
  });

  final String activityVersionId;
  final String activityCode;
  final String activityName;
  final String sourceLabel;
  final int level;
  final int displayOrder;
  final String taxonomyVersion;
  final int validTotal;
  final int estimatedTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedCount;
  final int missingValueCount;

  int get recordCount =>
      validCount + notReportedCount + invalidSourceCount + estimatedCount;
}

final class GakkumDashboardSnapshot {
  const GakkumDashboardSnapshot({
    required this.periodId,
    required this.pomdamId,
    required this.level,
    required this.taxonomyVersion,
    required this.recordCount,
    required this.validTotal,
    required this.estimatedTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedCount,
    required this.missingValueCount,
    required this.activities,
  });

  final String periodId;
  final String? pomdamId;
  final int level;
  final String taxonomyVersion;
  final int recordCount;
  final int validTotal;
  final int estimatedTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedCount;
  final int missingValueCount;
  final List<GakkumActivityMetric> activities;

  int get nonConfirmedCount =>
      notReportedCount + invalidSourceCount + estimatedCount;

  factory GakkumDashboardSnapshot.fromDataPoints({
    required String periodId,
    required String? pomdamId,
    required int level,
    required List<GakkumDataPoint> dataPoints,
  }) {
    final selected = dataPoints.where((point) => point.level == level);

    final grouped = <String, _MetricAccumulator>{};

    for (final point in selected) {
      final accumulator = grouped.putIfAbsent(
        point.activityVersionId,
        () => _MetricAccumulator(
          activityVersionId: point.activityVersionId,
          activityCode: point.activityCode,
          activityName: point.activityName,
          sourceLabel: point.sourceLabel,
          level: point.level,
          displayOrder: point.displayOrder,
          taxonomyVersion: point.taxonomyVersion,
        ),
      );
      accumulator.add(point);
    }

    final metrics = grouped.values
        .map((value) => value.toMetric())
        .toList(growable: false)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final taxonomyVersions =
        selected.map((point) => point.taxonomyVersion).toSet();

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

    return GakkumDashboardSnapshot(
      periodId: periodId,
      pomdamId: pomdamId,
      level: level,
      taxonomyVersion:
          taxonomyVersions.length == 1 ? taxonomyVersions.first : 'MIXED',
      recordCount: selected.length,
      validTotal: validTotal,
      estimatedTotal: estimatedTotal,
      validCount: validCount,
      notReportedCount: notReportedCount,
      invalidSourceCount: invalidSourceCount,
      estimatedCount: estimatedCount,
      missingValueCount: missingValueCount,
      activities: metrics,
    );
  }
}

final class _MetricAccumulator {
  _MetricAccumulator({
    required this.activityVersionId,
    required this.activityCode,
    required this.activityName,
    required this.sourceLabel,
    required this.level,
    required this.displayOrder,
    required this.taxonomyVersion,
  });

  final String activityVersionId;
  final String activityCode;
  final String activityName;
  final String sourceLabel;
  final int level;
  final int displayOrder;
  final String taxonomyVersion;

  int validTotal = 0;
  int estimatedTotal = 0;
  int validCount = 0;
  int notReportedCount = 0;
  int invalidSourceCount = 0;
  int estimatedCount = 0;
  int missingValueCount = 0;

  void add(GakkumDataPoint point) {
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

  GakkumActivityMetric toMetric() {
    return GakkumActivityMetric(
      activityVersionId: activityVersionId,
      activityCode: activityCode,
      activityName: activityName,
      sourceLabel: sourceLabel,
      level: level,
      displayOrder: displayOrder,
      taxonomyVersion: taxonomyVersion,
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
