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

  Future<CommanderSourceFileContext> getSourceFileContext({
    required String domainCode,
    required String recordId,
  });

  Future<String> createSourceFileSignedUrl({
    required String bucketId,
    required String objectPath,
    int expiresIn = 300,
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
  Future<CommanderSourceFileContext> getSourceFileContext({
    required String domainCode,
    required String recordId,
  }) async {
    try {
      final response = await _client.rpc(
        'get_commander_source_file_context',
        params: <String, dynamic>{
          'p_domain_code': domainCode,
          'p_record_id': recordId,
        },
      );

      if (response is! Map) {
        throw const DataAccessException(
          'Source file context memiliki format respons yang tidak valid.',
        );
      }

      return CommanderSourceFileContext.fromMap(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const AuthorizationException(
          'Source file tidak dapat diakses untuk scope akun ini.',
        );
      }

      throw DataAccessException(
        'Gagal membaca source file context: ' + error.message,
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Source file context tidak dapat dibaca dari Supabase.',
      );
    }
  }

  @override
  Future<String> createSourceFileSignedUrl({
    required String bucketId,
    required String objectPath,
    int expiresIn = 300,
  }) async {
    if (bucketId.isEmpty || objectPath.isEmpty) {
      throw const DataAccessException(
        'Path workbook asli tidak tersedia.',
      );
    }

    try {
      return await _client.storage
          .from(bucketId)
          .createSignedUrl(objectPath, expiresIn);
    } on StorageException catch (error) {
      throw DataAccessException(
        'Gagal membuka workbook asli: ' + error.message,
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Workbook asli tidak dapat dibuka.',
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
