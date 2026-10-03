import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_entities.dart';

abstract interface class CommanderDashboardRepository {
  Future<CommanderDashboardSnapshot> getSnapshot({String? pomdamId});
}

final class SupabaseCommanderDashboardRepository
    implements CommanderDashboardRepository {
  const SupabaseCommanderDashboardRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<CommanderDashboardSnapshot> getSnapshot({String? pomdamId}) async {
    try {
      final response = await _client.rpc(
        'get_commander_cop_snapshot',
        params: <String, dynamic>{
          'p_pomdam_id': pomdamId,
        },
      );

      if (response is! Map) {
        throw const DataAccessException(
          'Commander snapshot memiliki format respons yang tidak valid.',
        );
      }

      return CommanderDashboardSnapshot.fromMap(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const AuthorizationException(
          'Akses Commander tidak diizinkan untuk scope yang diminta.',
        );
      }

      throw DataAccessException(
        'Gagal membaca Commander Dashboard: ' + error.message,
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const DataAccessException(
        'Gagal membaca Commander Dashboard dari Supabase. '
        'Periksa akses RPC/RLS dan status autentikasi.',
      );
    }
  }
}