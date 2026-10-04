import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reference_data_providers.dart';
import '../../application/providers/sim_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reference_entities.dart';
import '../widgets/report_filters.dart';
import '../../domain/entities/sim_entities.dart';
import '../widgets/analytics_ui.dart';

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

        final query = SimDashboardQuery(
          periodId: selectedPeriod.id,
          pomdamId: _selectedPomdamId,
        );
        final dashboard = ref.watch(simDashboardProvider(query));

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const AnalyticsPageHeader(
              title: 'SIM TNI',
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MonthlyPeriodSelector(
                  periods: periods,
                  selectedPeriodId: selectedPeriod.id,
                  onChanged: (value) {
                    setState(() => _selectedPeriodId = value);
                  },
                ),
                _PomdamFilter(
                  state: pomdamsState,
                  selectedValue: _selectedPomdamId,
                  onChanged: (value) {
                    setState(() => _selectedPomdamId = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            dashboard.when(
              loading: () => const _LoadingCard(),
              error: (error, stackTrace) =>
                  _MessageState(message: _errorMessage(error)),
              data: (snapshot) => _DashboardContent(snapshot: snapshot),
            ),
          ],
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Data SIM TNI belum dapat dibaca.';
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

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final SimDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.recordCount == 0) {
      return const _MessageState(
        message: 'Tidak ada data untuk kombinasi filter yang dipilih.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Total valid',
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
          title: 'Distribusi jenis SIM',
          child: VisualBarList(
            items: [
              for (final metric in snapshot.metrics)
                VisualBarItem(
                  label: metric.simDisplayName,
                  value: metric.validTotal.toDouble(),
                ),
            ],
            maxItems: 5,
          ),
        ),
        const SizedBox(height: 14),
        if (snapshot.invalidSourceCount > 0)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sebagian baris berstatus INVALID_SOURCE dan tidak dimasukkan '
                'ke Total valid.',
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
                  'Rincian jenis SIM',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                for (final metric in snapshot.metrics)
                  _SimRow(metric: metric),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SimRow extends StatelessWidget {
  const _SimRow({required this.metric});

  final SimMetric metric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              metric.simCode,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.simDisplayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  metric.sourceLabel ?? '—',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              metric.validTotal.toString(),
              textAlign: TextAlign.end,
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
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Membaca data SIM TNI…'),
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
