import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/provos_providers.dart';
import '../../application/providers/reference_data_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/provos_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/report_filters.dart';
import '../widgets/visual_analytics.dart';

class ProvosPage extends ConsumerStatefulWidget {
  const ProvosPage({super.key});

  @override
  ConsumerState<ProvosPage> createState() => _ProvosPageState();
}

class _ProvosPageState extends ConsumerState<ProvosPage> {
  String? _selectedPeriodId;
  String? _selectedPomdamId;

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(provosPeriodsProvider);
    final pomdamsState = ref.watch(pomdamsProvider);

    return periodsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(
            message: 'Belum ada periode dengan data Provos.',
          );
        }

        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );

        final dashboard = ref.watch(
          provosDashboardProvider(
            ProvosDashboardQuery(
              periodId: selectedPeriod.id,
              pomdamId: _selectedPomdamId,
            ),
          ),
        );

        return VisualReportFrame(
          title: 'Provos',
          contentKey: selectedPeriod.id,
          accent: AppVisualPalettes.provos.primary,
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
    return 'Data Provos belum dapat dibaca.';
  }
}


class _DashboardVisual extends StatelessWidget {
  const _DashboardVisual({required this.snapshot});
  final ProvosDashboardSnapshot snapshot;
  @override
  Widget build(BuildContext context) {
    final palette = AppVisualPalettes.provos;
    final totalValidCount = snapshot.allMetrics.fold<int>(0, (sum, m) => sum + m.validCount);
    final totalNotReported = snapshot.allMetrics.fold<int>(0, (sum, m) => sum + m.notReportedCount);
    final totalEstimated = snapshot.allMetrics.fold<int>(0, (sum, m) => sum + m.estimatedCount);
    final totalInvalidSource = snapshot.allMetrics.fold<int>(0, (sum, m) => sum + m.invalidSourceCount);
    final totalMissingValue = snapshot.allMetrics.fold<int>(0, (sum, m) => sum + m.missingValueCount);
    final totalValidTotal = snapshot.allMetrics.fold<int>(0, (sum, m) => sum + m.validTotal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 20),
          child: AnimatedMetric(value: totalValidTotal, label: 'TOTAL', color: palette.primary, size: 62),
        ),
        VisualPanel(
          title: 'Distribusi terbesar',
          accent: palette.primary,
          child: AnimatedRankBarChart(
            items: [for (final metric in snapshot.allMetrics) VisualDatum(label: metric.name, value: metric.validTotal.toDouble())],
            palette: palette,
            height: 250,
            maxItems: 6,
          ),
        ),
        const SizedBox(height: 12),
        VisualPanel(
          title: 'Status data',
          accent: palette.primary,
          child: AnimatedStatusRing(
            valid: totalValidCount,
            attention: totalNotReported + totalEstimated,
            error: totalInvalidSource + totalMissingValue,
            palette: palette,
          ),
        ),
      ],
    );
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
