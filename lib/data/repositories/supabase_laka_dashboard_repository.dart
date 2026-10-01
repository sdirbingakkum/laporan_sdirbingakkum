import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/laka_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/laka_dashboard_repository.dart';

final class SupabaseLakaDashboardRepository
    implements LakaDashboardRepository {
  const SupabaseLakaDashboardRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReportPeriod>> getAvailablePeriods() async {
    try {
      final results = await Future.wait([
        _client.from('laka_accident_records').select('period_id'),
        _client.from('laka_personnel_records').select('period_id'),
        _client.from('laka_material_records').select('period_id'),
        _client.from('laka_victim_rank_records').select('period_id'),
        _client.from('laka_victim_outcome_records').select('period_id'),
      ]);
      final periodIds = <String>{
        for (final response in results)
          for (final row in response)
            row['period_id'] as String,
      };
      if (periodIds.isEmpty) return const [];

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
        'Gagal membaca periode Laka Lalin: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca periode Laka Lalin dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<LakaDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  }) async {
    try {
      final results = await Future.wait([
        _getAccident(periodId, pomdamId),
        _getPersonnel(periodId, pomdamId),
        _getMaterial(periodId, pomdamId),
        _getVictimRank(periodId, pomdamId),
        _getVictimOutcome(periodId, pomdamId),
      ]);
      return [
        ...results[0],
        ...results[1],
        ...results[2],
        ...results[3],
        ...results[4],
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca data Laka Lalin: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca data Laka Lalin dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  Future<List<LakaDataPoint>> _getAccident(String periodId, String? pomdamId) async {
    final query = _client.from('laka_accident_records').select(
      'id,period_id,pomdam_id,accident_type_id,value,data_status,source_cell_id,notes',
    ).eq('period_id', periodId);
    final rows = pomdamId == null ? await query : await query.eq('pomdam_id', pomdamId);
    final refs = await _client.from('accident_types').select(
      'id,code,name,display_order,active',
    ).order('display_order');
    final map = {
      for (final row in refs) row['id'] as String: Map<String, dynamic>.from(row),
    };
    return [
      for (final row in rows)
        _point(
          row: Map<String, dynamic>.from(row),
          section: LakaSection.accident,
          primaryId: row['accident_type_id'] as String,
          primaryRef: map[row['accident_type_id'] as String],
        ),
    ];
  }

  Future<List<LakaDataPoint>> _getPersonnel(String periodId, String? pomdamId) async {
    final query = _client.from('laka_personnel_records').select(
      'id,period_id,pomdam_id,personnel_category_id,value,data_status,source_cell_id,notes',
    ).eq('period_id', periodId);
    final rows = pomdamId == null ? await query : await query.eq('pomdam_id', pomdamId);
    final refs = await _client.from('personnel_categories').select(
      'id,code,name,display_order,active',
    ).order('display_order');
    final map = {
      for (final row in refs) row['id'] as String: Map<String, dynamic>.from(row),
    };
    return [
      for (final row in rows)
        _point(
          row: Map<String, dynamic>.from(row),
          section: LakaSection.personnel,
          primaryId: row['personnel_category_id'] as String,
          primaryRef: map[row['personnel_category_id'] as String],
        ),
    ];
  }

  Future<List<LakaDataPoint>> _getMaterial(String periodId, String? pomdamId) async {
    final query = _client.from('laka_material_records').select(
      'id,period_id,pomdam_id,vehicle_category_id,material_damage_type_id,value,data_status,source_cell_id,notes',
    ).eq('period_id', periodId);
    final rows = pomdamId == null ? await query : await query.eq('pomdam_id', pomdamId);
    final refs = await Future.wait([
      _client.from('vehicle_categories').select('id,code,name,display_order,active').order('display_order'),
      _client.from('material_damage_types').select('id,code,name,display_order,active').order('display_order'),
    ]);
    final vehicles = {
      for (final row in refs[0]) row['id'] as String: Map<String, dynamic>.from(row),
    };
    final damages = {
      for (final row in refs[1]) row['id'] as String: Map<String, dynamic>.from(row),
    };
    final points = <LakaDataPoint>[];
    for (final row in rows) {
      final raw = Map<String, dynamic>.from(row);
      final vehicleId = raw['vehicle_category_id'] as String;
      final damageId = raw['material_damage_type_id'] as String;
      final vehicle = vehicles[vehicleId];
      final damage = damages[damageId];
      if (vehicle == null) {
        throw DataAccessException('Vehicle category $vehicleId tidak ditemukan.');
      }
      if (damage == null) {
        throw DataAccessException('Material damage type $damageId tidak ditemukan.');
      }
      points.add(_point(
        row: raw,
        section: LakaSection.material,
        primaryId: vehicleId,
        primaryRef: vehicle,
        secondaryId: damageId,
        secondaryRef: damage,
      ));
    }
    return points;
  }

  Future<List<LakaDataPoint>> _getVictimRank(String periodId, String? pomdamId) async {
    final query = _client.from('laka_victim_rank_records').select(
      'id,period_id,pomdam_id,personnel_category_id,value,data_status,source_cell_id,notes',
    ).eq('period_id', periodId);
    final rows = pomdamId == null ? await query : await query.eq('pomdam_id', pomdamId);
    final refs = await _client.from('personnel_categories').select(
      'id,code,name,display_order,active',
    ).order('display_order');
    final map = {
      for (final row in refs) row['id'] as String: Map<String, dynamic>.from(row),
    };
    return [
      for (final row in rows)
        _point(
          row: Map<String, dynamic>.from(row),
          section: LakaSection.victimRank,
          primaryId: row['personnel_category_id'] as String,
          primaryRef: map[row['personnel_category_id'] as String],
        ),
    ];
  }

  Future<List<LakaDataPoint>> _getVictimOutcome(String periodId, String? pomdamId) async {
    final query = _client.from('laka_victim_outcome_records').select(
      'id,period_id,pomdam_id,victim_outcome_id,value,data_status,source_cell_id,notes',
    ).eq('period_id', periodId);
    final rows = pomdamId == null ? await query : await query.eq('pomdam_id', pomdamId);
    final refs = await _client.from('victim_outcomes').select(
      'id,code,name,display_order,active',
    ).order('display_order');
    final map = {
      for (final row in refs) row['id'] as String: Map<String, dynamic>.from(row),
    };
    return [
      for (final row in rows)
        _point(
          row: Map<String, dynamic>.from(row),
          section: LakaSection.victimOutcome,
          primaryId: row['victim_outcome_id'] as String,
          primaryRef: map[row['victim_outcome_id'] as String],
        ),
    ];
  }

  LakaDataPoint _point({
    required Map<String, dynamic> row,
    required LakaSection section,
    required String primaryId,
    required Map<String, dynamic>? primaryRef,
    String? secondaryId,
    Map<String, dynamic>? secondaryRef,
  }) {
    if (primaryRef == null) {
      throw DataAccessException('Reference $primaryId tidak ditemukan.');
    }
    return LakaDataPoint(
      recordId: row['id'] as String,
      periodId: row['period_id'] as String,
      pomdamId: row['pomdam_id'] as String,
      section: section,
      primaryDimensionId: primaryId,
      secondaryDimensionId: secondaryId,
      primaryCode: primaryRef['code'] as String,
      primaryName: primaryRef['name'] as String,
      secondaryCode: secondaryRef?['code'] as String?,
      secondaryName: secondaryRef?['name'] as String?,
      displayOrder: (primaryRef['display_order'] as num).toInt(),
      value: (row['value'] as num?)?.toInt(),
      dataStatus: DataStatus.fromDatabase(row['data_status'] as String),
      sourceCellId: row['source_cell_id'] as String?,
      notes: row['notes'] as String?,
    );
  }
}