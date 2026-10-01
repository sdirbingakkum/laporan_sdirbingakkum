import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/sim_entities.dart';
import '../../domain/repositories/sim_dashboard_repository.dart';

final class SupabaseSimDashboardRepository
    implements SimDashboardRepository {
  const SupabaseSimDashboardRepository(this._client);

  final SupabaseClient _client;

  static const _pageSize = 500;

  @override
  Future<List<ReportPeriod>> getAvailablePeriods() async {
    try {
      final simPeriodRows = await _client
          .from('sim_records')
          .select('period_id')
          .order('period_id');

      final periodIds = simPeriodRows
          .map((row) => row['period_id'] as String)
          .toSet();

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
        'Gagal membaca periode SIM TNI: $error',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca periode SIM TNI dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<SimDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  }) async {
    try {
      final recordRows = <Map<String, dynamic>>[];
      var offset = 0;

      while (true) {
        var recordsQuery = _client.from('sim_records').select(
              'id,period_id,pomdam_id,sim_type_id,value,data_status,source_cell_id,notes',
            );

        recordsQuery = recordsQuery.eq('period_id', periodId);

        if (pomdamId != null) {
          recordsQuery = recordsQuery.eq('pomdam_id', pomdamId);
        }

        final page = await recordsQuery
            .order('sim_type_id')
            .order('pomdam_id')
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

      final typeResponse = await _client
          .from('sim_types')
          .select(
            'id,code,display_name,source_label,display_order,active',
          )
          .order('display_order');

      final types = <String, Map<String, dynamic>>{
        for (final row in typeResponse)
          row['id'] as String: Map<String, dynamic>.from(row),
      };

      return [
        for (final raw in recordRows) _toDataPoint(raw, types),
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca data SIM TNI: $error',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca data SIM TNI dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  SimDataPoint _toDataPoint(
    Map<String, dynamic> record,
    Map<String, Map<String, dynamic>> types,
  ) {
    final typeId = record['sim_type_id'] as String;
    final type = types[typeId];

    if (type == null) {
      throw DataAccessException(
        'SIM type $typeId tidak ditemukan.',
      );
    }

    return SimDataPoint(
      recordId: record['id'] as String,
      periodId: record['period_id'] as String,
      pomdamId: record['pomdam_id'] as String,
      simTypeId: typeId,
      simCode: type['code'] as String,
      simDisplayName: type['display_name'] as String,
      sourceLabel: type['source_label'] as String?,
      displayOrder: (type['display_order'] as num).toInt(),
      value: (record['value'] as num?)?.toInt(),
      dataStatus: DataStatus.fromDatabase(record['data_status'] as String),
      sourceCellId: record['source_cell_id'] as String?,
      notes: record['notes'] as String?,
    );
  }
}
