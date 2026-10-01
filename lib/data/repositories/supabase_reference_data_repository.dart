import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/reference_data_repository.dart';

final class SupabaseReferenceDataRepository
    implements ReferenceDataRepository {
  const SupabaseReferenceDataRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Pomdam>> getPomdams() async {
    final rows = await _select(
      table: 'pomdams',
      columns:
          'id,report_order,roman_numeral,roman_value,code,short_name,kodam_name,kodam_full_name,pomdam_full_name,active,valid_from,valid_to,created_at',
      orderBy: 'report_order',
    );
    return rows.map(Pomdam.fromMap).toList(growable: false);
  }

  @override
  Future<List<PomdamAlias>> getPomdamAliases() async {
    final rows = await _select(
      table: 'pomdam_aliases',
      columns:
          'id,pomdam_id,source_value,alias_type,source_period,notes,created_at',
      orderBy: 'source_value',
    );
    return rows.map(PomdamAlias.fromMap).toList(growable: false);
  }

  @override
  Future<List<ReportType>> getReportTypes() async {
    final rows = await _select(
      table: 'report_types',
      columns: 'id,code,name,description,active,created_at',
      orderBy: 'code',
    );
    return rows.map(ReportType.fromMap).toList(growable: false);
  }

  @override
  Future<List<ReportPeriod>> getReportPeriods() async {
    final rows = await _select(
      table: 'report_periods',
      columns:
          'id,period_type,period_start,period_end,period_label,report_year,fiscal_year,source_label,created_at',
      orderBy: 'period_start',
      ascending: false,
    );
    return rows.map(ReportPeriod.fromMap).toList(growable: false);
  }

  @override
  Future<List<PersonnelCategory>> getPersonnelCategories() async {
    final rows = await _select(
      table: 'personnel_categories',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(PersonnelCategory.fromMap).toList(growable: false);
  }

  @override
  Future<List<SimType>> getSimTypes() async {
    final rows = await _select(
      table: 'sim_types',
      columns:
          'id,code,display_name,source_label,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(SimType.fromMap).toList(growable: false);
  }

  @override
  Future<List<AccidentType>> getAccidentTypes() async {
    final rows = await _select(
      table: 'accident_types',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(AccidentType.fromMap).toList(growable: false);
  }

  @override
  Future<List<VictimOutcome>> getVictimOutcomes() async {
    final rows = await _select(
      table: 'victim_outcomes',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(VictimOutcome.fromMap).toList(growable: false);
  }

  @override
  Future<List<VehicleCategory>> getVehicleCategories() async {
    final rows = await _select(
      table: 'vehicle_categories',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(VehicleCategory.fromMap).toList(growable: false);
  }

  @override
  Future<List<MaterialDamageType>> getMaterialDamageTypes() async {
    final rows = await _select(
      table: 'material_damage_types',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(MaterialDamageType.fromMap).toList(growable: false);
  }

  @override
  Future<List<EducationStatus>> getEducationStatuses() async {
    final rows = await _select(
      table: 'education_statuses',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(EducationStatus.fromMap).toList(growable: false);
  }

  @override
  Future<List<ProvosStrengthMeasure>> getProvosStrengthMeasures() async {
    final rows = await _select(
      table: 'provos_strength_measures',
      columns: 'id,code,name,display_order,active,created_at',
      orderBy: 'display_order',
    );
    return rows.map(ProvosStrengthMeasure.fromMap).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _select({
    required String table,
    required String columns,
    required String orderBy,
    bool ascending = true,
  }) async {
    try {
      final response = await _client
          .from(table)
          .select(columns)
          .order(orderBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException {
      throw DataAccessException(
        'Gagal membaca data $table dari Supabase. Periksa akses Data API/RLS untuk client.',
      );
    } on Object {
      throw DataAccessException(
        'Gagal membaca data $table dari Supabase.',
      );
    }
  }
}
