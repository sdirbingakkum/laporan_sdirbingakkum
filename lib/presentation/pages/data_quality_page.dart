import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reporting_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reporting_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/visual_analytics.dart';

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
                const SizedBox(height: 24),
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
    final validPercent = totals.factRows == 0
        ? 0.0
        : (totals.validRows / totals.factRows * 100);
    final integrityLabel =
        clean ? 'Audit integrity: OK' : 'Audit integrity: REVIEW';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: VisualPanel(
        accent: AppTheme.success,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First visible text → becomes the Card group's accessible name (starting with Audit integrity...)
            Text(
              integrityLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: clean ? AppTheme.success : AppTheme.danger,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AnimatedMetric(
                    value: validPercent,
                    suffix: '%',
                    label: 'VALID',
                    color: AppTheme.success,
                    size: 56,
                  ),
                ),
                Expanded(
                  child: AnimatedMetric(
                    value: totals.factRows,
                    label: 'TOTAL FACTS',
                    color: AppTheme.brandDark,
                    size: 56,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stat row — visible for E2E getByText(/Fact rows/) assertion
            Wrap(
              spacing: 20,
              runSpacing: 4,
              children: [
                Text(
                  'Fact rows: ${totals.factRows}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Valid: ${totals.validRows}  ·  Not reported: ${totals.notReportedRows}',
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedStatusRing(
              valid: totals.validRows,
              attention: totals.notReportedRows + totals.estimatedRows,
              error: totals.invalidSourceRows + totals.integrityIssues,
              palette: VisualPalette(
                primary: AppTheme.success,
                secondary: AppTheme.warning,
                tertiary: AppTheme.danger,
                soft: AppTheme.border,
              ),
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
    final qualityOk = provenanceOk &&
        summary.validNullValue == 0 &&
        summary.nonvalidWithValue == 0;
    
    final hasIssues = summary.integrityIssueCount > 0 || !qualityOk;
    final statusColor = hasIssues ? AppTheme.danger : AppTheme.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.reportTypeCode,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  Text(
                    summary.periodLabel,
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${summary.validRows} valid',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (hasIssues)
                  Text(
                    '${summary.integrityIssueCount} issues',
                    style: TextStyle(color: AppTheme.danger),
                  ),
              ],
            ),
          ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(message),
      ),
    );
  }
}
