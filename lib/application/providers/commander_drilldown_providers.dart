import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_commander_drilldown_repository.dart';
import '../../domain/entities/commander_drilldown_entities.dart';
import 'reference_data_providers.dart';

final commanderDrilldownRepositoryProvider =
    Provider<CommanderDrilldownRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi.',
    );
  }

  return SupabaseCommanderDrilldownRepository(
    Supabase.instance.client,
  );
});

final commanderDrilldownProvider = FutureProvider.autoDispose
    .family<CommanderDrilldownSnapshot, CommanderDrilldownQuery>(
  (ref, query) async {
    return ref.watch(commanderDrilldownRepositoryProvider).getDomain(
          domainCode: query.domainCode,
          pomdamId: query.pomdamId,
          dimensionCode: query.dimensionCode,
        );
  },
);

final commanderFactProvenanceProvider = FutureProvider.autoDispose
    .family<CommanderFactProvenance, CommanderFactProvenanceQuery>(
  (ref, query) async {
    return ref
        .watch(commanderDrilldownRepositoryProvider)
        .getFactProvenance(
          domainCode: query.domainCode,
          recordId: query.recordId,
        );
  },
);

final commanderSourceSheetContextProvider = FutureProvider.autoDispose
    .family<CommanderSourceSheetContext, CommanderSourceSheetContextQuery>(
  (ref, query) async {
    return ref
        .watch(commanderDrilldownRepositoryProvider)
        .getSourceSheetContext(
          domainCode: query.domainCode,
          recordId: query.recordId,
        );
  },
);

final commanderSourceFileContextProvider = FutureProvider.autoDispose
    .family<CommanderSourceFileContext, CommanderSourceFileContextQuery>(
  (ref, query) async {
    return ref
        .watch(commanderDrilldownRepositoryProvider)
        .getSourceFileContext(
          domainCode: query.domainCode,
          recordId: query.recordId,
        );
  },
);

final class CommanderSourceFileContextQuery {
  const CommanderSourceFileContextQuery({
    required this.domainCode,
    required this.recordId,
  });

  final String domainCode;
  final String recordId;

  @override
  bool operator ==(Object other) {
    return other is CommanderSourceFileContextQuery &&
        other.domainCode == domainCode &&
        other.recordId == recordId;
  }

  @override
  int get hashCode => Object.hash(domainCode, recordId);
}

final class CommanderSourceSheetContextQuery {
  const CommanderSourceSheetContextQuery({
    required this.domainCode,
    required this.recordId,
  });

  final String domainCode;
  final String recordId;

  @override
  bool operator ==(Object other) {
    return other is CommanderSourceSheetContextQuery &&
        other.domainCode == domainCode &&
        other.recordId == recordId;
  }

  @override
  int get hashCode => Object.hash(domainCode, recordId);
}

final class CommanderDrilldownQuery {
  const CommanderDrilldownQuery({
    required this.domainCode,
    this.pomdamId,
    this.dimensionCode,
  });

  final String domainCode;
  final String? pomdamId;
  final String? dimensionCode;

  @override
  bool operator ==(Object other) {
    return other is CommanderDrilldownQuery &&
        other.domainCode == domainCode &&
        other.pomdamId == pomdamId &&
        other.dimensionCode == dimensionCode;
  }

  @override
  int get hashCode =>
      Object.hash(domainCode, pomdamId, dimensionCode);
}

final class CommanderFactProvenanceQuery {
  const CommanderFactProvenanceQuery({
    required this.domainCode,
    required this.recordId,
  });

  final String domainCode;
  final String recordId;

  @override
  bool operator ==(Object other) {
    return other is CommanderFactProvenanceQuery &&
        other.domainCode == domainCode &&
        other.recordId == recordId;
  }

  @override
  int get hashCode => Object.hash(domainCode, recordId);
}
