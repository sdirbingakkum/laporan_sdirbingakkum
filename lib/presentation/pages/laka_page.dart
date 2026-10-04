import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/laka_providers.dart';
import '../../application/providers/reference_data_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/laka_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/report_filters.dart';
import '../widgets/visual_analytics.dart';

class LakaPage extends ConsumerStatefulWidget {
  const LakaPage({super.key});

  @override
  ConsumerState<LakaPage> createState() => _LakaPageState();
}

class _LakaPageState extends ConsumerState<LakaPage> {
  String? _selectedPeriodId;
  String? _selectedPomdamId;

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(lakaPeriodsProvider);
    final pomdamsState = ref.watch(pomdamsProvider);

    return periodsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(
            message: 'Belum ada periode dengan data Laka Lalin.',
          );
        }

        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );

        final dashboard = ref.watch(
          lakaDashboardProvider(
            LakaDashboardQuery(
              periodId: selectedPeriod.id,
              pomdamId: _selectedPomdamId,
            ),
          ),
        );

        return VisualReportFrame(
          title: 'Laka Lalu Lintas',
          contentKey: selectedPeriod.id,
          accent: AppVisualPalettes.laka.primary,
          periodControl: CompactMonthlyPeriodSelector(
            periods: periods,
            selectedPeriodId: selectedPeriod.id,
            onChanged: (value) => setState(() => _selectedPeriodId = value),
          ),
          filters: [
            _PomdamFilter(
              state: pomdamsState,
              selectedValue: _selectedPomdamId,
              onChanged: (value) =>
                  setState(() => _selectedPomdamId = value),
            ),
          ],
          child: dashboard.when(
            loading: () => const _LoadingVisual(),
            error: (error, stackTrace) =>
                _MessageState(message: _errorMessage(error)),
            data: (snapshot) => _DashboardVisual(snapshot: snapshot),
          ),
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Data Laka Lalin belum dapat dibaca.';
  }
}

class _DashboardVisual extends StatelessWidget {
  const _DashboardVisual({required this.snapshot});

  final LakaDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = AppVisualPalettes.laka;
    final accident = _data(snapshot.accident);

    final valid = _valid(snapshot);
    final attention = _attention(snapshot);
    final error = _error(snapshot);
    final totalReports = valid + attention + error;
    final validPercent = totalReports == 0 ? 0.0 : (valid / totalReports * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: AnimatedMetric(
                  value: snapshot.accident.validTotal,
                  label: 'TOTAL',
                  color: palette.primary,
                ),
              ),
              Expanded(
                child: AnimatedMetric(
                  value: validPercent,
                  suffix: '%',
                  label: 'VALID',
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        VisualPanel(
          title: 'Kejadian',
          accent: palette.primary,
          child: AnimatedRankBarChart(
            items: accident,
            palette: palette,
            maxItems: 7,
            height: 320,
          ),
        ),
        const SizedBox(height: 24),
        VisualPanel(
          title: 'Kualitas Data',
          accent: palette.primary,
          child: AnimatedStatusRing(
            valid: valid,
            attention: attention,
            error: error,
            palette: palette,
          ),
        ),
      ],
    );
  }

  List<VisualDatum> _data(LakaSectionSnapshot section) => [
        for (final metric in section.metrics)
          VisualDatum(
            label: metric.secondaryName == null
                ? metric.primaryName
                : '${metric.primaryName} · ${metric.secondaryName}',
            value: metric.validTotal.toDouble(),
          ),
      ];

  int _valid(LakaDashboardSnapshot snapshot) =>
      snapshot.accident.validCount +
      snapshot.personnel.validCount +
      snapshot.material.validCount +
      snapshot.victimRank.validCount +
      snapshot.victimOutcome.validCount;

  int _attention(LakaDashboardSnapshot snapshot) =>
      snapshot.accident.notReportedCount +
      snapshot.personnel.notReportedCount +
      snapshot.material.notReportedCount +
      snapshot.victimRank.notReportedCount +
      snapshot.victimOutcome.notReportedCount +
      snapshot.accident.estimatedCount +
      snapshot.personnel.estimatedCount +
      snapshot.material.estimatedCount +
      snapshot.victimRank.estimatedCount +
      snapshot.victimOutcome.estimatedCount;

  int _error(LakaDashboardSnapshot snapshot) =>
      snapshot.accident.invalidSourceCount +
      snapshot.personnel.invalidSourceCount +
      snapshot.material.invalidSourceCount +
      snapshot.victimRank.invalidSourceCount +
      snapshot.victimOutcome.invalidSourceCount +
      snapshot.accident.missingValueCount +
      snapshot.personnel.missingValueCount +
      snapshot.material.missingValueCount +
      snapshot.victimRank.missingValueCount +
      snapshot.victimOutcome.missingValueCount;
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
  Widget build(BuildContext context) => state.when(
        loading: () => const SizedBox(
          width: 210,
          child: LinearProgressIndicator(),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (pomdams) => SizedBox(
          width: 210,
          child: DropdownButtonFormField<String?>(
            initialValue: selectedValue,
            decoration:
                const InputDecoration(labelText: 'POMDAM', isDense: true),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua POMDAM'),
              ),
              for (final pomdam in pomdams)
                DropdownMenuItem<String?>(
                  value: pomdam.id,
                  child: Text('${pomdam.code} - ${pomdam.shortName}'),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

class _LoadingVisual extends StatelessWidget {
  const _LoadingVisual();

  @override
  Widget build(BuildContext context) => const VisualPanel(
        child: SizedBox(
          height: 280,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
}
