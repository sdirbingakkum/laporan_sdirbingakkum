import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/report_input_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/report_input_repository.dart';
import 'supabase_reference_data_repository.dart';

final class SupabaseReportInputRepository implements ReportInputRepository {
  const SupabaseReportInputRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ReportInputCatalog> getCatalog() async {
    try {
      final reference = SupabaseReferenceDataRepository(_client);
      final common = await Future.wait<dynamic>([
        reference.getPomdams(),
        reference.getReportPeriods(),
        reference.getPersonnelCategories(),
        reference.getSimTypes(),
        reference.getAccidentTypes(),
        reference.getVictimOutcomes(),
        reference.getVehicleCategories(),
        reference.getMaterialDamageTypes(),
        reference.getEducationStatuses(),
        reference.getProvosStrengthMeasures(),
      ]);

      final gakkumRows = await _client
          .from('gakkum_activity_versions')
          .select(
            'id,activity_id,level,display_order,taxonomy_version,gakkum_activities!inner(code,canonical_name,active)',
          )
          .eq('taxonomy_version', 'CURRENT_2026')
          .eq('gakkum_activities.active', true)
          .order('display_order');

      final gakkum = <GakkumInputOption>[
        for (final row in gakkumRows)
          if (!_hasGakkumChild(gakkumRows, row['id'] as String))
            GakkumInputOption(
              versionId: row['id'] as String,
              code: ((row['gakkum_activities'] as Map)['code'] as String),
              name: ((row['gakkum_activities'] as Map)['canonical_name'] as String),
              displayOrder: (row['display_order'] as num).toInt(),
            ),
      ];

      final violationRows = await _client
          .from('violation_versions')
          .select(
            'id,violation_id,display_order,violations!inner(canonical_code,canonical_name,category,active)',
          )
          .eq('violations.active', true)
          .order('display_order');

      final violationById = <String, ViolationInputOption>{};
      for (final row in violationRows) {
        final violation = Map<String, dynamic>.from(row['violations'] as Map);
        final id = row['violation_id'] as String;
        violationById[id] ??= ViolationInputOption(
          versionId: row['id'] as String,
          code: violation['canonical_code'] as String,
          name: violation['canonical_name'] as String,
          category: violation['category'] as String,
          displayOrder: (row['display_order'] as num?)?.toInt() ?? 9999,
        );
      }

      final offenseRows = await _client
          .from('criminal_offense_versions')
          .select(
            'id,offense_id,source_number,display_order,criminal_offenses!inner(canonical_name,active)',
          )
          .eq('criminal_offenses.active', true)
          .order('display_order');

      final offenseById = <String, CriminalOffenseInputOption>{};
      for (final row in offenseRows) {
        final offense = Map<String, dynamic>.from(
          row['criminal_offenses'] as Map,
        );
        final id = row['offense_id'] as String;
        offenseById[id] ??= CriminalOffenseInputOption(
          versionId: row['id'] as String,
          sourceNumber: (row['source_number'] as num).toInt(),
          name: offense['canonical_name'] as String,
          displayOrder: (row['display_order'] as num).toInt(),
        );
      }

      gakkum.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      final violations = violationById.values.toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      final criminalOffenses = offenseById.values.toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      return ReportInputCatalog(
        pomdams: List<Pomdam>.from(common[0] as List<Pomdam>),
        periods: List<ReportPeriod>.from(common[1] as List<ReportPeriod>),
        personnelCategories:
            List<PersonnelCategory>.from(common[2] as List<PersonnelCategory>),
        simTypes: List<SimType>.from(common[3] as List<SimType>),
        accidentTypes: List<AccidentType>.from(common[4] as List<AccidentType>),
        victimOutcomes:
            List<VictimOutcome>.from(common[5] as List<VictimOutcome>),
        vehicleCategories:
            List<VehicleCategory>.from(common[6] as List<VehicleCategory>),
        materialDamageTypes:
            List<MaterialDamageType>.from(common[7] as List<MaterialDamageType>),
        educationStatuses:
            List<EducationStatus>.from(common[8] as List<EducationStatus>),
        provosStrengthMeasures:
            List<ProvosStrengthMeasure>.from(
          common[9] as List<ProvosStrengthMeasure>,
        ),
        gakkum: List.unmodifiable(gakkum),
        violations: List.unmodifiable(violations),
        criminalOffenses: List.unmodifiable(criminalOffenses),
      );
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal memuat struktur input laporan: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal memuat struktur input laporan dari Supabase.',
      );
    }
  }

  @override
  Future<ReportPeriod> createPeriod({
    required DateTime periodStart,
    required DateTime periodEnd,
    required String periodLabel,
    String periodType = 'MONTH',
  }) async {
    try {
      final row = await _client.rpc(
        'create_report_period',
        params: {
          'p_period_start': _dateOnly(periodStart),
          'p_period_end': _dateOnly(periodEnd),
          'p_period_label': periodLabel,
          'p_period_type': periodType,
        },
      );

      return ReportPeriod.fromMap(
        Map<String, dynamic>.from(row as Map),
      );
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membuat periode laporan: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membuat periode laporan.',
      );
    }
  }

  @override
  Future<ReportInputSubmission> submitReport({
    required String reportType,
    required String periodId,
    required String pomdamId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final row = await _client.rpc(
        'submit_report',
        params: {
          'p_report_type': reportType,
          'p_period_id': periodId,
          'p_pomdam_id': pomdamId,
          'p_payload': payload,
        },
      );

      return ReportInputSubmission.fromMap(
        Map<String, dynamic>.from(row as Map),
      );
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal menyimpan laporan: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal menyimpan laporan.',
      );
    }
  }

  bool _hasGakkumChild(List<dynamic> rows, String id) {
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final parent = row['parent_version_id'];
      if (parent == id) return true;
    }
    return false;
  }

  String _dateOnly(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-${month}-${day}';
  }
}
