import 'package:flutter_test/flutter_test.dart';

import 'package:laporan_sdirbingakkum/domain/entities/reference_entities.dart';
import 'package:laporan_sdirbingakkum/domain/entities/reporting_entities.dart';

void main() {
  test('report summary exposes integrity and status semantics', () {
    const summary = ReportSummary(
      reportTypeCode: 'TEST',
      reportTypeName: 'Test',
      periodId: 'period',
      periodLabel: 'Juli 2026',
      reportYear: 2026,
      sourceReports: 1,
      importedSourceReports: 1,
      nonImportedSourceReports: 0,
      sourceCellCount: 10,
      factRows: 10,
      pomdamCount: 21,
      validRows: 8,
      notReportedRows: 1,
      invalidSourceRows: 1,
      estimatedRows: 0,
      validNullValue: 0,
      nonvalidWithValue: 0,
      nullSourceCell: 0,
      danglingSourceCell: 0,
    );

    expect(summary.statusIssueRows, 2);
    expect(summary.integrityIssueCount, 0);
    expect(summary.hasUsableSource, isTrue);
    expect(summary.isClean, isTrue);
  });

  test('report selection equality is stable', () {
    const a = ReportSelection(
      reportTypeCode: 'GAKKUM',
      periodId: 'period-1',
    );
    const b = ReportSelection(
      reportTypeCode: 'GAKKUM',
      periodId: 'period-1',
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('provenance preserves fact status without collapsing it', () {
    const row = ReportProvenance(
      sourceCellId: 'cell',
      sourceReportId: 'report',
      workbookName: 'book.xlsx',
      sheetName: 'AGU 26',
      sourceSheetIndex: 2,
      cellRef: 'K12',
      rowNumber: 12,
      columnLetter: 'K',
      rawValue: null,
      formulaText: null,
      parsedNumeric: null,
      dataStatus: DataStatus.notReported,
      semanticRole: 'fact',
      rowLabel: 'Contoh',
      columnLabel: 'Juli',
      importStatus: 'IMPORTED',
      periodResolutionStatus: 'RESOLVED',
    );

    expect(row.dataStatus, DataStatus.notReported);
    expect(row.rawValue, isNull);
    expect(row.parsedNumeric, isNull);
  });
}
