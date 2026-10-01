import 'reference_entities.dart';

enum LakaSection {
  accident,
  personnel,
  material,
  victimRank,
  victimOutcome,
}

final class LakaDataPoint {
  const LakaDataPoint({
    required this.recordId,
    required this.periodId,
    required this.pomdamId,
    required this.section,
    required this.primaryDimensionId,
    required this.secondaryDimensionId,
    required this.primaryCode,
    required this.primaryName,
    required this.secondaryCode,
    required this.secondaryName,
    required this.displayOrder,
    required this.value,
    required this.dataStatus,
    required this.sourceCellId,
    required this.notes,
  });

  final String recordId;
  final String periodId;
  final String pomdamId;
  final LakaSection section;
  final String primaryDimensionId;
  final String? secondaryDimensionId;
  final String primaryCode;
  final String primaryName;
  final String? secondaryCode;
  final String? secondaryName;
  final int displayOrder;
  final int? value;
  final DataStatus dataStatus;
  final String? sourceCellId;
  final String? notes;
}

final class LakaMetric {
  const LakaMetric({
    required this.section,
    required this.primaryDimensionId,
    required this.secondaryDimensionId,
    required this.primaryCode,
    required this.primaryName,
    required this.secondaryCode,
    required this.secondaryName,
    required this.displayOrder,
    required this.validTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedTotal,
    required this.estimatedCount,
    required this.missingValueCount,
  });

  final LakaSection section;
  final String primaryDimensionId;
  final String? secondaryDimensionId;
  final String primaryCode;
  final String primaryName;
  final String? secondaryCode;
  final String? secondaryName;
  final int displayOrder;
  final int validTotal;
  final int validCount;
  final int notReportedCount;
  final int invalidSourceCount;
  final int estimatedTotal;
  final int estimatedCount;
  final int missingValueCount;

  int get issueCount =>
      notReportedCount +
      invalidSourceCount +
      estimatedCount +
      missingValueCount;
}

final class LakaSectionSnapshot {
  const LakaSectionSnapshot({
    required this.section,
    required this.metrics,
  });

  final LakaSection section;
  final List<LakaMetric> metrics;

  int get validTotal =>
      metrics.fold(0, (sum, metric) => sum + metric.validTotal);
  int get validCount =>
      metrics.fold(0, (sum, metric) => sum + metric.validCount);
  int get notReportedCount =>
      metrics.fold(0, (sum, metric) => sum + metric.notReportedCount);
  int get invalidSourceCount =>
      metrics.fold(0, (sum, metric) => sum + metric.invalidSourceCount);
  int get estimatedCount =>
      metrics.fold(0, (sum, metric) => sum + metric.estimatedCount);
  int get missingValueCount =>
      metrics.fold(0, (sum, metric) => sum + metric.missingValueCount);
}

final class LakaDashboardSnapshot {
  const LakaDashboardSnapshot({
    required this.periodId,
    required this.pomdamId,
    required this.accident,
    required this.personnel,
    required this.material,
    required this.victimRank,
    required this.victimOutcome,
  });

  final String periodId;
  final String? pomdamId;
  final LakaSectionSnapshot accident;
  final LakaSectionSnapshot personnel;
  final LakaSectionSnapshot material;
  final LakaSectionSnapshot victimRank;
  final LakaSectionSnapshot victimOutcome;

  static LakaDashboardSnapshot fromDataPoints({
    required String periodId,
    required String? pomdamId,
    required List<LakaDataPoint> dataPoints,
  }) {
    final grouped = <String, _LakaMetricAccumulator>{};

    for (final point in dataPoints) {
      final key = [
        point.section.name,
        point.primaryDimensionId,
        point.secondaryDimensionId ?? '',
      ].join(':');
      final accumulator = grouped.putIfAbsent(
        key,
        () => _LakaMetricAccumulator(
          section: point.section,
          primaryDimensionId: point.primaryDimensionId,
          secondaryDimensionId: point.secondaryDimensionId,
          primaryCode: point.primaryCode,
          primaryName: point.primaryName,
          secondaryCode: point.secondaryCode,
          secondaryName: point.secondaryName,
          displayOrder: point.displayOrder,
        ),
      );
      accumulator.add(point);
    }

    final metrics = grouped.values
        .map((value) => value.toMetric())
        .toList(growable: false)
      ..sort((a, b) {
        final sectionOrder = a.section.index.compareTo(b.section.index);
        if (sectionOrder != 0) return sectionOrder;
        final order = a.displayOrder.compareTo(b.displayOrder);
        if (order != 0) return order;
        return a.primaryCode.compareTo(b.primaryCode);
      });

    List<LakaMetric> sectionMetrics(LakaSection section) =>
        metrics.where((metric) => metric.section == section).toList();

    return LakaDashboardSnapshot(
      periodId: periodId,
      pomdamId: pomdamId,
      accident: LakaSectionSnapshot(
        section: LakaSection.accident,
        metrics: sectionMetrics(LakaSection.accident),
      ),
      personnel: LakaSectionSnapshot(
        section: LakaSection.personnel,
        metrics: sectionMetrics(LakaSection.personnel),
      ),
      material: LakaSectionSnapshot(
        section: LakaSection.material,
        metrics: sectionMetrics(LakaSection.material),
      ),
      victimRank: LakaSectionSnapshot(
        section: LakaSection.victimRank,
        metrics: sectionMetrics(LakaSection.victimRank),
      ),
      victimOutcome: LakaSectionSnapshot(
        section: LakaSection.victimOutcome,
        metrics: sectionMetrics(LakaSection.victimOutcome),
      ),
    );
  }
}

final class _LakaMetricAccumulator {
  _LakaMetricAccumulator({
    required this.section,
    required this.primaryDimensionId,
    required this.secondaryDimensionId,
    required this.primaryCode,
    required this.primaryName,
    required this.secondaryCode,
    required this.secondaryName,
    required this.displayOrder,
  });

  final LakaSection section;
  final String primaryDimensionId;
  final String? secondaryDimensionId;
  final String primaryCode;
  final String primaryName;
  final String? secondaryCode;
  final String? secondaryName;
  final int displayOrder;

  int validTotal = 0;
  int validCount = 0;
  int notReportedCount = 0;
  int invalidSourceCount = 0;
  int estimatedTotal = 0;
  int estimatedCount = 0;
  int missingValueCount = 0;

  void add(LakaDataPoint point) {
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

  LakaMetric toMetric() => LakaMetric(
        section: section,
        primaryDimensionId: primaryDimensionId,
        secondaryDimensionId: secondaryDimensionId,
        primaryCode: primaryCode,
        primaryName: primaryName,
        secondaryCode: secondaryCode,
        secondaryName: secondaryName,
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