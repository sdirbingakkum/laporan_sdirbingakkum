import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reference_data_providers.dart';
import '../../domain/entities/reference_entities.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportTypes = ref.watch(reportTypesProvider);
    final periods = ref.watch(reportPeriodsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Metadata laporan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;

            final typesCard = _ReportTypesCard(state: reportTypes);
            final periodsCard = _PeriodsCard(state: periods);

            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: typesCard),
                  const SizedBox(width: 16),
                  Expanded(child: periodsCard),
                ],
              );
            }

            return Column(
              children: [
                typesCard,
                const SizedBox(height: 16),
                periodsCard,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReportTypesCard extends StatelessWidget {
  const _ReportTypesCard({required this.state});

  final AsyncValue<List<ReportType>> state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: state.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text(error.toString()),
          data: (rows) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jenis laporan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final row in rows)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(row.name),
                  subtitle: Text(row.code),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodsCard extends StatelessWidget {
  const _PeriodsCard({required this.state});

  final AsyncValue<List<ReportPeriod>> state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: state.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text(error.toString()),
          data: (rows) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Periode tersedia',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final row in rows.take(12))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(row.periodLabel),
                  subtitle: Text(
                    '${row.periodType}${row.reportYear == null ? '' : ' · ${row.reportYear}'}',
                  ),
                ),
              if (rows.length > 12)
                Text(
                  '+ ${rows.length - 12} periode lainnya',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
