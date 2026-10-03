import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_commander_access_context_repository.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import 'reference_data_providers.dart';

final commanderAccessContextRepositoryProvider =
    Provider<CommanderAccessContextRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi.',
    );
  }

  return SupabaseCommanderAccessContextRepository(
    Supabase.instance.client,
  );
});

final commanderAccessContextProvider =
    FutureProvider<CommanderAccessContext>((ref) async {
  return ref
      .watch(commanderAccessContextRepositoryProvider)
      .getMyAccessContext();
});
