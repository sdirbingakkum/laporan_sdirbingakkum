import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/gakkum_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/gakkum_dashboard_repository.dart';

final class SupabaseGakkumDashboardRepository
    implements GakkumDashboardRepository {
  const SupabaseGakkumDashboardRepository(this._client);

  final SupabaseClient _client;

  static const _pageSize = 500;

  @override
  Future<List<GakkumDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  }) async {
    try {
      final recordRows = <Map<String, dynamic>>[];
      var offset = 0;

      while (true) {
        var recordsQuery = _client.from('gakkum_records').select(
              'id,period_id,pomdam_id,activity_version_id,value,data_status,source_cell_id,notes',
            );

        recordsQuery = recordsQuery.eq('period_id', periodId);

        if (pomdamId != null) {
          recordsQuery = recordsQuery.eq('pomdam_id', pomdamId);
        }

        final page = await recordsQuery
            .order('activity_version_id')
            .order('pomdam_id')
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
          .from('gakkum_activity_versions')
          .select(
            'id,activity_id,source_code,source_label,level,display_order,valid_from,valid_to,taxonomy_version,parent_version_id',
          )
          .order('display_order');

      final activityResponse = await _client
          .from('gakkum_activities')
          .select('id,code,canonical_name,active');

      final activities = <String, Map<String, dynamic>>{
        for (final row in activityResponse)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      final versions = <String, Map<String, dynamic>>{
        for (final row in versionResponse)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      return [
        for (final raw in recordRows) _toDataPoint(raw, versions, activities),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca data Gakkum: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca data Gakkum dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  GakkumDataPoint _toDataPoint(
    Map<String, dynamic> record,
    Map<String, Map<String, dynamic>> versions,
    Map<String, Map<String, dynamic>> activities,
  ) {
    final versionId = record['activity_version_id'] as String;
    final version = versions[versionId];

    if (version == null) {
      throw DataAccessException(
        'Activity version $versionId tidak ditemukan.',
      );
    }

    final activityId = version['activity_id'] as String;
    final activity = activities[activityId];

    if (activity == null) {
      throw DataAccessException(
        'Activity $activityId tidak ditemukan.',
      );
    }

    return GakkumDataPoint(
      recordId: record['id'] as String,
      periodId: record['period_id'] as String,
      pomdamId: record['pomdam_id'] as String,
      activityVersionId: versionId,
      activityCode: activity['code'] as String,
      activityName: activity['canonical_name'] as String,
      sourceLabel: version['source_label'] as String,
      level: (version['level'] as num).toInt(),
      displayOrder: (version['display_order'] as num).toInt(),
      taxonomyVersion: version['taxonomy_version'] as String,
      value: (record['value'] as num?)?.toInt(),
      dataStatus: DataStatus.fromDatabase(record['data_status'] as String),
      sourceCellId: record['source_cell_id'] as String?,
      notes: record['notes'] as String?,
    );
  }
}
