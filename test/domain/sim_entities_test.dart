import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/sim_entities.dart';

void main() {
  SimDataPoint point({
    required String id,
    required String typeId,
    required String code,
    required int order,
    int? value,
    DataStatus status = DataStatus.valid,
  }) {
    return SimDataPoint(
      recordId: id,
      periodId: 'period',
      pomdamId: 'pomdam',
      simTypeId: typeId,
      simCode: code,
      simDisplayName: code,
      sourceLabel: code,
      displayOrder: order,
      value: value,
      dataStatus: status,
      sourceCellId: null,
      notes: null,
    );
  }

  group('SimDashboardSnapshot', () {
    test('groups by SIM type and preserves display order', () {
      final snapshot = SimDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: null,
        dataPoints: [
          point(
            id: '2',
            typeId: 'bii',
            code: 'BII',
            order: 3,
            value: 20,
          ),
          point(
            id: '1',
            typeId: 'a',
            code: 'A',
            order: 1,
            value: 10,
          ),
          point(
            id: '3',
            typeId: 'a',
            code: 'A',
            order: 1,
            value: 5,
          ),
        ],
      );

      expect(snapshot.recordCount, 3);
      expect(snapshot.validTotal, 35);
      expect(snapshot.metrics.length, 2);
      expect(snapshot.metrics[0].simCode, 'A');
      expect(snapshot.metrics[0].validTotal, 15);
      expect(snapshot.metrics[1].simCode, 'BII');
      expect(snapshot.metrics[1].validTotal, 20);
    });

    test('keeps not reported and invalid source outside valid total', () {
      final snapshot = SimDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: null,
        dataPoints: [
          point(
            id: '1',
            typeId: 'a',
            code: 'A',
            order: 1,
            value: 10,
          ),
          point(
            id: '2',
            typeId: 'bi',
            code: 'BI',
            order: 2,
            value: null,
            status: DataStatus.notReported,
          ),
          point(
            id: '3',
            typeId: 'bii',
            code: 'BII',
            order: 3,
            value: 50,
            status: DataStatus.invalidSource,
          ),
          point(
            id: '4',
            typeId: 'c',
            code: 'C',
            order: 5,
            value: 0,
          ),
        ],
      );

      expect(snapshot.validTotal, 10);
      expect(snapshot.validCount, 2);
      expect(snapshot.notReportedCount, 1);
      expect(snapshot.invalidSourceCount, 1);
    });

    test('does not turn a missing valid value into zero silently', () {
      final snapshot = SimDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: null,
        dataPoints: [
          point(
            id: '1',
            typeId: 'a',
            code: 'A',
            order: 1,
            value: null,
          ),
        ],
      );

      expect(snapshot.validCount, 1);
      expect(snapshot.validTotal, 0);
      expect(snapshot.missingValueCount, 1);
    });

    test('keeps estimated values separate from valid total', () {
      final snapshot = SimDashboardSnapshot.fromDataPoints(
        periodId: 'period',
        pomdamId: null,
        dataPoints: [
          point(
            id: '1',
            typeId: 'a',
            code: 'A',
            order: 1,
            value: 10,
          ),
          point(
            id: '2',
            typeId: 'bi',
            code: 'BI',
            order: 2,
            value: 7,
            status: DataStatus.estimated,
          ),
        ],
      );

      expect(snapshot.validTotal, 10);
      expect(snapshot.estimatedTotal, 7);
      expect(snapshot.estimatedCount, 1);
    });
  });
}
