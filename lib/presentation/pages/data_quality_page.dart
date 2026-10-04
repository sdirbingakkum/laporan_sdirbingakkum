import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reporting_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reporting_entities.dart';

class DataQualityPage extends ConsumerWidget {
  const DataQualityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportAuditSummaryProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Semantics(
          container: true,
          header: true,
          headingLevel: 2,
          child: Text(
            'Kualitas data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Audit live terhadap fact, status, coverage POMDAM, source-cell, dan source report.',
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
                message: 'Belum ada fact data yang dapat diaudit.',
              );
            }

            final totals = _Totals.fromSummaries(summaries);
            final clean = totals.integrityIssues == 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusSummary(totals: totals, clean: clean),
                const SizedBox(height: 16),
                for (final summary in summaries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportQualityCard(summary: summary),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Audit data quality belum dapat dibaca dari backend.';
  }
}

final class _Totals {
  const _Totals({
    required this.reports,
    required this.factRows,
    required this.validRows,
    required this.notReportedRows,
    required this.invalidSourceRows,
    required this.estimatedRows,
    required this.sourceCells,
    required this.integrityIssues,
  });

  final int reports;
  final int factRows;
  final int validRows;
  final int notReportedRows;
  final int invalidSourceRows;
  final int estimatedRows;
  final int sourceCells;
  final int integrityIssues;

  factory _Totals.fromSummaries(List<ReportSummary> rows) {
    return _Totals(
      reports: rows.length,
      factRows: rows.fold(0, (sum, row) => sum + row.factRows),
      validRows: rows.fold(0, (sum, row) => sum + row.validRows),
      notReportedRows:
          rows.fold(0, (sum, row) => sum + row.notReportedRows),
      invalidSourceRows:
          rows.fold(0, (sum, row) => sum + row.invalidSourceRows),
      estimatedRows:
          rows.fold(0, (sum, row) => sum + row.estimatedRows),
      sourceCells:
          rows.fold(0, (sum, row) => sum + row.sourceCellCount),
      integrityIssues:
          rows.fold(0, (sum, row) => sum + row.integrityIssueCount),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({
    required this.totals,
    required this.clean,
  });

  final _Totals totals;
  final bool clean;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clean ? 'Audit integrity: OK' : 'Audit integrity: REVIEW',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: clean
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(title: 'Report periods', value: '${totals.reports}'),
                _Metric(title: 'Fact rows', value: '${totals.factRows}'),
                _Metric(title: 'VALID', value: '${totals.validRows}'),
                _Metric(
                  title: 'NOT_REPORTED',
                  value: '${totals.notReportedRows}',
                ),
                _Metric(
                  title: 'INVALID_SOURCE',
                  value: '${totals.invalidSourceRows}',
                ),
                _Metric(
                  title: 'ESTIMATED',
                  value: '${totals.estimatedRows}',
                ),
                _Metric(
                  title: 'Source cells',
                  value: '${totals.sourceCells}',
                ),
                _Metric(
                  title: 'Integrity issues',
                  value: '${totals.integrityIssues}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'VALID menyumbang nilai numerik. NOT_REPORTED dan INVALID_SOURCE tidak diperlakukan sebagai nol.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportQualityCard extends StatelessWidget {
  const _ReportQualityCard({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final importedFactRows = summary.factRows - summary.nullSourceCell;
    final provenanceOk = importedFactRows >= 0 &&
        summary.danglingSourceCell == 0 &&
        summary.sourceCellCount == importedFactRows;
    final applicationFactRows = summary.nullSourceCell;
    final sourceLabel = summary.importedSourceReports > 0
        ? (applicationFactRows > 0 ? 'MIXED SOURCE' : 'SOURCE OK')
        : (applicationFactRows == summary.factRows && summary.factRows > 0
            ? 'INPUT APLIKASI'
            : 'SOURCE REVIEW');
    final qualityOk = provenanceOk &&
        summary.validNullValue == 0 &&
        summary.nonvalidWithValue == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.reportTypeCode,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(summary.periodLabel),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    sourceLabel,
                  ),
                ),
                Chip(
                  label: Text(
                    provenanceOk ? 'PROVENANCE OK' : 'PROVENANCE REVIEW',
                  ),
                ),
                Chip(
                  label: Text(
                    qualityOk ? 'VALUE CONTRACT OK' : 'VALUE CONTRACT REVIEW',
                  ),
                ),
                if (summary.nonImportedSourceReports > 0)
                  Chip(
                    label: Text(
                      '${summary.nonImportedSourceReports} non-imported source',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Facts ${summary.factRows} · POMDAM ${summary.pomdamCount} · source cells ${summary.sourceCellCount}',
            ),
            Text(
              'VALID ${summary.validRows} · NOT_REPORTED ${summary.notReportedRows} · INVALID_SOURCE ${summary.invalidSourceRows} · ESTIMATED ${summary.estimatedRows}',
            ),
            if (summary.integrityIssueCount > 0)
              Text(
                'Integrity issues: ${summary.integrityIssueCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
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
      width: 150,
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
            Text('Membaca audit data terbaru…'),
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
