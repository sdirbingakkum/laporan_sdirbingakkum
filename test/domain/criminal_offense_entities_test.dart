import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/criminal_offense_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';

void main() {
  CriminalOffenseDataPoint point({
    required String recordId,
    required String versionId,
    required String offenseId,
    required String canonicalName,
    required int sourceNumber,
    required String sourceLabel,
    required String sourcePeriod,
    required int displayOrder,
    int? value,
    DataStatus status = DataStatus.valid,
  }) {
    return CriminalOffenseDataPoint(
      recordId: recordId,
      periodId: 'period',
      pomdamId: 'pomdam',
      offenseVersionId: versionId,
      personnelCategoryId: 'personnel',
      offenseId: offenseId,
      canonicalKey: offenseId,
      canonicalName: canonicalName,
      sourceNumber: sourceNumber,
      sourceLabel: sourceLabel,
      sourcePeriod: sourcePeriod,
      displayOrder: displayOrder,
      value: value,
      dataStatus: status,
      sourceCellId: null,
      notes: null,
    );
  }

  group('CriminalOffenseDashboardSnapshot', () {
    test('keeps different source versions separate', () {
      final snapshot =
          CriminalOffenseDashboardSnapshot.fromDataPoints(
            periodId: 'period',
            pomdamId: null,
            personnelCategoryId: null,
            sourcePeriod: 'AUG_2026',
            dataPoints: [
              point(
                recordId: '1',
                versionId: 'version-a',
                offenseId: 'offense-1',
                canonicalName: 'Asusila',
                sourceNumber: 1,
                sourceLabel: 'Asusila',
                sourcePeriod: 'AUG_2026',
                displayOrder: 1,
                value: 0,
              ),
              point(
                recordId: '2',
                versionId: 'version-b',
                offenseId: 'offense-1',
                canonicalName: 'Asusila',
                sourceNumber: 1,
                sourceLabel: 'Asusila historis',
                sourcePeriod: 'HIST_2024_09',
                displayOrder: 1,
                value: 9,
              ),
            ],
          );

      expect(snapshot.metrics.length, 1);
      expect(snapshot.metrics.single.offenseVersionId, 'version-a');
      expect(snapshot.recordCount, 1);
      expect(snapshot.validTotal, 0);
    });

    test('keeps not reported outside valid totals', () {
      final snapshot =
          CriminalOffenseDashboardSnapshot.fromDataPoints(
            periodId: 'period',
            pomdamId: null,
            personnelCategoryId: null,
            sourcePeriod: 'AUG_2026',
            dataPoints: [
              point(
                recordId: '1',
                versionId: 'version-a',
                offenseId: 'offense-1',
                canonicalName: 'Asusila',
                sourceNumber: 1,
                sourceLabel: 'Asusila',
                sourcePeriod: 'AUG_2026',
                displayOrder: 1,
                value: 0,
              ),
              point(
                recordId: '2',
                versionId: 'version-b',
                offenseId: 'offense-2',
                canonicalName: 'Desersi',
                sourceNumber: 3,
                sourceLabel: 'Desersi',
                sourcePeriod: 'AUG_2026',
                displayOrder: 3,
                status: DataStatus.notReported,
              ),
            ],
          );

      expect(snapshot.validTotal, 0);
      expect(snapshot.validCount, 1);
      expect(snapshot.notReportedCount, 1);
    });

    test('tracks missing valid values separately from zero', () {
      final snapshot =
          CriminalOffenseDashboardSnapshot.fromDataPoints(
            periodId: 'period',
            pomdamId: null,
            personnelCategoryId: null,
            sourcePeriod: 'AUG_2026',
            dataPoints: [
              point(
                recordId: '1',
                versionId: 'version-a',
                offenseId: 'offense-1',
                canonicalName: 'Asusila',
                sourceNumber: 1,
                sourceLabel: 'Asusila',
                sourcePeriod: 'AUG_2026',
                displayOrder: 1,
                value: null,
              ),
            ],
          );

      expect(snapshot.validCount, 1);
      expect(snapshot.validTotal, 0);
      expect(snapshot.missingValueCount, 1);
    });
  });
}
