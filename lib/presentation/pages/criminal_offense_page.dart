import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/criminal_offense_providers.dart';
import '../../application/providers/reference_data_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/criminal_offense_entities.dart';
import '../widgets/analytics_ui.dart';
import '../../domain/entities/reference_entities.dart';
import '../widgets/report_filters.dart';

class CriminalOffensePage extends ConsumerStatefulWidget {
  const CriminalOffensePage({super.key});

  @override
  ConsumerState<CriminalOffensePage> createState() =>
      _CriminalOffensePageState();
}

class _CriminalOffensePageState extends ConsumerState<CriminalOffensePage> {
  String? _selectedPeriodId;
  String? _selectedSourcePeriod;
  String? _selectedPomdamId;
  String? _selectedPersonnelCategoryId;

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(criminalOffensePeriodsProvider);
    final pomdamsState = ref.watch(pomdamsProvider);
    final personnelState = ref.watch(personnelCategoriesProvider);

    return periodsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(
            message: 'Belum ada periode dengan data Tindak Pidana.',
          );
        }

        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );

        final sourcePeriodsState = ref.watch(
          criminalOffenseSourcePeriodsProvider(selectedPeriod.id),
        );

        return sourcePeriodsState.when(
          loading: () => const _LoadingCard(
            message: 'Membaca sumber versi Tindak Pidana…',
          ),
          error: (error, stackTrace) =>
              _MessageState(message: _errorMessage(error)),
          data: (sourcePeriods) {
            if (sourcePeriods.isEmpty) {
              return const _MessageState(
                message: 'Belum ada sumber versi untuk periode ini.',
              );
            }

            final selectedSourcePeriod = sourcePeriods.firstWhere(
              (source) => source == _selectedSourcePeriod,
              orElse: () => sourcePeriods.first,
            );

            final dashboard = ref.watch(
              criminalOffenseDashboardProvider(
                CriminalOffenseDashboardQuery(
                  periodId: selectedPeriod.id,
                  sourcePeriod: selectedSourcePeriod,
                  pomdamId: _selectedPomdamId,
                  personnelCategoryId: _selectedPersonnelCategoryId,
                ),
              ),
            );

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const AnalyticsPageHeader(
                  title: 'Tindak Pidana',
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    MonthlyPeriodSelector(
                      periods: periods,
                      selectedPeriodId: selectedPeriod.id,
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriodId = value;
                          _selectedSourcePeriod = null;
                        });
                      },
                    ),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedSourcePeriod,
                        decoration: const InputDecoration(
                          labelText: 'Sumber versi',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final source in sourcePeriods)
                            DropdownMenuItem(
                              value: source,
                              child: Text(source),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedSourcePeriod = value);
                        },
                      ),
                    ),
                    _PomdamFilter(
                      state: pomdamsState,
                      selectedValue: _selectedPomdamId,
                      onChanged: (value) {
                        setState(() => _selectedPomdamId = value);
                      },
                    ),
                    _PersonnelFilter(
                      state: personnelState,
                      selectedValue: _selectedPersonnelCategoryId,
                      onChanged: (value) {
                        setState(() => _selectedPersonnelCategoryId = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                dashboard.when(
                  loading: () => const _LoadingCard(
                    message: 'Membaca data Tindak Pidana…',
                  ),
                  error: (error, stackTrace) =>
                      _MessageState(message: _errorMessage(error)),
                  data: (snapshot) => _DashboardContent(snapshot: snapshot),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Data Tindak Pidana belum dapat dibaca.';
  }
}

class _PomdamFilter extends StatelessWidget {
  const _PomdamFilter({
    required this.state,
    required this.selectedValue,
    required this.onChanged,
  });

  final AsyncValue<List<Pomdam>> state;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const SizedBox(
        width: 280,
        child: LinearProgressIndicator(),
      ),
      error: (error, stackTrace) => SizedBox(
        width: 280,
        child: Text('POMDAM tidak tersedia: $error'),
      ),
      data: (pomdams) => SizedBox(
        width: 280,
        child: DropdownButtonFormField<String?>(
          initialValue: selectedValue,
          decoration: const InputDecoration(
            labelText: 'POMDAM',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Semua POMDAM'),
            ),
            for (final pomdam in pomdams)
              DropdownMenuItem<String?>(
                value: pomdam.id,
                child: Text('${pomdam.code} · ${pomdam.shortName}'),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PersonnelFilter extends StatelessWidget {
  const _PersonnelFilter({
    required this.state,
    required this.selectedValue,
    required this.onChanged,
  });

  final AsyncValue<List<PersonnelCategory>> state;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const SizedBox(
        width: 260,
        child: LinearProgressIndicator(),
      ),
      error: (error, stackTrace) => SizedBox(
        width: 260,
        child: Text('Personel tidak tersedia: $error'),
      ),
      data: (categories) => SizedBox(
        width: 260,
        child: DropdownButtonFormField<String?>(
          initialValue: selectedValue,
          decoration: const InputDecoration(
            labelText: 'Personel',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Semua Personel'),
            ),
            for (final category in categories)
              DropdownMenuItem<String?>(
                value: category.id,
                child: Text('${category.code} · ${category.name}'),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final CriminalOffenseDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.recordCount == 0) {
      return const _MessageState(
        message: 'Tidak ada data untuk kombinasi filter yang dipilih.',
      );
    }

    final allValuesZero = snapshot.validCount > 0 && snapshot.validTotal == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Nilai valid',
              value: snapshot.validTotal.toString(),
            ),
            _MetricCard(
              title: 'Valid records',
              value: snapshot.validCount.toString(),
            ),
            _MetricCard(
              title: 'Tidak dilaporkan',
              value: snapshot.notReportedCount.toString(),
            ),
            _MetricCard(
              title: 'Invalid source',
              value: snapshot.invalidSourceCount.toString(),
            ),
            if (snapshot.estimatedCount > 0)
              _MetricCard(
                title: 'Estimated',
                value: snapshot.estimatedCount.toString(),
              ),
            if (snapshot.missingValueCount > 0)
              _MetricCard(
                title: 'Nilai kosong',
                value: snapshot.missingValueCount.toString(),
              ),
          ],
        ),
        const SizedBox(height: 14),
        AnalyticsSection(
          title: 'Tindak pidana terbanyak',
          trailing: Text(
            'Menampilkan 10 teratas',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          child: VisualBarList(
            items: [
              for (final metric in snapshot.metrics)
                VisualBarItem(
                  label: metric.canonicalName,
                  value: metric.validTotal.toDouble(),
                ),
            ],
            maxItems: 10,
          ),
        ),
        const SizedBox(height: 14),
        if (allValuesZero)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Fakta VALID ditemukan, tetapi seluruh nilai source yang '
                'tersimpan pada filter ini bernilai 0. Ini bukan berarti '
                'record-nya tidak ada.',
              ),
            ),
          ),
        if (allValuesZero) const SizedBox(height: 12),
        if (snapshot.invalidSourceCount > 0)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Baris berstatus INVALID_SOURCE tidak dimasukkan ke Nilai valid.',
              ),
            ),
          ),
        if (snapshot.invalidSourceCount > 0) const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rincian tindak pidana',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                for (final metric in snapshot.metrics)
                  _CriminalOffenseRow(metric: metric),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CriminalOffenseRow extends StatelessWidget {
  const _CriminalOffenseRow({required this.metric});

  final CriminalOffenseMetric metric;

  @override
  Widget build(BuildContext context) {
    final canonicalLine =
        '${metric.canonicalKey} · ${metric.canonicalName}';
    final sourceLine = '#${metric.sourceNumber} · ${metric.sourceLabel}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              sourceLine,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canonicalLine,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Sumber versi: ${metric.sourcePeriod ?? '—'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  metric.validTotal.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${metric.validCount} valid',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (metric.issueCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Chip(
                label: Text(metric.issueCount.toString()),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
