import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_access_context_entities.dart';

abstract interface class CommanderAccessContextRepository {
  Future<CommanderAccessContext> getMyAccessContext();
}

final class SupabaseCommanderAccessContextRepository
    implements CommanderAccessContextRepository {
  const SupabaseCommanderAccessContextRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<CommanderAccessContext> getMyAccessContext() async {
    try {
      final response = await _client.rpc('get_my_access_context');

      if (response is! Map) {
        throw const DataAccessException(
          'Authorization context memiliki format respons yang tidak valid.',
        );
      }

      final context = CommanderAccessContext.fromMap(
        Map<String, dynamic>.from(response),
      );

      if (context.authenticated && !context.configured) {
        throw const AuthorizationException(
          'Akun belum memiliki authorization role yang aktif.',
        );
      }

      return context;
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const AuthorizationException(
          'Akses authorization context tidak diizinkan.',
        );
      }

      throw DataAccessException(
        'Gagal membaca authorization context: ' + error.message,
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Authorization context tidak dapat dibaca dari Supabase.',
      );
    }
  }
}
