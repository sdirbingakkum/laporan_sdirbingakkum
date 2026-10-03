import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_commander_dashboard_repository.dart';
import '../../domain/entities/commander_entities.dart';
import 'reference_data_providers.dart';

final commanderDashboardRepositoryProvider =
    Provider<CommanderDashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi.',
    );
  }

  return SupabaseCommanderDashboardRepository(
    Supabase.instance.client,
  );
});

final commanderDashboardProvider = FutureProvider.autoDispose.family<
    CommanderDashboardSnapshot, CommanderDashboardQuery>((ref, query) async {
  return ref
      .watch(commanderDashboardRepositoryProvider)
      .getSnapshot(pomdamId: query.pomdamId);
});

final class CommanderDashboardQuery {
  const CommanderDashboardQuery({this.pomdamId});

  final String? pomdamId;

  @override
  bool operator ==(Object other) {
    return other is CommanderDashboardQuery && other.pomdamId == pomdamId;
  }

  @override
  int get hashCode => pomdamId.hashCode;
}
