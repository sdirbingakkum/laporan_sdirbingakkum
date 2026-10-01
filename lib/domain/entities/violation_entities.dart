import 'reference_entities.dart';

final class ViolationDataPoint {
  const ViolationDataPoint({
    required this.recordId,
    required this.periodId,
    required this.pomdamId,
    required this.violationVersionId,
    required this.personnelCategoryId,
    required this.violationId,
    required this.canonicalCode,
    required this.canonicalName,
    required this.category,
    required this.sourceCode,
    required this.sourceLabel,
    required this.sourcePeriod,
    required this.displayOrder,
    required this.value,
    required this.dataStatus,
    required this.notes,
  });

  final String recordId;
  final String periodId;
  final String pomdamId;
  final String violationVersionId;
  final String personnelCategoryId;
  final String violationId;
  final String canonicalCode;
  final String canonicalName;
  final String category;
  final String sourceCode;
  final String sourceLabel;
  final String? sourcePeriod;
  final int? displayOrder;
  final int? value;
  final DataStatus dataStatus;
  final String? notes;
}

final class ViolationMetric {
  const ViolationMetric({
    required this.violationVersionId,
    required this.violationId,
    required this.canonicalCode,
    required this.canonicalName,
    required this.category,
    required this.sourceCode,
    required this.sourceLabel,
    required this.sourcePeriod,
    required this.displayOrder,
    required this.validTotal,
    required this.estimatedTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedCount,
    required this.missingValueCount,
  });

  final String violationVersionId;
  final String violationId;
  final String canonicalCode;
  final String canonicalName;
  final String category;
  final String sourceCode;
  final String sourceLabel;
  final String? sourcePeriod;
  final int? displayOrder;
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

final class ViolationDashboardSnapshot {
  const ViolationDashboardSnapshot({
    required this.periodId,
    required this.pomdamId,
    required this.personnelCategoryId,
    required this.category,
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
  final String? personnelCategoryId;
  final String? category;
  final int recordCount;
  final int validTotal;
  final int estimatedTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedCount;
  final int missingValueCount;
  final List<ViolationMetric> metrics;

  factory ViolationDashboardSnapshot.fromDataPoints({
    required String periodId,
    required String? pomdamId,
    required String? personnelCategoryId,
    required String? category,
    required List<ViolationDataPoint> dataPoints,
  }) {
    final selected = dataPoints.where(
      (point) => category == null || point.category == category,
    );

    final grouped = <String, _MetricAccumulator>{};

    for (final point in selected) {
      final accumulator = grouped.putIfAbsent(
        point.violationVersionId,
        () => _MetricAccumulator(
          violationVersionId: point.violationVersionId,
          violationId: point.violationId,
          canonicalCode: point.canonicalCode,
          canonicalName: point.canonicalName,
          category: point.category,
          sourceCode: point.sourceCode,
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
        final orderCompare = (a.displayOrder ?? 2147483647).compareTo(
          b.displayOrder ?? 2147483647,
        );
        if (orderCompare != 0) {
          return orderCompare;
        }

        final categoryCompare = a.category.compareTo(b.category);
        if (categoryCompare != 0) {
          return categoryCompare;
        }

        return a.sourceCode.compareTo(b.sourceCode);
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

    return ViolationDashboardSnapshot(
      periodId: periodId,
      pomdamId: pomdamId,
      personnelCategoryId: personnelCategoryId,
      category: category,
      recordCount: selected.length,
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

final class _MetricAccumulator {
  _MetricAccumulator({
    required this.violationVersionId,
    required this.violationId,
    required this.canonicalCode,
    required this.canonicalName,
    required this.category,
    required this.sourceCode,
    required this.sourceLabel,
    required this.sourcePeriod,
    required this.displayOrder,
  });

  final String violationVersionId;
  final String violationId;
  final String canonicalCode;
  final String canonicalName;
  final String category;
  final String sourceCode;
  final String sourceLabel;
  final String? sourcePeriod;
  final int? displayOrder;

  int validTotal = 0;
  int estimatedTotal = 0;
  int validCount = 0;
  int notReportedCount = 0;
  int invalidSourceCount = 0;
  int estimatedCount = 0;
  int missingValueCount = 0;

  void add(ViolationDataPoint point) {
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

  ViolationMetric toMetric() {
    return ViolationMetric(
      violationVersionId: violationVersionId,
      violationId: violationId,
      canonicalCode: canonicalCode,
      canonicalName: canonicalName,
      category: category,
      sourceCode: sourceCode,
      sourceLabel: sourceLabel,
      sourcePeriod: sourcePeriod,
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
