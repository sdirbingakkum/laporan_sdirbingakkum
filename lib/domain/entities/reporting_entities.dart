import 'reference_entities.dart';

final class ReportSummary {
  const ReportSummary({
    required this.reportTypeCode,
    required this.reportTypeName,
    required this.periodId,
    required this.periodLabel,
    required this.reportYear,
    required this.sourceReports,
    required this.importedSourceReports,
    required this.nonImportedSourceReports,
    required this.sourceCellCount,
    required this.factRows,
    required this.pomdamCount,
    required this.validRows,
    required this.notReportedRows,
    required this.invalidSourceRows,
    required this.estimatedRows,
    required this.validNullValue,
    required this.nonvalidWithValue,
    required this.nullSourceCell,
    required this.danglingSourceCell,
  });

  final String reportTypeCode;
  final String reportTypeName;
  final String periodId;
  final String periodLabel;
  final int? reportYear;
  final int sourceReports;
  final int importedSourceReports;
  final int nonImportedSourceReports;
  final int sourceCellCount;
  final int factRows;
  final int pomdamCount;
  final int validRows;
  final int notReportedRows;
  final int invalidSourceRows;
  final int estimatedRows;
  final int validNullValue;
  final int nonvalidWithValue;
  final int nullSourceCell;
  final int danglingSourceCell;

  int get statusIssueRows =>
      notReportedRows + invalidSourceRows + estimatedRows;

  int get integrityIssueCount =>
      validNullValue +
      nonvalidWithValue +
      nullSourceCell +
      danglingSourceCell;

  bool get hasUsableSource => importedSourceReports > 0;

  bool get isClean => integrityIssueCount == 0;
}

final class ReportSelection {
  const ReportSelection({
    required this.reportTypeCode,
    required this.periodId,
  });

  final String reportTypeCode;
  final String periodId;

  @override
  bool operator ==(Object other) =>
      other is ReportSelection &&
      other.reportTypeCode == reportTypeCode &&
      other.periodId == periodId;

  @override
  int get hashCode => Object.hash(reportTypeCode, periodId);
}

final class ReportProvenance {
  const ReportProvenance({
    required this.sourceCellId,
    required this.sourceReportId,
    required this.workbookName,
    required this.sheetName,
    required this.sourceSheetIndex,
    required this.cellRef,
    required this.rowNumber,
    required this.columnLetter,
    required this.rawValue,
    required this.formulaText,
    required this.parsedNumeric,
    required this.dataStatus,
    required this.semanticRole,
    required this.rowLabel,
    required this.columnLabel,
    required this.importStatus,
    required this.periodResolutionStatus,
  });

  final String sourceCellId;
  final String sourceReportId;
  final String workbookName;
  final String sheetName;
  final int? sourceSheetIndex;
  final String cellRef;
  final int rowNumber;
  final String columnLetter;
  final String? rawValue;
  final String? formulaText;
  final int? parsedNumeric;
  final DataStatus dataStatus;
  final String? semanticRole;
  final String? rowLabel;
  final String? columnLabel;
  final String importStatus;
  final String periodResolutionStatus;
}
