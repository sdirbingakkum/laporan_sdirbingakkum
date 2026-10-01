import 'package:flutter_test/flutter_test.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';

void main() {
  group('DataStatus', () {
    test('parses all supported database statuses', () {
      expect(DataStatus.fromDatabase('VALID'), DataStatus.valid);
      expect(
        DataStatus.fromDatabase('NOT_REPORTED'),
        DataStatus.notReported,
      );
      expect(
        DataStatus.fromDatabase('INVALID_SOURCE'),
        DataStatus.invalidSource,
      );
      expect(
        DataStatus.fromDatabase('ESTIMATED'),
        DataStatus.estimated,
      );
    });

    test('rejects unknown status', () {
      expect(
        () => DataStatus.fromDatabase('UNKNOWN'),
        throwsFormatException,
      );
    });
  });
}
