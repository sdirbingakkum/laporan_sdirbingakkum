import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reference_data_providers.dart';
import '../../application/providers/sim_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/sim_entities.dart';
import '../widgets/report_filters.dart';
import '../widgets/visual_analytics.dart';

class SimTniPage extends ConsumerStatefulWidget {
  const SimTniPage({super.key});

  @override
  ConsumerState<SimTniPage> createState() => _SimTniPageState();
}

class _SimTniPageState extends ConsumerState<SimTniPage> {
  String? _selectedPeriodId;
  String? _selectedPomdamId;

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(simPeriodsProvider);
    final pomdamsState = ref.watch(pomdamsProvider);

    return periodsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(
            message: 'Belum ada periode dengan data SIM TNI.',
          );
        }

        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );

        final dashboard = ref.watch(
          simDashboardProvider(
            SimDashboardQuery(
              periodId: selectedPeriod.id,
              pomdamId: _selectedPomdamId,
            ),
          ),
        );

        return VisualReportFrame(
          title: 'SIM TNI',
          accent: AppVisualPalettes.simTni.primary,
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
    return 'Data SIM TNI belum dapat dibaca.';
  }
}

class _DashboardVisual extends StatelessWidget {
  const _DashboardVisual({required this.snapshot});

  final SimDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = AppVisualPalettes.simTni;

    final items = [
      for (final metric in snapshot.metrics)
        VisualDatum(
          label: metric.simDisplayName,
          value: metric.validTotal.toDouble(),
        ),
    ];

    return ResponsiveGridShim(
      children: [
        VisualPanel(
          title: 'Distribusi',
          accent: palette.primary,
          child: AnimatedDonutChart(
            items: items,
            palette: palette,
            centerValue: snapshot.validTotal,
            centerLabel: 'total',
            height: 285,
          ),
        ),
        VisualPanel(
          title: 'Kualitas',
          accent: palette.secondary,
          child: Row(
            children: [
              Expanded(
                child: AnimatedStatusRing(
                  valid: snapshot.validCount,
                  attention:
                      snapshot.notReportedCount + snapshot.estimatedCount,
                  error: snapshot.invalidSourceCount +
                      snapshot.missingValueCount,
                  palette: palette,
                ),
              ),
              Expanded(
                child: AnimatedMetric(
                  value: snapshot.validTotal,
                  label: 'SIM valid',
                  color: palette.primary,
                  size: 40,
                ),
              ),
            ],
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
                  child: Text('\${pomdam.code} · \${pomdam.shortName}'),
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

class ResponsiveGridShim extends StatelessWidget {
  const ResponsiveGridShim({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 800) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}
