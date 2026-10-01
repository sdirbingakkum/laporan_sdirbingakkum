import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/gakkum_providers.dart';
import '../../application/providers/reference_data_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/gakkum_entities.dart';

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
    final periodsState = ref.watch(reportPeriodsProvider);
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

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Giat Gakkum',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Periode, POMDAM, dan level taxonomy dipilih secara eksplisit. '
              'Parent dan child tidak dijumlahkan menjadi satu angka.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedPeriod.id,
                    decoration: const InputDecoration(
                      labelText: 'Periode',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final period in periods)
                        DropdownMenuItem(
                          value: period.id,
                          child: Text(period.periodLabel),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedPeriodId = value);
                    },
                  ),
                ),
                pomdamsState.when(
                  loading: () => const SizedBox(
                    width: 280,
                    child: LinearProgressIndicator(),
                  ),
                  error: (error, stackTrace) => SizedBox(
                    width: 280,
                    child: Text(
                      'POMDAM tidak tersedia: ' + error.toString(),
                    ),
                  ),
                  data: (pomdams) => SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String?>(
                      initialValue: _selectedPomdamId,
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
                            child: Text(
                              pomdam.code + ' · ' + pomdam.shortName,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPomdamId = value);
                      },
                    ),
                  ),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Level 1')),
                    ButtonSegment(value: 2, label: Text('Level 2')),
                  ],
                  selected: {_level},
                  onSelectionChanged: (value) {
                    setState(() => _level = value.first);
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
    return 'Data Gakkum belum dapat dibaca.';
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final GakkumDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
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
            if (snapshot.missingValueCount > 0)
              _MetricCard(
                title: 'Nilai kosong',
                value: snapshot.missingValueCount.toString(),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Rincian aktivitas',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    Text(
                      snapshot.taxonomyVersion,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final activity in snapshot.activities)
                  _ActivityRow(activity: activity),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final GakkumActivityMetric activity;

  @override
  Widget build(BuildContext context) {
    final issueCount = activity.notReportedCount +
        activity.invalidSourceCount +
        activity.estimatedCount +
        activity.missingValueCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(activity.displayOrder.toString()),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.activityName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  activity.sourceLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              activity.validTotal.toString(),
              textAlign: TextAlign.end,
            ),
          ),
          if (issueCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Chip(
                label: Text(issueCount.toString()),
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
      width: 200,
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
            Text('Membaca data Gakkum…'),
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
