import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_drilldown_entities.dart';

abstract interface class CommanderDrilldownRepository {
  Future<CommanderDrilldownSnapshot> getDomain({
    required String domainCode,
    String? pomdamId,
    String? dimensionCode,
    int limit = 100,
  });

  Future<CommanderFactProvenance> getFactProvenance({
    required String domainCode,
    required String recordId,
  });

  Future<CommanderSourceSheetContext> getSourceSheetContext({
    required String domainCode,
    required String recordId,
    int rowRadius = 4,
  });
}

final class SupabaseCommanderDrilldownRepository
    implements CommanderDrilldownRepository {
  const SupabaseCommanderDrilldownRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<CommanderDrilldownSnapshot> getDomain({
    required String domainCode,
    String? pomdamId,
    String? dimensionCode,
    int limit = 100,
  }) async {
    try {
      final response = await _client.rpc(
        'get_commander_domain_drilldown',
        params: <String, dynamic>{
          'p_domain_code': domainCode,
          'p_pomdam_id': pomdamId,
          'p_dimension_code': dimensionCode,
          'p_limit': limit,
        },
      );

      if (response is! Map) {
        throw const DataAccessException(
          'Commander drill-down memiliki format respons yang tidak valid.',
        );
      }

      return CommanderDrilldownSnapshot.fromMap(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const AuthorizationException(
          'Akses Commander drill-down tidak diizinkan untuk scope yang diminta.',
        );
      }

      throw DataAccessException(
        'Gagal membaca Commander drill-down: ${error.message}',
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Commander drill-down tidak dapat dibaca dari Supabase.',
      );
    }
  }

  @override
  Future<CommanderFactProvenance> getFactProvenance({
    required String domainCode,
    required String recordId,
  }) async {
    try {
      final response = await _client.rpc(
        'get_commander_fact_provenance',
        params: <String, dynamic>{
          'p_domain_code': domainCode,
          'p_record_id': recordId,
        },
      );

      if (response is! Map) {
        throw const DataAccessException(
          'Fact provenance memiliki format respons yang tidak valid.',
        );
      }

      return CommanderFactProvenance.fromMap(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const AuthorizationException(
          'Fact provenance tidak dapat diakses untuk scope akun ini.',
        );
      }

      throw DataAccessException(
        'Gagal membaca fact provenance: ${error.message}',
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Fact provenance tidak dapat dibaca dari Supabase.',
      );
    }
  }
  @override
  Future<CommanderSourceSheetContext> getSourceSheetContext({
    required String domainCode,
    required String recordId,
    int rowRadius = 4,
  }) async {
    try {
      final response = await _client.rpc(
        'get_commander_source_sheet_context',
        params: <String, dynamic>{
          'p_domain_code': domainCode,
          'p_record_id': recordId,
          'p_row_radius': rowRadius,
        },
      );

      if (response is! Map) {
        throw const DataAccessException(
          'Source sheet context memiliki format respons yang tidak valid.',
        );
      }

      return CommanderSourceSheetContext.fromMap(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const AuthorizationException(
          'Source sheet context tidak dapat diakses untuk scope akun ini.',
        );
      }

      throw DataAccessException(
        'Gagal membaca source sheet context: ' + error.message,
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Source sheet context tidak dapat dibaca dari Supabase.',
      );
    }
  }

}
