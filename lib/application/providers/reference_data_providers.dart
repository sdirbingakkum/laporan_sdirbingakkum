import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/supabase_reference_data_repository.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/repositories/reference_data_repository.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final referenceDataRepositoryProvider =
    Provider<ReferenceDataRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (!config.isConfigured) {
    throw const AppConfigurationException(
      'Supabase belum dikonfigurasi. Berikan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi.',
    );
  }

  return SupabaseReferenceDataRepository(Supabase.instance.client);
});

final pomdamsProvider = FutureProvider<List<Pomdam>>((ref) async {
  return ref.watch(referenceDataRepositoryProvider).getPomdams();
});

final reportTypesProvider = FutureProvider<List<ReportType>>((ref) async {
  return ref.watch(referenceDataRepositoryProvider).getReportTypes();
});

final reportPeriodsProvider = FutureProvider<List<ReportPeriod>>((ref) async {
  return ref.watch(referenceDataRepositoryProvider).getReportPeriods();
});

final personnelCategoriesProvider =
    FutureProvider<List<PersonnelCategory>>((ref) async {
  return ref.watch(referenceDataRepositoryProvider).getPersonnelCategories();
});
