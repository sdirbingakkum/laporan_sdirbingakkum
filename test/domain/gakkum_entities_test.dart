import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/gakkum_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';

void main() {
  group('GakkumDashboardSnapshot', () {
    test('does not combine parent and child levels', () {
      final points = [
        GakkumDataPoint(
          recordId: '1',
          periodId: 'period',
          pomdamId: 'pomdam',
          activityVersionId: 'parent',
          activityCode: 'PATROLI',
          activityName: 'Patroli',
          sourceLabel: 'Patroli',
          level: 0,
          displayOrder: 1,
          taxonomyVersion: 'CURRENT_2026',
          value: 100,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
        GakkumDataPoint(
          recordId: '2',
          periodId: 'period',
          pomdamId: 'pomdam',
          activityVersionId: 'child',
          activityCode: 'PATROLI_BERKENDARAAN',
          activityName: 'Patroli Berkendaraan',
          sourceLabel: 'Patroli Berkendaraan',
          level: 1,
          displayOrder: 2,
          taxonomyVersion: 'CURRENT_2026',
          value: 60,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
      ];

      final levelOne = GakkumDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        level: 1,
        dataPoints: points,
      );

      expect(levelOne.recordCount, 1);
      expect(levelOne.validTotal, 60);
      expect(
        levelOne.activities.single.activityCode,
        'PATROLI_BERKENDARAAN',
      );
    });

    test('keeps not reported separate from zero', () {
      final points = [
        GakkumDataPoint(
          recordId: '1',
          periodId: 'period',
          pomdamId: 'pomdam',
          activityVersionId: 'activity',
          activityCode: 'A',
          activityName: 'A',
          sourceLabel: 'A',
          level: 1,
          displayOrder: 1,
          taxonomyVersion: 'CURRENT_2026',
          value: null,
          dataStatus: DataStatus.notReported,
          notes: null,
        ),
        GakkumDataPoint(
          recordId: '2',
          periodId: 'period',
          pomdamId: 'pomdam',
          activityVersionId: 'B',
          activityCode: 'B',
          activityName: 'B',
          sourceLabel: 'B',
          level: 1,
          displayOrder: 2,
          taxonomyVersion: 'CURRENT_2026',
          value: 0,
          dataStatus: DataStatus.valid,
          notes: null,
        ),
      ];

      final snapshot = GakkumDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        level: 1,
        dataPoints: points,
      );

      expect(snapshot.validTotal, 0);
      expect(snapshot.validCount, 1);
      expect(snapshot.notReportedCount, 1);
    });

    test('does not turn a missing valid value into zero', () {
      final point = GakkumDataPoint(
        recordId: '1',
        periodId: 'period',
        pomdamId: 'pomdam',
        activityVersionId: 'activity',
        activityCode: 'A',
        activityName: 'A',
        sourceLabel: 'A',
        level: 1,
        displayOrder: 1,
        taxonomyVersion: 'CURRENT_2026',
        value: null,
        dataStatus: DataStatus.valid,
        notes: null,
      );

      final snapshot = GakkumDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: 'pomdam',
        level: 1,
        dataPoints: [point],
      );

      expect(snapshot.validCount, 1);
      expect(snapshot.validTotal, 0);
      expect(snapshot.missingValueCount, 1);
    });
  });
}
