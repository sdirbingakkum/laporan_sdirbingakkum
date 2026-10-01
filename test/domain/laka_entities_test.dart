import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/laka_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';

void main() {
  LakaDataPoint point({
    required String id,
    required LakaSection section,
    required String primaryId,
    required String primaryCode,
    required String primaryName,
    int order = 1,
    String? secondaryId,
    String? secondaryCode,
    String? secondaryName,
    int? value,
    DataStatus status = DataStatus.valid,
  }) => LakaDataPoint(
        recordId: id,
        periodId: 'period',
        pomdamId: 'pomdam',
        section: section,
        primaryDimensionId: primaryId,
        secondaryDimensionId: secondaryId,
        primaryCode: primaryCode,
        primaryName: primaryName,
        secondaryCode: secondaryCode,
        secondaryName: secondaryName,
        displayOrder: order,
        value: value,
        dataStatus: status,
        sourceCellId: null,
        notes: null,
      );

  test('keeps five Laka sections separate', () {
    final snapshot = LakaDashboardSnapshot.fromDataPoints(
      periodId: 'period',
      pomdamId: null,
      dataPoints: [
        point(id: 'a', section: LakaSection.accident, primaryId: 'a', primaryCode: 'GANDA', primaryName: 'Ganda', value: 10),
        point(id: 'p', section: LakaSection.personnel, primaryId: 'p', primaryCode: 'PA', primaryName: 'Perwira', value: 3),
        point(id: 'm', section: LakaSection.material, primaryId: 'v', primaryCode: 'RANDIS', primaryName: 'Kendaraan Dinas', secondaryId: 'rb', secondaryCode: 'RB', secondaryName: 'Rusak Berat', value: 2),
        point(id: 'r', section: LakaSection.victimRank, primaryId: 'r', primaryCode: 'BA', primaryName: 'Bintara', value: 1),
        point(id: 'o', section: LakaSection.victimOutcome, primaryId: 'o', primaryCode: 'MD', primaryName: 'Meninggal Dunia', value: 1),
      ],
    );
    expect(snapshot.accident.validTotal, 10);
    expect(snapshot.personnel.validTotal, 3);
    expect(snapshot.material.validTotal, 2);
    expect(snapshot.victimRank.validTotal, 1);
    expect(snapshot.victimOutcome.validTotal, 1);
    expect(snapshot.accident.metrics.single.section, LakaSection.accident);
    expect(snapshot.material.metrics.single.section, LakaSection.material);
  });

  test('keeps material vehicle and damage combinations separate', () {
    final snapshot = LakaDashboardSnapshot.fromDataPoints(
      periodId: 'period',
      pomdamId: null,
      dataPoints: [
        point(id: '1', section: LakaSection.material, primaryId: 'v', primaryCode: 'RANDIS', primaryName: 'Kendaraan Dinas', secondaryId: 'rb', secondaryCode: 'RB', secondaryName: 'Rusak Berat', value: 4),
        point(id: '2', section: LakaSection.material, primaryId: 'v', primaryCode: 'RANDIS', primaryName: 'Kendaraan Dinas', secondaryId: 'rr', secondaryCode: 'RR', secondaryName: 'Rusak Ringan', value: 6),
      ],
    );
    expect(snapshot.material.metrics.length, 2);
    expect(snapshot.material.validTotal, 10);
    expect(snapshot.material.metrics[0].secondaryCode, 'RB');
    expect(snapshot.material.metrics[1].secondaryCode, 'RR');
  });

  test('keeps source statuses outside valid totals', () {
    final snapshot = LakaDashboardSnapshot.fromDataPoints(
      periodId: 'period',
      pomdamId: null,
      dataPoints: [
        point(id: '1', section: LakaSection.accident, primaryId: 'a', primaryCode: 'GANDA', primaryName: 'Ganda', value: 5),
        point(id: '2', section: LakaSection.accident, primaryId: 't', primaryCode: 'TUNGGAL', primaryName: 'Tunggal', status: DataStatus.notReported),
        point(id: '3', section: LakaSection.accident, primaryId: 'l', primaryCode: 'TABRAK_LARI', primaryName: 'Tabrak Lari', value: 99, status: DataStatus.invalidSource),
      ],
    );
    expect(snapshot.accident.validTotal, 5);
    expect(snapshot.accident.validCount, 1);
    expect(snapshot.accident.notReportedCount, 1);
    expect(snapshot.accident.invalidSourceCount, 1);
  });
}