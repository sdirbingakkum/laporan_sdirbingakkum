import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../application/providers/commander_providers.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../../domain/entities/commander_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/visual_analytics.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _selectedPomdamId;

  @override
  Widget build(BuildContext context) {
    final accessState = ref.watch(commanderAccessContextProvider);

    return accessState.when(
      loading: () => const _LoadingView(),
      error: (error, stack) => _MessageView(
        message: 'Dashboard belum dapat dibuka.',
        retry: () => ref.invalidate(commanderAccessContextProvider),
      ),
      data: (access) {
        if (!access.canUseCommanderDashboard) {
          return const _MessageView(
            message: 'Dashboard tidak tersedia untuk akun ini.',
          );
        }

        final effectivePomdamId = access.isPomdamScoped
            ? (access.pomdamIds.length == 1 ? access.pomdamIds.first : null)
            : _selectedPomdamId;

        if (access.isPomdamScoped && effectivePomdamId == null) {
          return const _MessageView(
            message: 'Scope POMDAM akun belum lengkap.',
          );
        }

        final query = CommanderDashboardQuery(pomdamId: effectivePomdamId);
        final state = ref.watch(commanderDashboardProvider(query));

        return state.when(
          loading: () => const _LoadingView(),
          error: (error, stack) => _MessageView(
            message: 'Ringkasan belum dapat dibaca.',
            retry: () => ref.invalidate(commanderDashboardProvider(query)),
          ),
          data: (snapshot) => _CommanderView(
            snapshot: snapshot,
            access: access,
            selectedPomdamId: effectivePomdamId,
            onPomdamChanged: (value) {
              if (!access.isAllPomdam) return;
              setState(() => _selectedPomdamId = value);
            },
          ),
        );
      },
    );
  }
}

class _CommanderView extends StatelessWidget {
  const _CommanderView({
    required this.snapshot,
    required this.access,
    required this.selectedPomdamId,
    required this.onPomdamChanged,
  });

  final CommanderDashboardSnapshot snapshot;
  final CommanderAccessContext access;
  final String? selectedPomdamId;
  final ValueChanged<String?> onPomdamChanged;

  static const _routes = {
    'GAKKUM': '/gakkum',
    'PELANGGARAN': '/pelanggaran',
    'SIM_TNI': '/sim-tni',
    'PROVOS': '/provos',
    'LAKA_LALIN': '/laka-lalin',
    'TINDAK_PIDANA': '/tindak-pidana',
  };

  @override
  Widget build(BuildContext context) {
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            snapshot: snapshot,
            access: access,
            selectedPomdamId: selectedPomdamId,
            onPomdamChanged: onPomdamChanged,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 3
                  : constraints.maxWidth >= 720
                      ? 2
                      : 1;
              final gap = 12.0;
              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final domain in snapshot.domains)
                    SizedBox(
                      width: cardWidth,
                      height: 140, // fix height for overview card
                      child: DomainOverviewCard(
                        icon: _iconFor(domain.code),
                        label: domain.name,
                        color: _paletteFor(domain.code).primary,
                        kpiValue: domain.primaryMetric.value?.toInt(),
                        kpiLabel: domain.primaryMetric.unit.isEmpty
                            ? 'TOTAL'
                            : domain.primaryMetric.unit.toUpperCase(),
                        onTap: _routes[domain.code] == null
                            ? () {}
                            : () => context.go(_routes[domain.code]!),
                      ),
                    ),
                ],
              );
            },
          ),
          if (access.isAllPomdam && snapshot.pomdamMatrix.isNotEmpty) ...[
            const SizedBox(height: 14),
            VisualPanel(
              title: 'Status POMDAM',
              accent: AppTheme.brand,
              child: AnimatedHeatmap(
                columns: const [
                  'Gakkum',
                  'Pelang.',
                  'SIM',
                  'Provos',
                  'Laka',
                  'Pidana',
                ],
                rows: [
                  for (final row in snapshot.pomdamMatrix)
                    HeatmapRow(
                      label: row.shortName,
                      values: [
                        _heatmapState(row.stateFor('GAKKUM')),
                        _heatmapState(row.stateFor('PELANGGARAN')),
                        _heatmapState(row.stateFor('SIM_TNI')),
                        _heatmapState(row.stateFor('PROVOS')),
                        _heatmapState(row.stateFor('LAKA_LALIN')),
                        _heatmapState(row.stateFor('TINDAK_PIDANA')),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _iconFor(String code) => switch (code) {
        'GAKKUM' => Icons.gavel_rounded,
        'PELANGGARAN' => Icons.rule_rounded,
        'SIM_TNI' => Icons.badge_rounded,
        'PROVOS' => Icons.shield_rounded,
        'LAKA_LALIN' => Icons.car_crash_rounded,
        'TINDAK_PIDANA' => Icons.policy_rounded,
        _ => Icons.analytics_rounded,
      };

  static VisualPalette _paletteFor(String code) => switch (code) {
        'GAKKUM' => AppVisualPalettes.gakkum,
        'PELANGGARAN' => AppVisualPalettes.pelanggaran,
        'SIM_TNI' => AppVisualPalettes.simTni,
        'PROVOS' => AppVisualPalettes.provos,
        'LAKA_LALIN' => AppVisualPalettes.laka,
        'TINDAK_PIDANA' => AppVisualPalettes.pidana,
        _ => AppVisualPalettes.gakkum,
      };

  static HeatmapState _heatmapState(String value) => switch (value) {
        'VALID' || 'COMPLETE' || 'OK' => HeatmapState.good,
        'GAP' || 'ATTENTION' || 'NOT_REPORTED' || 'ESTIMATED' =>
          HeatmapState.warning,
        'ERROR' || 'INVALID_SOURCE' => HeatmapState.error,
        _ => HeatmapState.none,
      };

  static HeatmapState _statusFor(CommanderDataTrust trust) {
    if (trust.invalidSourceRows > 0) return HeatmapState.error;
    if (trust.notReportedRows > 0 || trust.estimatedRows > 0) {
      return HeatmapState.warning;
    }
    if (trust.factRows > 0 && trust.validRows > 0) {
      return HeatmapState.good;
    }
    return HeatmapState.none;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.snapshot,
    required this.access,
    required this.selectedPomdamId,
    required this.onPomdamChanged,
  });

  final CommanderDashboardSnapshot snapshot;
  final CommanderAccessContext access;
  final String? selectedPomdamId;
  final ValueChanged<String?> onPomdamChanged;

  @override
  Widget build(BuildContext context) {
    final scope = snapshot.scope.isAllPomdam
        ? 'Semua POMDAM'
        : (snapshot.scope.pomdamShortName ?? 'POMDAM');

    final selector = access.isAllPomdam && snapshot.pomdamMatrix.length > 1
        ? SizedBox(
            width: 220,
            child: DropdownButtonFormField<String?>(
              initialValue: selectedPomdamId,
              isDense: true,
              decoration: const InputDecoration(labelText: 'POMDAM'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Semua POMDAM'),
                ),
                for (final row in snapshot.pomdamMatrix)
                  DropdownMenuItem<String?>(
                    value: row.pomdamId,
                    child: Text('${row.code} · ${row.shortName}'),
                  ),
              ],
              onChanged: onPomdamChanged,
            ),
          )
        : null;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            headingLevel: 2,
            child: Text(
              'Ringkasan laporan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
            ),
          ),
        ),
        if (selector != null) ...[
          selector,
          const SizedBox(width: 8),
        ],
        if (scope != 'Semua POMDAM')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              scope,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.brand,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 16.0 : width < 1200 ? 24.0 : 32.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, this.retry});

  final String message;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              if (retry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: retry,
                  child: const Text('Coba lagi'),
                ),
              ],
            ],
          ),
        ),
      );
}
