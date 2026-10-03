import 'package:flutter_test/flutter_test.dart';

import 'package:laporan_sdirbingakkum/domain/entities/commander_drilldown_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';

void main() {
  test('parses domain dimensions and fact records', () {
    final snapshot = CommanderDrilldownSnapshot.fromMap({
      'schema_version': 1,
      'domain': 'GAKKUM',
      'domain_name': 'GAKKUM',
      'scope': {
        'type': 'POMDAM',
        'pomdam_id': 'pomdam-a',
        'pomdam': {
          'id': 'pomdam-a',
          'code': 'IM',
          'short_name': 'Iskandar Muda',
          'full_name': 'Polisi Militer Kodam Iskandar Muda',
        },
      },
      'as_of': {
        'id': 'period-a',
        'label': 'September 2026',
        'start': '2026-09-01',
        'end': '2026-09-30',
      },
      'selected_dimension_code': 'PATROLI',
      'dimensions': [
        {
          'code': 'PATROLI',
          'name': 'Patroli Berkendaraan',
          'group': 'ACTIVITY',
          'fact_rows': 1,
          'valid_rows': 1,
          'not_reported_rows': 0,
          'invalid_source_rows': 0,
          'estimated_rows': 0,
          'valid_total': 146,
        },
      ],
      'records': [
        {
          'record_id': 'record-a',
          'pomdam_id': 'pomdam-a',
          'pomdam_code': 'IM',
          'pomdam_short_name': 'Iskandar Muda',
          'period_id': 'period-a',
          'period_label': 'September 2026',
          'dimension_code': 'PATROLI',
          'dimension_name': 'Patroli Berkendaraan',
          'dimension_group': 'ACTIVITY',
          'secondary_code': null,
          'secondary_name': null,
          'value': 146,
          'data_status': 'VALID',
          'source_cell_id': 'cell-a',
          'notes': null,
        },
      ],
    });

    expect(snapshot.domainCode, 'GAKKUM');
    expect(snapshot.scope.pomdamId, 'pomdam-a');
    expect(snapshot.dimensions.single.code, 'PATROLI');
    expect(snapshot.records.single.dataStatus, DataStatus.valid);
    expect(snapshot.records.single.hasSource, isTrue);
  });

  test('source trace parses workbook, sheet, and cell lineage', () {
    final trace = CommanderFactProvenance.fromMap({
      'record_id': 'record-a',
      'domain': 'GAKKUM',
      'pomdam': {
        'id': 'pomdam-a',
        'code': 'IM',
        'short_name': 'Iskandar Muda',
      },
      'period': {
        'id': 'period-a',
        'label': 'September 2026',
        'start': '2026-09-01',
        'end': '2026-09-30',
      },
      'source': {
        'status': 'FOUND',
        'source_cell_id': 'cell-a',
        'source_report_id': 'report-a',
        'workbook': {
          'id': 'report-a',
          'name': 'statistik.xlsx',
          'sheet': 'SEP 26',
          'sheet_index': 1,
          'import_status': 'IMPORTED',
          'sheet_state': 'visible',
          'sheet_role': 'DATA',
          'period_resolution_status': 'RESOLVED',
        },
        'cell': {
          'ref': 'C9',
          'row_number': 9,
          'column_letter': 'C',
          'raw_value': '146',
          'formula_text': '=A1',
          'parsed_numeric': 146,
          'data_status': 'VALID',
          'semantic_role': 'FACT',
          'row_label': 'Patroli Berkendaraan',
          'column_label': 'IM',
        },
      },
    });

    expect(trace.source.found, isTrue);
    expect(trace.source.workbook!.name, 'statistik.xlsx');
    expect(trace.source.workbook!.sheet, 'SEP 26');
    expect(trace.source.cell!.ref, 'C9');
    expect(trace.source.cell!.parsedNumeric, 146);
  });

  test('missing source is represented without guessing', () {
    final trace = CommanderFactProvenance.fromMap({
      'record_id': 'record-b',
      'domain': 'SIM_TNI',
      'pomdam': {
        'id': 'pomdam-a',
        'code': 'IM',
        'short_name': 'Iskandar Muda',
      },
      'period': {
        'id': 'period-b',
        'label': 'July 2026',
      },
      'source': {
        'status': 'NO_SOURCE_CELL',
        'source_cell_id': null,
        'source_report_id': null,
      },
    });

    expect(trace.source.found, isFalse);
    expect(trace.source.cell, isNull);
    expect(trace.source.workbook, isNull);
  });
}
