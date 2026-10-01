
import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/provos_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';

void main() {
  ProvosDataPoint point({
    required String id,
    required String dimensionId,
    required String code,
    required String name,
    required ProvosSection section,
    required int order,
    int? value,
    DataStatus status = DataStatus.valid,
  }) {
    return ProvosDataPoint(
      recordId: id,
      periodId: 'period',
      pomdamId: 'pomdam',
      dimensionId: dimensionId,
      code: code,
      name: name,
      section: section,
      displayOrder: order,
      value: value,
      dataStatus: status,
      sourceCellId: null,
      notes: null,
    );
  }

  test('does not mix metrics from different Provos sections', () {
    final snapshot = ProvosDashboardSnapshot.fromDataPoints(
      periodId: 'period',
      pomdamId: null,
      dataPoints: [
        point(
          id: 'strength',
          dimensionId: 'dspp',
          code: 'DSPP',
          name: 'DSPP',
          section: ProvosSection.strength,
          order: 1,
          value: 100,
        ),
        point(
          id: 'personnel',
          dimensionId: 'pa',
          code: 'PA',
          name: 'Perwira',
          section: ProvosSection.personnel,
          order: 1,
          value: 20,
        ),
      ],
    );

    expect(snapshot.strengthMetrics.single.validTotal, 100);
    expect(snapshot.personnelMetrics.single.validTotal, 20);
    expect(snapshot.educationMetrics, isEmpty);
  });

  test('keeps not reported and invalid source out of valid totals', () {
    final snapshot = ProvosDashboardSnapshot.fromDataPoints(
      periodId: 'period',
      pomdamId: null,
      dataPoints: [
        point(
          id: '1',
          dimensionId: 'dspp',
          code: 'DSPP',
          name: 'DSPP',
          section: ProvosSection.strength,
          order: 1,
          value: 100,
        ),
        point(
          id: '2',
          dimensionId: 'nyata',
          code: 'NYATA',
          name: 'Nyata',
          section: ProvosSection.strength,
          order: 2,
          value: null,
          status: DataStatus.notReported,
        ),
        point(
          id: '3',
          dimensionId: 'su',
          code: 'SUDAH',
          name: 'Sudah',
          section: ProvosSection.education,
          order: 1,
          value: 10,
          status: DataStatus.invalidSource,
        ),
      ],
    );

    expect(snapshot.strengthMetrics.single.validTotal, 100);
    expect(snapshot.strengthMetrics.single.notReportedCount, 1);
    expect(snapshot.educationMetrics.single.validTotal, 0);
    expect(snapshot.educationMetrics.single.invalidSourceCount, 1);
  });

  test('does not turn a missing valid value into zero silently', () {
    final snapshot = ProvosDashboardSnapshot.fromDataPoints(
      periodId: 'period',
      pomdamId: null,
      dataPoints: [
        point(
          id: '1',
          dimensionId: 'pa',
          code: 'PA',
          name: 'Perwira',
          section: ProvosSection.personnel,
          order: 1,
          value: null,
        ),
      ],
    );

    expect(snapshot.personnelMetrics.single.validCount, 1);
    expect(snapshot.personnelMetrics.single.validTotal, 0);
    expect(snapshot.personnelMetrics.single.missingValueCount, 1);
  });
}
