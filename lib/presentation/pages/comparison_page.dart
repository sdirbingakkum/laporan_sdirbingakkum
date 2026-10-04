import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/commander_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/analytics_ui.dart';

class ComparisonPage extends ConsumerStatefulWidget {
  const ComparisonPage({super.key});

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage> {
  String _domain = 'GAKKUM';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      commanderDashboardProvider(const CommanderDashboardQuery()),
    );

    return AppPage(
      child: state.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, stack) => AnalyticsSection(
          title: 'Perbandingan belum tersedia',
          child: Text(
            error is AppException
                ? error.message
                : 'Snapshot perbandingan belum dapat dibaca.',
          ),
        ),
        data: (snapshot) => _Content(
          snapshot: snapshot,
          domain: _domain,
          onDomainChanged: (value) => setState(() => _domain = value),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.snapshot,
    required this.domain,
    required this.onDomainChanged,
  });

  final CommanderDashboardSnapshot snapshot;
  final String domain;
  final ValueChanged<String> onDomainChanged;

  static const _domains = <(String, String)>[
    ('GAKKUM', 'Gakkum'),
    ('PELANGGARAN', 'Pelanggaran'),
    ('SIM_TNI', 'SIM TNI'),
    ('PROVOS', 'Provos'),
    ('LAKA_LALIN', 'Laka'),
    ('TINDAK_PIDANA', 'Pidana'),
  ];

  @override
  Widget build(BuildContext context) {
    final rows = snapshot.pomdamMatrix;
    final complete = rows.where((r) => r.stateFor(domain) == 'COMPLETE').length;
    final gap = rows.where((r) => r.stateFor(domain) == 'GAP').length;
    final error = rows.where((r) => r.stateFor(domain) == 'ERROR').length;
    final estimated =
        rows.where((r) => r.stateFor(domain) == 'ESTIMATED').length;
    final noData = rows.length - complete - gap - error - estimated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsPageHeader(
          title: 'Perbandingan',
          subtitle: snapshot.scope.isAllPomdam
              ? 'Cakupan dan status data seluruh POMDAM.'
              : 'Cakupan POMDAM sesuai kewenangan akun.',
          trailing: AppBadge(
            icon: Icons.update_rounded,
            label: 'Diperbarui ${_formatDate(snapshot.generatedAt)}',
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (code, label) in _domains)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: code == domain,
                    onSelected: (_) => onDomainChanged(code),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ResponsiveGrid(
          minWidth: 170,
          children: [
            AnalyticsKpiCard(
              label: 'Lengkap',
              value: '$complete',
              caption: 'POMDAM',
              icon: Icons.check_circle_outline_rounded,
            ),
            AnalyticsKpiCard(
              label: 'Perlu perhatian',
              value: '$gap',
              caption: 'ada kekosongan',
              icon: Icons.warning_amber_rounded,
            ),
            AnalyticsKpiCard(
              label: 'Kesalahan',
              value: '$error',
              caption: 'perlu pemeriksaan',
              icon: Icons.error_outline_rounded,
            ),
            AnalyticsKpiCard(
              label: 'Belum ada',
              value: '$noData',
              caption: 'belum tersedia',
              icon: Icons.remove_circle_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnalyticsSection(
          title: 'Status POMDAM',
          trailing: Text(
            '${rows.length} POMDAM',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.muted,
                ),
          ),
          child: _Matrix(
            rows: rows,
            domain: domain,
            estimated: estimated,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}

class _Matrix extends StatelessWidget {
  const _Matrix({
    required this.rows,
    required this.domain,
    required this.estimated,
  });

  final List<CommanderPomdamMatrixRow> rows;
  final String domain;
  final int estimated;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 132,
                  child: Text(
                    row.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Row(
                      children: [
                        for (final entry in const [
                          ('COMPLETE', AppTheme.success),
                          ('GAP', AppTheme.warning),
                          ('ERROR', AppTheme.danger),
                          ('ESTIMATED', AppTheme.brand),
                          ('NO_DATA', AppTheme.border),
                        ])
                          if (row.stateFor(domain) == entry.$1)
                            Expanded(
                              child: ColoredBox(
                                color: entry.$2,
                                child: const SizedBox(height: 12),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 76,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _StatusLabel(row.stateFor(domain)),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            AppBadge(
              icon: Icons.check_rounded,
              label: 'Lengkap',
              color: AppTheme.success,
            ),
            AppBadge(
              icon: Icons.warning_amber_rounded,
              label: 'Perhatian',
              color: AppTheme.warning,
            ),
            AppBadge(
              icon: Icons.error_outline_rounded,
              label: 'Periksa',
              color: AppTheme.danger,
            ),
            if (estimated > 0)
              AppBadge(
                icon: Icons.functions_rounded,
                label: 'Estimasi: $estimated',
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel(this.state);

  final String state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      'COMPLETE' => ('Lengkap', AppTheme.success),
      'GAP' => ('Perhatian', AppTheme.warning),
      'ERROR' => ('Periksa', AppTheme.danger),
      'ESTIMATED' => ('Estimasi', AppTheme.brand),
      _ => ('Belum ada', AppTheme.muted),
    };
    return AppBadge(label: label, color: color);
  }
}
