import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/analytics_ui.dart';
import '../widgets/visual_analytics.dart';

class VisualPreviewPage extends StatelessWidget {
  const VisualPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 700;

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreviewHeader(compact: compact),
          const SizedBox(height: 20),
          _PreviewHero(compact: compact),
          const SizedBox(height: 22),
          _DomainOverview(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return const Column(
                  children: [
                    _PrimaryVisual(),
                    SizedBox(height: 18),
                    _QualityVisual(),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _PrimaryVisual()),
                  SizedBox(width: 34),
                  Expanded(flex: 2, child: _QualityVisual()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppTheme.brand,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'RINGKASAN LAPORAN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7,
                      ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_rounded, size: 17),
              SizedBox(width: 7),
              Text(
                'Sep 2026',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewHero extends StatelessWidget {
  const _PreviewHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 26,
        compact ? 20 : 24,
        compact ? 18 : 26,
        compact ? 18 : 24,
      ),
      decoration: BoxDecoration(
        color: AppTheme.brand.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.brand.withValues(alpha: .10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AnimatedMetric(
              value: 356,
              label: 'TOTAL LAPORAN',
              color: AppTheme.brand,
              size: compact ? 52 : 70,
            ),
          ),
          if (!compact)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                    color: AppTheme.muted,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusDot(color: AppTheme.success, size: 9),
                    SizedBox(width: 7),
                    Text(
                      'Data aktif',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DomainOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const domains = [
      (
        'GAKKUM',
        356,
        AppDomainColors.gakkum,
        Icons.gavel_rounded,
      ),
      (
        'PELANGGARAN',
        184,
        AppDomainColors.pelanggaran,
        Icons.rule_rounded,
      ),
      (
        'SIM TNI',
        522,
        AppDomainColors.simTni,
        Icons.badge_rounded,
      ),
      (
        'PROVOS',
        271,
        AppDomainColors.provos,
        Icons.shield_rounded,
      ),
      (
        'LAKA LALIN',
        93,
        AppDomainColors.laka,
        Icons.car_crash_rounded,
      ),
      (
        'TINDAK PIDANA',
        142,
        AppDomainColors.tindakPidana,
        Icons.policy_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOMAIN',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w900,
                letterSpacing: .45,
              ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < domains.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == domains.length - 1 ? 0 : 6),
            child: DomainSignalRow(
              icon: domains[i].$4,
              label: domains[i].$1,
              color: domains[i].$3,
              value: domains[i].$2,
              unit: 'TOTAL',
              onTap: () {},
              compact: true,
            ),
          ),
      ],
    );
  }
}

class _PrimaryVisual extends StatelessWidget {
  const _PrimaryVisual();

  @override
  Widget build(BuildContext context) {
    return VisualPanel(
      title: 'Distribusi kegiatan',
      accent: AppDomainColors.gakkum,
      child: AnimatedRankBarChart(
        items: const [
          VisualDatum(label: 'Gakkum', value: 356),
          VisualDatum(label: 'SIM TNI', value: 271),
          VisualDatum(label: 'Pelanggaran', value: 184),
          VisualDatum(label: 'Provos', value: 142),
          VisualDatum(label: 'Tindak Pidana', value: 93),
          VisualDatum(label: 'Laka Lalin', value: 51),
        ],
        palette: AppVisualPalettes.gakkum,
        maxItems: 6,
        height: 280,
      ),
    );
  }
}

class _QualityVisual extends StatelessWidget {
  const _QualityVisual();

  @override
  Widget build(BuildContext context) {
    return VisualPanel(
      title: 'Kualitas data',
      accent: AppTheme.success,
      child: AnimatedStatusRing(
        valid: 86,
        attention: 11,
        error: 3,
        palette: AppVisualPalettes.provos,
      ),
    );
  }
}
