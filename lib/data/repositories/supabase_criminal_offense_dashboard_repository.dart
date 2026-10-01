import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/criminal_offense_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/criminal_offense_dashboard_repository.dart';

final class SupabaseCriminalOffenseDashboardRepository
    implements CriminalOffenseDashboardRepository {
  const SupabaseCriminalOffenseDashboardRepository(this._client);

  final SupabaseClient _client;

  static const _pageSize = 500;

  @override
  Future<List<ReportPeriod>> getAvailablePeriods() async {
    try {
      final periodIds = <String>{};
      var offset = 0;

      while (true) {
        final page = await _client
            .from('criminal_offense_records')
            .select('period_id')
            .order('period_id')
            .range(offset, offset + _pageSize - 1);

        periodIds.addAll(
          page.map((row) => row['period_id'] as String),
        );

        if (page.length < _pageSize) {
          break;
        }
        offset += _pageSize;
      }

      if (periodIds.isEmpty) {
        return const [];
      }

      final periodRows = await _client
          .from('report_periods')
          .select(
            'id,period_type,period_start,period_end,period_label,report_year,fiscal_year,source_label,created_at',
          )
          .order('period_start', ascending: false);

      return [
        for (final row in periodRows)
          if (periodIds.contains(row['id']))
            ReportPeriod.fromMap(Map<String, dynamic>.from(row)),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca periode Tindak Pidana: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca periode Tindak Pidana dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<String>> getAvailableSourcePeriods({
    required String periodId,
  }) async {
    try {
      final rows = await _client
          .from('criminal_offense_versions')
          .select(
            'id,source_period,criminal_offense_records!inner(id)',
          )
          .eq('criminal_offense_records.period_id', periodId)
          .not('source_period', 'is', null)
          .order('source_period')
          .limit(1, referencedTable: 'criminal_offense_records');

      return rows
          .map((row) => row['source_period'] as String?)
          .whereType<String>()
          .toSet()
          .toList(growable: false)
        ..sort();
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca sumber versi Tindak Pidana: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca sumber versi Tindak Pidana dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<CriminalOffenseDataPoint>> getDataPoints({
    required String periodId,
    required String sourcePeriod,
    String? pomdamId,
    String? personnelCategoryId,
  }) async {
    try {
      final recordRows = <Map<String, dynamic>>[];
      var offset = 0;

      while (true) {
        var query = _client.from('criminal_offense_records').select(
              'id,period_id,pomdam_id,criminal_offense_version_id,personnel_category_id,value,data_status,source_cell_id,notes',
            );

        query = query.eq('period_id', periodId);

        if (pomdamId != null) {
          query = query.eq('pomdam_id', pomdamId);
        }

        if (personnelCategoryId != null) {
          query = query.eq('personnel_category_id', personnelCategoryId);
        }

        final page = await query
            .order('criminal_offense_version_id')
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

      if (recordRows.isEmpty) {
        return const [];
      }

      final versionIds = recordRows
          .map((row) => row['criminal_offense_version_id'] as String)
          .toSet()
          .toList(growable: false);

      final versionRows = await _client
          .from('criminal_offense_versions')
          .select(
            'id,offense_id,source_number,source_label,source_period,display_order',
          )
          .inFilter('id', versionIds);

      final versions = <String, Map<String, dynamic>>{
        for (final row in versionRows)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      final offenseIds = versions.values
          .map((version) => version['offense_id'] as String)
          .toSet()
          .toList(growable: false);

      final offenseRows = await _client
          .from('criminal_offenses')
          .select('id,canonical_key,canonical_name,active')
          .inFilter('id', offenseIds);

      final offenses = <String, Map<String, dynamic>>{
        for (final row in offenseRows)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      final points = <CriminalOffenseDataPoint>[];

      for (final record in recordRows) {
        final versionId = record['criminal_offense_version_id'] as String;
        final version = versions[versionId];

        if (version == null) {
          throw DataAccessException(
            'Criminal offense version $versionId tidak ditemukan.',
          );
        }

        if (version['source_period'] != sourcePeriod) {
          continue;
        }

        final offenseId = version['offense_id'] as String;
        final offense = offenses[offenseId];

        if (offense == null) {
          throw DataAccessException(
            'Criminal offense $offenseId tidak ditemukan.',
          );
        }

        points.add(
          CriminalOffenseDataPoint(
            recordId: record['id'] as String,
            periodId: record['period_id'] as String,
            pomdamId: record['pomdam_id'] as String,
            offenseVersionId: versionId,
            personnelCategoryId:
                record['personnel_category_id'] as String,
            offenseId: offenseId,
            canonicalKey: offense['canonical_key'] as String,
            canonicalName: offense['canonical_name'] as String,
            sourceNumber: (version['source_number'] as num).toInt(),
            sourceLabel: version['source_label'] as String,
            sourcePeriod: version['source_period'] as String?,
            displayOrder: (version['display_order'] as num).toInt(),
            value: (record['value'] as num?)?.toInt(),
            dataStatus: DataStatus.fromDatabase(
              record['data_status'] as String,
            ),
            sourceCellId: record['source_cell_id'] as String?,
            notes: record['notes'] as String?,
          ),
        );
      }

      return points;
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca data Tindak Pidana: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca data Tindak Pidana dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }
}
