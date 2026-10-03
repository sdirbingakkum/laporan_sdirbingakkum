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

      final payload = Map<String, dynamic>.from(response as Map);

      return CommanderDashboardSnapshot.fromMap(payload);
    } on PostgrestException catch (error) {
      throw DataAccessException(
        'Gagal membaca Commander Dashboard: ${error.message}',
      );
    } on Object {
      throw const DataAccessException(
        'Gagal membaca Commander Dashboard dari Supabase. '
        'Periksa akses RPC/RLS dan status autentikasi.',
      );
    }
  }
}
