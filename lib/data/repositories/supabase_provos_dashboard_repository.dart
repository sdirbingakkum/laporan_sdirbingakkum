
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/provos_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/provos_dashboard_repository.dart';

final class SupabaseProvosDashboardRepository
    implements ProvosDashboardRepository {
  const SupabaseProvosDashboardRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReportPeriod>> getAvailablePeriods() async {
    try {
      final results = await Future.wait([
        _client.from('provos_strength_records').select('period_id'),
        _client.from('provos_personnel_records').select('period_id'),
        _client.from('provos_education_records').select('period_id'),
      ]);

      final periodIds = <String>{
        for (final response in results)
          for (final row in response)
            row['period_id'] as String,
      };

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
        'Gagal membaca periode Provos: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca periode Provos dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  @override
  Future<List<ProvosDataPoint>> getDataPoints({
    required String periodId,
    String? pomdamId,
  }) async {
    try {
      final results = await Future.wait([
        _getStrength(periodId, pomdamId),
        _getPersonnel(periodId, pomdamId),
        _getEducation(periodId, pomdamId),
      ]);

      return [
        ...results[0],
        ...results[1],
        ...results[2],
      ];
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca data Provos: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca data Provos dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    }
  }

  Future<List<ProvosDataPoint>> _getStrength(
    String periodId,
    String? pomdamId,
  ) async {
    final query = _client
        .from('provos_strength_records')
        .select(
          'id,period_id,pomdam_id,strength_measure_id,value,data_status,source_cell_id,notes',
        )
        .eq('period_id', periodId);

    final rows = pomdamId == null
        ? await query
        : await query.eq('pomdam_id', pomdamId);

    final references = await _client
        .from('provos_strength_measures')
        .select('id,code,name,display_order,active')
        .order('display_order');

    final map = <String, Map<String, dynamic>>{
      for (final row in references)
        row['id'] as String: Map<String, dynamic>.from(row),
    };

    return [
      for (final row in rows)
        _strengthPoint(Map<String, dynamic>.from(row), map),
    ];
  }

  Future<List<ProvosDataPoint>> _getPersonnel(
    String periodId,
    String? pomdamId,
  ) async {
    final query = _client
        .from('provos_personnel_records')
        .select(
          'id,period_id,pomdam_id,personnel_category_id,value,data_status,source_cell_id,notes',
        )
        .eq('period_id', periodId);

    final rows = pomdamId == null
        ? await query
        : await query.eq('pomdam_id', pomdamId);

    final references = await _client
        .from('personnel_categories')
        .select('id,code,name,display_order,active')
        .order('display_order');

    final map = <String, Map<String, dynamic>>{
      for (final row in references)
        row['id'] as String: Map<String, dynamic>.from(row),
    };

    return [
      for (final row in rows)
        _personnelPoint(Map<String, dynamic>.from(row), map),
    ];
  }

  Future<List<ProvosDataPoint>> _getEducation(
    String periodId,
    String? pomdamId,
  ) async {
    final query = _client
        .from('provos_education_records')
        .select(
          'id,period_id,pomdam_id,education_status_id,value,data_status,source_cell_id,notes',
        )
        .eq('period_id', periodId);

    final rows = pomdamId == null
        ? await query
        : await query.eq('pomdam_id', pomdamId);

    final references = await _client
        .from('education_statuses')
        .select('id,code,name,display_order,active')
        .order('display_order');

    final map = <String, Map<String, dynamic>>{
      for (final row in references)
        row['id'] as String: Map<String, dynamic>.from(row),
    };

    return [
      for (final row in rows)
        _educationPoint(Map<String, dynamic>.from(row), map),
    ];
  }

  ProvosDataPoint _strengthPoint(
    Map<String, dynamic> row,
    Map<String, Map<String, dynamic>> references,
  ) {
    final id = row['strength_measure_id'] as String;
    final reference = references[id];
    if (reference == null) {
      throw DataAccessException('Strength measure $id tidak ditemukan.');
    }

    return _point(
      row: row,
      dimensionId: id,
      code: reference['code'] as String,
      name: reference['name'] as String,
      displayOrder: (reference['display_order'] as num).toInt(),
      section: ProvosSection.strength,
    );
  }

  ProvosDataPoint _personnelPoint(
    Map<String, dynamic> row,
    Map<String, Map<String, dynamic>> references,
  ) {
    final id = row['personnel_category_id'] as String;
    final reference = references[id];
    if (reference == null) {
      throw DataAccessException('Personnel category $id tidak ditemukan.');
    }

    return _point(
      row: row,
      dimensionId: id,
      code: reference['code'] as String,
      name: reference['name'] as String,
      displayOrder: (reference['display_order'] as num).toInt(),
      section: ProvosSection.personnel,
    );
  }

  ProvosDataPoint _educationPoint(
    Map<String, dynamic> row,
    Map<String, Map<String, dynamic>> references,
  ) {
    final id = row['education_status_id'] as String;
    final reference = references[id];
    if (reference == null) {
      throw DataAccessException('Education status $id tidak ditemukan.');
    }

    return _point(
      row: row,
      dimensionId: id,
      code: reference['code'] as String,
      name: reference['name'] as String,
      displayOrder: (reference['display_order'] as num).toInt(),
      section: ProvosSection.education,
    );
  }

  ProvosDataPoint _point({
    required Map<String, dynamic> row,
    required String dimensionId,
    required String code,
    required String name,
    required int displayOrder,
    required ProvosSection section,
  }) {
    return ProvosDataPoint(
      recordId: row['id'] as String,
      periodId: row['period_id'] as String,
      pomdamId: row['pomdam_id'] as String,
      dimensionId: dimensionId,
      code: code,
      name: name,
      section: section,
      displayOrder: displayOrder,
      value: (row['value'] as num?)?.toInt(),
      dataStatus: DataStatus.fromDatabase(row['data_status'] as String),
      sourceCellId: row['source_cell_id'] as String?,
      notes: row['notes'] as String?,
    );
  }
}
