import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/reference_data_providers.dart';
import '../../domain/entities/reference_entities.dart';
import '../widgets/visual_analytics.dart';

class LaporanHubPage extends ConsumerWidget {
  const LaporanHubPage({super.key});

  static const _icons = {
    'GAKKUM': Icons.gavel_rounded,
    'PELANGGARAN': Icons.rule_rounded,
    'SIM_TNI': Icons.badge_rounded,
    'PROVOS': Icons.shield_rounded,
    'LAKA_LALIN': Icons.car_crash_rounded,
    'TINDAK_PIDANA': Icons.policy_rounded,
  };

  static const _routes = {
    'GAKKUM': '/gakkum',
    'PELANGGARAN': '/pelanggaran',
    'SIM_TNI': '/sim-tni',
    'PROVOS': '/provos',
    'LAKA_LALIN': '/laka-lalin',
    'TINDAK_PIDANA': '/tindak-pidana',
  };

  static const _palettes = {
    'GAKKUM': AppVisualPalettes.gakkum,
    'PELANGGARAN': AppVisualPalettes.pelanggaran,
    'SIM_TNI': AppVisualPalettes.simTni,
    'PROVOS': AppVisualPalettes.provos,
    'LAKA_LALIN': AppVisualPalettes.laka,
    'TINDAK_PIDANA': AppVisualPalettes.pidana,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportTypesProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Text('Laporan belum tersedia.'),
      ),
      data: (types) => _Hub(types: types),
    );
  }
}

class _Hub extends StatelessWidget {
  const _Hub({required this.types});

  final List<ReportType> types;

  @override
  Widget build(BuildContext context) {
    final active = types.where((item) => item.active).toList();

    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            headingLevel: 2,
            child: Text(
              'Laporan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 3
                  : constraints.maxWidth >= 650
                      ? 2
                      : 1;
              final gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final type in active)
                    SizedBox(
                      width: width,
                      child: _ReportTile(
                        type: type,
                        width: width,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.type, required this.width});

  final ReportType type;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = LaporanHubPage._palettes[type.code] ??
        AppVisualPalettes.gakkum;
    final route = LaporanHubPage._routes[type.code];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: route == null ? null : () => context.go(route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: width < 400 ? 132 : 156,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                palette.primary.withValues(alpha: .15),
                palette.secondary.withValues(alpha: .055),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: palette.primary.withValues(alpha: .12),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                top: -18,
                child: Icon(
                  LaporanHubPage._icons[type.code] ?? Icons.insights_rounded,
                  size: 104,
                  color: palette.primary.withValues(alpha: .07),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        LaporanHubPage._icons[type.code] ??
                            Icons.insights_rounded,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        type.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: .06, end: 0);
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
            constraints: const BoxConstraints(maxWidth: 1280),
            child: child,
          ),
        ),
      ],
    );
  }
}
