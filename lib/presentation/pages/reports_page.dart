import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reporting_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reporting_entities.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String? _selectedType;
  String? _selectedPeriodId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportAuditSummaryProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Semantics(
          container: true,
          header: true,
          headingLevel: 2,
          child: Text(
            'Laporan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ringkasan laporan dibaca dari read model live Supabase, termasuk status fakta dan jejak provenance.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        state.when(
          loading: () => const _LoadingCard(),
          error: (error, stackTrace) => _MessageState(
            message: _errorMessage(error),
          ),
          data: (summaries) {
            if (summaries.isEmpty) {
              return const _MessageState(
                message: 'Belum ada laporan dengan fact data yang aktif.',
              );
            }

            final typeCodes = summaries.map((row) => row.reportTypeCode).toSet();
            final selectedType = _selectedType != null &&
                    typeCodes.contains(_selectedType)
                ? _selectedType!
                : summaries.first.reportTypeCode;

            final typeSummaries = summaries
                .where((row) => row.reportTypeCode == selectedType)
                .toList(growable: false);

            final periodIds =
                typeSummaries.map((row) => row.periodId).toSet();
            final selectedPeriod = _selectedPeriodId != null &&
                    periodIds.contains(_selectedPeriodId)
                ? _selectedPeriodId!
                : typeSummaries.first.periodId;

            final detail = typeSummaries.firstWhere(
              (row) => row.periodId == selectedPeriod,
            );

            final provenance = ref.watch(
              reportProvenanceProvider(
                ReportSelection(
                  reportTypeCode: detail.reportTypeCode,
                  periodId: detail.periodId,
                ),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectionCard(
                  summaries: summaries,
                  selectedType: selectedType,
                  selectedPeriodId: selectedPeriod,
                  onTypeChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedType = value;
                      _selectedPeriodId = null;
                    });
                  },
                  onPeriodChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedPeriodId = value);
                  },
                ),
                const SizedBox(height: 16),
                _SummaryCard(summary: detail),
                const SizedBox(height: 16),
                _SourceCard(
                  state: provenance,
                  summary: detail,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Data laporan belum dapat dibaca dari backend.';
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.summaries,
    required this.selectedType,
    required this.selectedPeriodId,
    required this.onTypeChanged,
    required this.onPeriodChanged,
  });

  final List<ReportSummary> summaries;
  final String selectedType;
  final String selectedPeriodId;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final types = <String, String>{
      for (final row in summaries) row.reportTypeCode: row.reportTypeName,
    };
    final periods = summaries
        .where((row) => row.reportTypeCode == selectedType)
        .toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis laporan',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final entry in types.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: onTypeChanged,
              ),
            ),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue: selectedPeriodId,
                decoration: const InputDecoration(
                  labelText: 'Periode',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final row in periods)
                    DropdownMenuItem(
                      value: row.periodId,
                      child: Text(row.periodLabel),
                    ),
                ],
                onChanged: onPeriodChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final integrityClean = summary.integrityIssueCount == 0;
    final statusText = summary.statusIssueRows == 0
        ? 'Tidak ada status non-valid.'
        : '${summary.statusIssueRows} baris berstatus non-valid.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.reportTypeName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              summary.periodLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(title: 'Fact rows', value: '${summary.factRows}'),
                _Metric(title: 'POMDAM', value: '${summary.pomdamCount}'),
                _Metric(title: 'VALID', value: '${summary.validRows}'),
                _Metric(
                  title: 'NOT_REPORTED',
                  value: '${summary.notReportedRows}',
                ),
                _Metric(
                  title: 'INVALID_SOURCE',
                  value: '${summary.invalidSourceRows}',
                ),
                _Metric(
                  title: 'ESTIMATED',
                  value: '${summary.estimatedRows}',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              integrityClean
                  ? 'Integritas: OK — tidak ada gap provenance atau status/value yang tidak konsisten.'
                  : 'Integritas: ${summary.integrityIssueCount} temuan yang perlu diperiksa.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: integrityClean
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(statusText),
            if (summary.nonImportedSourceReports > 0) ...[
              const SizedBox(height: 10),
              Text(
                '${summary.nonImportedSourceReports} source report non-imported ditemukan; hanya source yang IMPORTED yang dianggap sumber aktif.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.state,
    required this.summary,
  });

  final AsyncValue<List<ReportProvenance>> state;
  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: state.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text(_errorMessage(error)),
          data: (rows) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Source & provenance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${summary.importedSourceReports} source imported · ${summary.sourceCellCount} source cells',
                ),
                const SizedBox(height: 14),
                if (rows.isEmpty)
                  const Text('Belum ada provenance yang dapat ditampilkan.')
                else
                  for (final row in rows.take(12))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProvenanceRow(row: row),
                    ),
                if (rows.length > 12)
                  Text(
                    '+ ${rows.length - 12} provenance lainnya',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Provenance laporan belum dapat dibaca.';
  }
}

class _ProvenanceRow extends StatelessWidget {
  const _ProvenanceRow({required this.row});

  final ReportProvenance row;

  @override
  Widget build(BuildContext context) {
    final value = row.rawValue ?? row.parsedNumeric?.toString() ?? '—';
    final location = '${row.sheetName}!${row.cellRef}';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(row.workbookName),
          const SizedBox(height: 4),
          Text(
            '${row.dataStatus.name.toUpperCase()} · value=$value',
          ),
          if (row.rowLabel != null || row.columnLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${row.rowLabel ?? ''}${row.rowLabel != null && row.columnLabel != null ? ' · ' : ''}${row.columnLabel ?? ''}',
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 3),
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
            Text('Membaca ringkasan laporan…'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(message),
      ),
    );
  }
}
