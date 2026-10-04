import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/laka_providers.dart';
import '../../application/providers/reference_data_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/laka_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../widgets/analytics_ui.dart';
import '../widgets/report_filters.dart';

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
      error: (error, stackTrace) => _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(message: 'Belum ada periode dengan data Laka Lalin.');
        }
        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );
        final dashboard = ref.watch(lakaDashboardProvider(LakaDashboardQuery(
          periodId: selectedPeriod.id,
          pomdamId: _selectedPomdamId,
        )));
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Laka Lalin',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Kejadian, personel, materiil, pangkat korban, dan akibat korban ditampilkan sebagai bagian terpisah. Status fakta dipertahankan.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
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
                  onChanged: (value) => setState(() => _selectedPomdamId = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            dashboard.when(
              loading: () => const _LoadingCard(),
              error: (error, stackTrace) => _MessageState(message: _errorMessage(error)),
              data: (snapshot) => _DashboardContent(snapshot: snapshot),
            ),
          ],
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Data Laka Lalin belum dapat dibaca.';
  }
}

class _PomdamFilter extends StatelessWidget {
  const _PomdamFilter({required this.state, required this.selectedValue, required this.onChanged});
  final AsyncValue<List<Pomdam>> state;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const SizedBox(width: 280, child: LinearProgressIndicator()),
      error: (error, stackTrace) => SizedBox(width: 280, child: Text('POMDAM tidak tersedia: $error')),
      data: (pomdams) => SizedBox(
        width: 280,
        child: DropdownButtonFormField<String?>(
          initialValue: selectedValue,
          decoration: const InputDecoration(labelText: 'POMDAM', border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Semua POMDAM')),
            for (final pomdam in pomdams)
              DropdownMenuItem<String?>(value: pomdam.id, child: Text('${pomdam.code} · ${pomdam.shortName}')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});
  final LakaDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveGrid(
          minWidth: 270,
          children: [
            _VisualSection(title: 'Kejadian', section: snapshot.accident),
            _VisualSection(title: 'Personel', section: snapshot.personnel),
            _VisualSection(title: 'Materiil', section: snapshot.material),
            _VisualSection(title: 'Pangkat korban', section: snapshot.victimRank),
            _VisualSection(title: 'Akibat korban', section: snapshot.victimOutcome),
          ],
        ),
        const SizedBox(height: 14),
        _SectionCard(title: 'Kejadian', section: snapshot.accident),
        const SizedBox(height: 16),
        _SectionCard(title: 'Personel', section: snapshot.personnel),
        const SizedBox(height: 16),
        _SectionCard(title: 'Materiil', section: snapshot.material, material: true),
        const SizedBox(height: 16),
        _SectionCard(title: 'Pangkat korban', section: snapshot.victimRank),
        const SizedBox(height: 16),
        _SectionCard(title: 'Akibat korban', section: snapshot.victimOutcome),
      ],
    );
  }
}

class _VisualSection extends StatelessWidget {
  const _VisualSection({
    required this.title,
    required this.section,
  });

  final String title;
  final LakaSectionSnapshot section;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSection(
      title: title,
      trailing: Text(
        section.validTotal.toString(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
      child: VisualBarList(
        items: [
          for (final metric in section.metrics)
            VisualBarItem(
              label: metric.secondaryName == null
                  ? metric.primaryName
                  : '${metric.primaryName} · ${metric.secondaryName}',
              value: metric.validTotal.toDouble(),
            ),
        ],
        maxItems: 5,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.section, this.material = false});
  final String title;
  final LakaSectionSnapshot section;
  final bool material;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            if (material)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Kombinasi kendaraan × jenis kerusakan ditampilkan per baris.', style: Theme.of(context).textTheme.bodySmall),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(title: 'Total valid', value: section.validTotal.toString()),
                _MetricCard(title: 'Valid records', value: section.validCount.toString()),
                _MetricCard(title: 'Tidak dilaporkan', value: section.notReportedCount.toString()),
                _MetricCard(title: 'Invalid source', value: section.invalidSourceCount.toString()),
                if (section.estimatedCount > 0) _MetricCard(title: 'Estimated', value: section.estimatedCount.toString()),
                if (section.missingValueCount > 0) _MetricCard(title: 'Nilai kosong', value: section.missingValueCount.toString()),
              ],
            ),
            const SizedBox(height: 14),
            if (section.invalidSourceCount > 0)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Sebagian baris berstatus INVALID_SOURCE dan tidak dimasukkan ke Total valid.'),
              ),
            for (final metric in section.metrics) _MetricRow(metric: metric),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});
  final LakaMetric metric;

  @override
  Widget build(BuildContext context) {
    final code = metric.secondaryCode == null
        ? metric.primaryCode
        : '${metric.primaryCode} · ${metric.secondaryCode}';
    final label = metric.secondaryName == null
        ? metric.primaryName
        : '${metric.primaryName} · ${metric.secondaryName}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(code, style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          SizedBox(width: 100, child: Text(metric.validTotal.toString(), textAlign: TextAlign.end)),
          if (metric.issueCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Chip(label: Text(metric.issueCount.toString()), visualDensity: VisualDensity.compact),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(title),
          ]),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Membaca data Laka Lalin…'),
          ]),
        ),
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(padding: const EdgeInsets.all(24), child: Text(message, textAlign: TextAlign.center)),
      );
}