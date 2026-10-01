import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/reporting_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/reporting_repository.dart';

final class SupabaseReportingRepository implements ReportingRepository {
  const SupabaseReportingRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReportSummary>> getReportSummaries() async {
    try {
      final rows = await _client
          .from('report_audit_summary')
          .select(
            'report_type_code,report_type_name,period_id,period_label,report_year,source_reports,imported_source_reports,non_imported_source_reports,source_cell_count,fact_rows,pomdam_count,valid_rows,not_reported_rows,invalid_source_rows,estimated_rows,valid_null_value,nonvalid_with_value,null_source_cell,dangling_source_cell',
          )
          .order('report_type_code')
          .order('period_label');

      return [
        for (final row in rows)
          ReportSummary(
            reportTypeCode: row['report_type_code'] as String,
            reportTypeName: row['report_type_name'] as String,
            periodId: row['period_id'] as String,
            periodLabel: row['period_label'] as String,
            reportYear: (row['report_year'] as num?)?.toInt(),
            sourceReports: (row['source_reports'] as num).toInt(),
            importedSourceReports:
                (row['imported_source_reports'] as num).toInt(),
            nonImportedSourceReports:
                (row['non_imported_source_reports'] as num).toInt(),
            sourceCellCount: (row['source_cell_count'] as num).toInt(),
            factRows: (row['fact_rows'] as num).toInt(),
            pomdamCount: (row['pomdam_count'] as num).toInt(),
            validRows: (row['valid_rows'] as num).toInt(),
            notReportedRows: (row['not_reported_rows'] as num).toInt(),
            invalidSourceRows:
                (row['invalid_source_rows'] as num).toInt(),
            estimatedRows: (row['estimated_rows'] as num).toInt(),
            validNullValue: (row['valid_null_value'] as num).toInt(),
            nonvalidWithValue:
                (row['nonvalid_with_value'] as num).toInt(),
            nullSourceCell: (row['null_source_cell'] as num).toInt(),
            danglingSourceCell:
                (row['dangling_source_cell'] as num).toInt(),
          ),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca ringkasan laporan: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca ringkasan laporan dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<ReportProvenance>> getProvenance({
    required ReportSelection selection,
    int limit = 25,
  }) async {
    try {
      final typeRows = await _client
          .from('report_types')
          .select('id')
          .eq('code', selection.reportTypeCode)
          .limit(1);

      if (typeRows.isEmpty) {
        throw DataAccessException(
          'Report type ${selection.reportTypeCode} tidak ditemukan.',
        );
      }

      final reportTypeId = typeRows.first['id'] as String;

      final sourceReports = await _client
          .from('source_reports')
          .select(
            'id,workbook_name,sheet_name,source_sheet_index,import_status,period_resolution_status',
          )
          .eq('report_type_id', reportTypeId)
          .eq('period_id', selection.periodId)
          .eq('import_status', 'IMPORTED')
          .order('source_sheet_index')
          .order('source_sheet_index');

      if (sourceReports.isEmpty) {
        return const [];
      }

      final sourceReportMap = <String, Map<String, dynamic>>{
        for (final row in sourceReports)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      final provenanceRows = await _client
          .from('report_provenance')
          .select(
            'source_cell_id,source_report_id,cell_ref,row_number,column_letter,raw_value,formula_text,parsed_numeric,data_status,semantic_role,row_label,column_label',
          )
          .inFilter('source_report_id', sourceReportMap.keys.toList())
          .order('source_report_id')
          .order('row_number')
          .order('cell_ref')
          .limit(limit);

      return [
        for (final row in provenanceRows)
          _toProvenance(
            Map<String, dynamic>.from(row),
            sourceReportMap[row['source_report_id'] as String],
          ),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca provenance laporan: ${error.message}',
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Gagal membaca provenance laporan dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  ReportProvenance _toProvenance(
    Map<String, dynamic> row,
    Map<String, dynamic>? sourceReport,
  ) {
    if (sourceReport == null) {
      throw DataAccessException(
        'Source report ${row['source_report_id']} tidak ditemukan.',
      );
    }

    return ReportProvenance(
      sourceCellId: row['source_cell_id'] as String,
      sourceReportId: row['source_report_id'] as String,
      workbookName: sourceReport['workbook_name'] as String,
      sheetName: sourceReport['sheet_name'] as String,
      sourceSheetIndex:
          (sourceReport['source_sheet_index'] as num?)?.toInt(),
      cellRef: row['cell_ref'] as String,
      rowNumber: (row['row_number'] as num).toInt(),
      columnLetter: row['column_letter'] as String,
      rawValue: row['raw_value'] as String?,
      formulaText: row['formula_text'] as String?,
      parsedNumeric: (row['parsed_numeric'] as num?)?.toInt(),
      dataStatus: DataStatus.fromDatabase(row['data_status'] as String),
      semanticRole: row['semantic_role'] as String?,
      rowLabel: row['row_label'] as String?,
      columnLabel: row['column_label'] as String?,
      importStatus: sourceReport['import_status'] as String,
      periodResolutionStatus:
          sourceReport['period_resolution_status'] as String,
    );
  }
}
