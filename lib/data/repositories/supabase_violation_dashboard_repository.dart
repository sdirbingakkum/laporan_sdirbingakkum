import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/violation_entities.dart';
import '../../domain/repositories/violation_dashboard_repository.dart';

final class SupabaseViolationDashboardRepository
    implements ViolationDashboardRepository {
  const SupabaseViolationDashboardRepository(this._client);

  final SupabaseClient _client;

  static const _pageSize = 500;

  @override
  Future<List<ReportPeriod>> getAvailablePeriods() async {
    try {
      final response = await _client
          .from('report_periods')
          .select(
            'id,period_type,period_start,period_end,period_label,report_year,fiscal_year,source_label,created_at,violation_records!inner(id)',
          )
          .order('period_start', ascending: false)
          .limit(1, referencedTable: 'violation_records');

      return [
        for (final row in response)
          ReportPeriod.fromMap(Map<String, dynamic>.from(row)),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca periode Pelanggaran: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca periode Pelanggaran dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _client
          .from('violations')
          .select('category')
          .order('category');

      return response
          .map((row) => row['category'] as String)
          .toSet()
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca kategori Pelanggaran: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca kategori Pelanggaran dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<ViolationDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
    String? personnelCategoryId,
  }) async {
    try {
      final recordRows = <Map<String, dynamic>>[];
      var offset = 0;

      while (true) {
        var recordsQuery = _client.from('violation_records').select(
              'id,period_id,pomdam_id,violation_version_id,personnel_category_id,value,data_status,notes',
            );

        recordsQuery = recordsQuery.eq('period_id', periodId);

        if (pomdamId != null) {
          recordsQuery = recordsQuery.eq('pomdam_id', pomdamId);
        }

        if (personnelCategoryId != null) {
          recordsQuery = recordsQuery.eq(
            'personnel_category_id',
            personnelCategoryId,
          );
        }

        final page = await recordsQuery
            .order('violation_version_id')
            .order('pomdam_id')
            .order('personnel_category_id')
            .order('id')
            .range(offset, offset + _pageSize - 1);

        recordRows.addAll(
          page.map((row) => Map<String, dynamic>.from(row)),
        );

        if (page.length < _pageSize) {
          break;
        }

        offset += _pageSize;
      }

      final versionResponse = await _client
          .from('violation_versions')
          .select(
            'id,violation_id,source_code,source_label,source_period,display_order',
          )
          .order('display_order');

      final violationResponse = await _client
          .from('violations')
          .select('id,canonical_code,canonical_name,category,active');

      final violations = <String, Map<String, dynamic>>{
        for (final row in violationResponse)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      final versions = <String, Map<String, dynamic>>{
        for (final row in versionResponse)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      return [
        for (final raw in recordRows) _toDataPoint(raw, versions, violations),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca data Pelanggaran: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca data Pelanggaran dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  ViolationDataPoint _toDataPoint(
    Map<String, dynamic> record,
    Map<String, Map<String, dynamic>> versions,
    Map<String, Map<String, dynamic>> violations,
  ) {
    final versionId = record['violation_version_id'] as String;
    final version = versions[versionId];

    if (version == null) {
      throw DataAccessException(
        'Violation version $versionId tidak ditemukan.',
      );
    }

    final violationId = version['violation_id'] as String;
    final violation = violations[violationId];

    if (violation == null) {
      throw DataAccessException(
        'Violation $violationId tidak ditemukan.',
      );
    }

    return ViolationDataPoint(
      recordId: record['id'] as String,
      periodId: record['period_id'] as String,
      pomdamId: record['pomdam_id'] as String,
      violationVersionId: versionId,
      personnelCategoryId: record['personnel_category_id'] as String,
      violationId: violationId,
      canonicalCode: violation['canonical_code'] as String,
      canonicalName: violation['canonical_name'] as String,
      category: violation['category'] as String,
      sourceCode: version['source_code'] as String,
      sourceLabel: version['source_label'] as String,
      sourcePeriod: version['source_period'] as String?,
      displayOrder: (version['display_order'] as num?)?.toInt(),
      value: (record['value'] as num?)?.toInt(),
      dataStatus: DataStatus.fromDatabase(record['data_status'] as String),
      notes: record['notes'] as String?,
    );
  }
}
