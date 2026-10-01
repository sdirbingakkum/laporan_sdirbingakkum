
import 'reference_entities.dart';

enum ProvosSection {
  strength,
  personnel,
  education,
}

final class ProvosDataPoint {
  const ProvosDataPoint({
    required this.recordId,
    required this.periodId,
    required this.pomdamId,
    required this.dimensionId,
    required this.code,
    required this.name,
    required this.section,
    required this.displayOrder,
    required this.value,
    required this.dataStatus,
    required this.sourceCellId,
    required this.notes,
  });

  final String recordId;
  final String periodId;
  final String pomdamId;
  final String dimensionId;
  final String code;
  final String name;
  final ProvosSection section;
  final int displayOrder;
  final int? value;
  final DataStatus dataStatus;
  final String? sourceCellId;
  final String? notes;
}

final class ProvosMetric {
  const ProvosMetric({
    required this.dimensionId,
    required this.code,
    required this.name,
    required this.section,
    required this.displayOrder,
    required this.validTotal,
    required this.estimatedTotal,
    required this.validCount,
    required this.notReportedCount,
    required this.invalidSourceCount,
    required this.estimatedCount,
    required this.missingValueCount,
  });

  final String dimensionId;
  final String code;
  final String name;
  final ProvosSection section;
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

final class ProvosDashboardSnapshot {
  const ProvosDashboardSnapshot({
    required this.periodId,
    required this.pomdamId,
    required this.strengthMetrics,
    required this.personnelMetrics,
    required this.educationMetrics,
  });

  final String periodId;
  final String? pomdamId;
  final List<ProvosMetric> strengthMetrics;
  final List<ProvosMetric> personnelMetrics;
  final List<ProvosMetric> educationMetrics;

  List<ProvosMetric> get allMetrics => [
        ...strengthMetrics,
        ...personnelMetrics,
        ...educationMetrics,
      ];

  static ProvosDashboardSnapshot fromDataPoints({
    required String periodId,
    required String? pomdamId,
    required List<ProvosDataPoint> dataPoints,
  }) {
    final grouped = <String, _ProvosMetricAccumulator>{};

    for (final point in dataPoints) {
      final key = point.section.name + ':' + point.dimensionId;
      final accumulator = grouped.putIfAbsent(
        key,
        () => _ProvosMetricAccumulator(
          dimensionId: point.dimensionId,
          code: point.code,
          name: point.name,
          section: point.section,
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
        return a.displayOrder.compareTo(b.displayOrder);
      });

    List<ProvosMetric> forSection(ProvosSection section) {
      return metrics
          .where((metric) => metric.section == section)
          .toList(growable: false);
    }

    return ProvosDashboardSnapshot(
      periodId: periodId,
      pomdamId: pomdamId,
      strengthMetrics: forSection(ProvosSection.strength),
      personnelMetrics: forSection(ProvosSection.personnel),
      educationMetrics: forSection(ProvosSection.education),
    );
  }
}

final class _ProvosMetricAccumulator {
  _ProvosMetricAccumulator({
    required this.dimensionId,
    required this.code,
    required this.name,
    required this.section,
    required this.displayOrder,
  });

  final String dimensionId;
  final String code;
  final String name;
  final ProvosSection section;
  final int displayOrder;

  int validTotal = 0;
  int estimatedTotal = 0;
  int validCount = 0;
  int notReportedCount = 0;
  int invalidSourceCount = 0;
  int estimatedCount = 0;
  int missingValueCount = 0;

  void add(ProvosDataPoint point) {
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

  ProvosMetric toMetric() {
    return ProvosMetric(
      dimensionId: dimensionId,
      code: code,
      name: name,
      section: section,
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
