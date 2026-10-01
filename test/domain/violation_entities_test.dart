import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/violation_entities.dart';

void main() {
  group('ViolationDashboardSnapshot', () {
    test('keeps category filtering explicit', () {
      final points = [
        ViolationDataPoint(
          recordId: '1',
          periodId: 'period',
          pomdamId: 'pomdam',
          violationVersionId: 'b1',
          personnelCategoryId: 'personnel',
          violationId: 'violation-b',
          canonicalCode: 'B1',
          canonicalName: 'B1',
          category: 'B',
          sourceCode: 'B1',
          sourceLabel: 'B1',
          sourcePeriod: 'CURRENT_2026',
          displayOrder: 1,
          value: 4,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
        ViolationDataPoint(
          recordId: '2',
          periodId: 'period',
          pomdamId: 'pomdam',
          violationVersionId: 'c1',
          personnelCategoryId: 'personnel',
          violationId: 'violation-c',
          canonicalCode: 'C1',
          canonicalName: 'C1',
          category: 'C',
          sourceCode: 'C1',
          sourceLabel: 'C1',
          sourcePeriod: 'CURRENT_2026',
          displayOrder: 1,
          value: 9,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
      ];

      final snapshot = ViolationDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        personnelCategoryId: 'personnel',
        category: 'B',
        dataPoints: points,
      );

      expect(snapshot.recordCount, 1);
      expect(snapshot.validTotal, 4);
      expect(snapshot.metrics.single.canonicalCode, 'B1');
    });

    test('does not merge separate versions of the same canonical violation', () {
      final points = [
        ViolationDataPoint(
          recordId: '1',
          periodId: 'period',
          pomdamId: 'pomdam',
          violationVersionId: 'historical-1',
          personnelCategoryId: 'personnel',
          violationId: 'b11',
          canonicalCode: 'B11',
          canonicalName: 'B11',
          category: 'B',
          sourceCode: 'B11',
          sourceLabel: 'B11 old',
          sourcePeriod: 'HISTORICAL',
          displayOrder: 11,
          value: 3,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
        ViolationDataPoint(
          recordId: '2',
          periodId: 'period',
          pomdamId: 'pomdam',
          violationVersionId: 'historical-2',
          personnelCategoryId: 'personnel',
          violationId: 'b11',
          canonicalCode: 'B11',
          canonicalName: 'B11',
          category: 'B',
          sourceCode: 'B11',
          sourceLabel: 'B11 newer source',
          sourcePeriod: 'HISTORICAL',
          displayOrder: 11,
          value: 5,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
      ];

      final snapshot = ViolationDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        personnelCategoryId: 'personnel',
        category: null,
        dataPoints: points,
      );

      expect(snapshot.metrics, hasLength(2));
      expect(
        snapshot.metrics.map((metric) => metric.violationVersionId),
        containsAll(['historical-1', 'historical-2']),
      );
      expect(snapshot.validTotal, 8);
    });

    test('keeps not reported separate from zero', () {
      final points = [
        ViolationDataPoint(
          recordId: '1',
          periodId: 'period',
          pomdamId: 'pomdam',
          violationVersionId: 'b1',
          personnelCategoryId: 'personnel',
          violationId: 'b1',
          canonicalCode: 'B1',
          canonicalName: 'B1',
          category: 'B',
          sourceCode: 'B1',
          sourceLabel: 'B1',
          sourcePeriod: 'CURRENT_2026',
          displayOrder: 1,
          value: null,
          dataStatus: DataStatus.notReported,
          notes: null,
        ),
        ViolationDataPoint(
          recordId: '2',
          periodId: 'period',
          pomdamId: 'pomdam',
          violationVersionId: 'b2',
          personnelCategoryId: 'personnel',
          violationId: 'b2',
          canonicalCode: 'B2',
          canonicalName: 'B2',
          category: 'B',
          sourceCode: 'B2',
          sourceLabel: 'B2',
          sourcePeriod: 'CURRENT_2026',
          displayOrder: 2,
          value: 0,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
      ];

      final snapshot = ViolationDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        personnelCategoryId: 'personnel',
        category: null,
        dataPoints: points,
      );

      expect(snapshot.validTotal, 0);
      expect(snapshot.validCount, 1);
      expect(snapshot.notReportedCount, 1);
    });

    test('preserves a missing valid value as missing', () {
      final point = ViolationDataPoint(
        recordId: '1',
        periodId: 'period',
        pomdamId: 'pomdam',
        violationVersionId: 'b1',
        personnelCategoryId: 'personnel',
        violationId: 'b1',
        canonicalCode: 'B1',
        canonicalName: 'B1',
        category: 'B',
        sourceCode: 'B1',
        sourceLabel: 'B1',
        sourcePeriod: 'CURRENT_2026',
        displayOrder: 1,
        value: null,
        dataStatus: DataStatus.valid,
        notes: null,
      );

      final snapshot = ViolationDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        personnelCategoryId: 'personnel',
        category: null,
        dataPoints: [point],
      );

      expect(snapshot.validCount, 1);
      expect(snapshot.validTotal, 0);
      expect(snapshot.missingValueCount, 1);
    });
  });
}
