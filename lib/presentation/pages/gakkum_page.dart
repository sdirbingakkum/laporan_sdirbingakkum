import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/gakkum_providers.dart';
import '../../application/providers/reference_data_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/gakkum_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/report_filters.dart';
import '../widgets/visual_analytics.dart';

class GakkumPage extends ConsumerStatefulWidget {
  const GakkumPage({super.key});

  @override
  ConsumerState<GakkumPage> createState() => _GakkumPageState();
}

class _GakkumPageState extends ConsumerState<GakkumPage> {
  String? _selectedPeriodId;
  String? _selectedPomdamId;
  int _level = 1;

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(gakkumPeriodsProvider);
    final pomdamsState = ref.watch(pomdamsProvider);

    return periodsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(message: 'Belum ada periode laporan.');
        }

        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );

        final query = GakkumDashboardQuery(
          periodId: selectedPeriod.id,
          pomdamId: _selectedPomdamId,
          level: _level,
        );

        final dashboard = ref.watch(gakkumDashboardProvider(query));

        return VisualReportFrame(
          title: 'Gakkum',
          contentKey: selectedPeriod.id,
          accent: AppVisualPalettes.gakkum.primary,
          periodControl: CompactMonthlyPeriodSelector(
            periods: periods,
            selectedPeriodId: selectedPeriod.id,
            onChanged: (value) => setState(() => _selectedPeriodId = value),
          ),
          filters: [
            _PomdamFilter(
              state: pomdamsState,
              selectedValue: _selectedPomdamId,
              onChanged: (value) => setState(() => _selectedPomdamId = value),
            ),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 1, label: Text('Level 1')),
                ButtonSegment(value: 2, label: Text('Level 2')),
              ],
              selected: {_level},
              onSelectionChanged: (value) =>
                  setState(() => _level = value.first),
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
    return 'Data Gakkum belum dapat dibaca.';
  }
}

class _DashboardVisual extends StatelessWidget {
  const _DashboardVisual({required this.snapshot});

  final GakkumDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = AppVisualPalettes.gakkum;
    final ranked = [
      for (final activity in snapshot.activities)
        VisualDatum(
          label: activity.activityName,
          value: activity.validTotal.toDouble(),
        ),
    ];

    final totalReports = snapshot.validCount +
        snapshot.notReportedCount +
        snapshot.estimatedCount +
        snapshot.invalidSourceCount +
        snapshot.missingValueCount;
    final validPercent =
        totalReports == 0 ? 0.0 : (snapshot.validCount / totalReports * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: AnimatedMetric(
                  value: snapshot.validTotal,
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
          title: 'Distribusi Kegiatan',
          accent: palette.primary,
          child: AnimatedRankBarChart(
            items: ranked,
            palette: palette,
            height: 320,
            maxItems: 7,
          ),
        ),
        const SizedBox(height: 24),
        VisualPanel(
          title: 'Kualitas Data',
          accent: palette.primary,
          child: AnimatedStatusRing(
            valid: snapshot.validCount,
            attention: snapshot.notReportedCount + snapshot.estimatedCount,
            error: snapshot.invalidSourceCount + snapshot.missingValueCount,
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
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const SizedBox(
        width: 230,
        child: LinearProgressIndicator(),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (pomdams) => SizedBox(
        width: 230,
        child: DropdownButtonFormField<String?>(
          initialValue: selectedValue,
          decoration: const InputDecoration(
            labelText: 'POMDAM',
            isDense: true,
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

class _LoadingVisual extends StatelessWidget {
  const _LoadingVisual();

  @override
  Widget build(BuildContext context) {
    return const VisualPanel(
      child: SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(),
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
