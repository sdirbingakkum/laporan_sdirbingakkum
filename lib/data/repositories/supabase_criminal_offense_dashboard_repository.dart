import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/criminal_offense_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/criminal_offense_dashboard_repository.dart';

final class SupabaseCriminalOffenseDashboardRepository
    implements CriminalOffenseDashboardRepository {
  const SupabaseCriminalOffenseDashboardRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReportPeriod>> getAvailablePeriods() async {
    try {
      final response = await _client
          .from('report_periods')
          .select(
            'id,period_type,period_start,period_end,period_label,report_year,fiscal_year,source_label,created_at,criminal_offense_records!inner(id)',
          )
          .order('period_start', ascending: false)
          .limit(1, referencedTable: 'criminal_offense_records');

      return [
        for (final row in response)
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
  Future<CriminalOffenseDashboardSnapshot> getDashboard({
    required String periodId,
    required String sourcePeriod,
    String? pomdamId,
    String? personnelCategoryId,
  }) async {
    try {
      final rows = await _client.rpc(
        'get_criminal_offense_dashboard',
        params: {
          'p_period_id': periodId,
          'p_source_period': sourcePeriod,
          'p_pomdam_id': pomdamId,
          'p_personnel_category_id': personnelCategoryId,
        },
      );

      final metrics = <CriminalOffenseMetric>[
        for (final raw in rows)
          _toMetric(Map<String, dynamic>.from(raw)),
      ];

      metrics.sort((a, b) {
        final order = a.displayOrder.compareTo(b.displayOrder);
        if (order != 0) return order;
        return a.sourceNumber.compareTo(b.sourceNumber);
      });

      var recordCount = 0;
      var validTotal = 0;
      var validCount = 0;
      var notReportedCount = 0;
      var invalidSourceCount = 0;
      var estimatedTotal = 0;
      var estimatedCount = 0;
      var missingValueCount = 0;

      for (final metric in metrics) {
        recordCount += metric.recordCount;
        validTotal += metric.validTotal;
        validCount += metric.validCount;
        notReportedCount += metric.notReportedCount;
        invalidSourceCount += metric.invalidSourceCount;
        estimatedTotal += metric.estimatedTotal;
        estimatedCount += metric.estimatedCount;
        missingValueCount += metric.missingValueCount;
      }

      return CriminalOffenseDashboardSnapshot(
        periodId: periodId,
        pomdamId: pomdamId,
        personnelCategoryId: personnelCategoryId,
        sourcePeriod: sourcePeriod,
        recordCount: recordCount,
        validTotal: validTotal,
        validCount: validCount,
        notReportedCount: notReportedCount,
        invalidSourceCount: invalidSourceCount,
        estimatedTotal: estimatedTotal,
        estimatedCount: estimatedCount,
        missingValueCount: missingValueCount,
        metrics: metrics,
      );
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

  CriminalOffenseMetric _toMetric(Map<String, dynamic> row) {
    return CriminalOffenseMetric(
      offenseVersionId: row['offense_version_id'] as String,
      offenseId: row['offense_id'] as String,
      canonicalKey: row['canonical_key'] as String,
      canonicalName: row['canonical_name'] as String,
      sourceNumber: (row['source_number'] as num).toInt(),
      sourceLabel: row['source_label'] as String,
      sourcePeriod: row['source_period'] as String?,
      displayOrder: (row['display_order'] as num).toInt(),
      validTotal: (row['valid_total'] as num).toInt(),
      validCount: (row['valid_count'] as num).toInt(),
      notReportedCount: (row['not_reported_count'] as num).toInt(),
      invalidSourceCount: (row['invalid_source_count'] as num).toInt(),
      estimatedTotal: (row['estimated_total'] as num).toInt(),
      estimatedCount: (row['estimated_count'] as num).toInt(),
      missingValueCount: (row['missing_value_count'] as num).toInt(),
    );
  }
}
