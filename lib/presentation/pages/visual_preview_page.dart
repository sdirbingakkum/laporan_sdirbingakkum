import 'package:flutter/material.dart';

import '../widgets/analytics_ui.dart';
import '../widgets/visual_analytics.dart';

class VisualPreviewPage extends StatelessWidget {
  const VisualPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  headingLevel: 2,
                  child: Text(
                    'Visual Preview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Text(
                  'Sep 2026',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100
                  ? 3
                  : constraints.maxWidth >= 720
                      ? 2
                      : 1;
              final gap = 12.0;
              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              final cards = <Widget>[
                DomainVisualCard(
                  title: 'Gakkum',
                  value: 356,
                  palette: AppVisualPalettes.gakkum,
                  icon: Icons.gavel_rounded,
                  trend: const [220, 250, 242, 278, 311, 356],
                  status: HeatmapState.good,
                ),
                DomainVisualCard(
                  title: 'Pelanggaran',
                  value: 184,
                  palette: AppVisualPalettes.pelanggaran,
                  icon: Icons.rule_rounded,
                  trend: const [140, 168, 151, 171, 177, 184],
                  status: HeatmapState.warning,
                ),
                DomainVisualCard(
                  title: 'SIM TNI',
                  value: 522,
                  palette: AppVisualPalettes.simTni,
                  icon: Icons.badge_rounded,
                  trend: const [410, 448, 470, 481, 508, 522],
                  status: HeatmapState.good,
                ),
                DomainVisualCard(
                  title: 'Provos',
                  value: 271,
                  palette: AppVisualPalettes.provos,
                  icon: Icons.shield_rounded,
                  trend: const [246, 252, 249, 258, 266, 271],
                  status: HeatmapState.good,
                ),
                DomainVisualCard(
                  title: 'Laka Lalu Lintas',
                  value: 93,
                  palette: AppVisualPalettes.laka,
                  icon: Icons.car_crash_rounded,
                  trend: const [71, 78, 84, 80, 89, 93],
                  status: HeatmapState.warning,
                ),
                DomainVisualCard(
                  title: 'Tindak Pidana',
                  value: 142,
                  palette: AppVisualPalettes.pidana,
                  icon: Icons.policy_rounded,
                  trend: const [128, 122, 131, 136, 139, 142],
                  status: HeatmapState.error,
                ),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final card in cards)
                    SizedBox(width: cardWidth, child: card),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          ResponsiveGrid(
            minWidth: 340,
            children: [
              VisualPanel(
                title: 'Distribusi Gakkum',
                accent: AppVisualPalettes.gakkum.primary,
                child: AnimatedRankBarChart(
                  items: const [
                    VisualDatum(label: 'Kategori 1', value: 128),
                    VisualDatum(label: 'Kategori 2', value: 94),
                    VisualDatum(label: 'Kategori 3', value: 71),
                    VisualDatum(label: 'Kategori 4', value: 42),
                    VisualDatum(label: 'Kategori 5', value: 21),
                    VisualDatum(label: 'Kategori 6', value: 12),
                  ],
                  palette: AppVisualPalettes.gakkum,
                  height: width < 600 ? 270 : 300,
                ),
              ),
              VisualPanel(
                title: 'Komposisi Pelanggaran',
                accent: AppVisualPalettes.pelanggaran.primary,
                child: AnimatedDonutChart(
                  items: const [
                    VisualDatum(label: 'Kategori A', value: 52),
                    VisualDatum(label: 'Kategori B', value: 43),
                    VisualDatum(label: 'Kategori C', value: 31),
                    VisualDatum(label: 'Kategori D', value: 18),
                    VisualDatum(label: 'Lainnya', value: 40),
                  ],
                  palette: AppVisualPalettes.pelanggaran,
                  centerValue: 184,
                  centerLabel: 'total',
                  height: width < 600 ? 250 : 300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ResponsiveGrid(
            minWidth: 300,
            children: [
              VisualPanel(
                title: 'Trend SIM TNI',
                accent: AppVisualPalettes.simTni.primary,
                child: AnimatedTrendChart(
                  points: const [410, 448, 470, 481, 508, 522, 548],
                  labels: const ['Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep'],
                  palette: AppVisualPalettes.simTni,
                  height: 240,
                ),
              ),
              VisualPanel(
                title: 'Kualitas Data',
                accent: AppVisualPalettes.provos.primary,
                child: AnimatedStatusRing(
                  valid: 86,
                  attention: 11,
                  error: 3,
                  palette: AppVisualPalettes.provos,
                ),
              ),
              VisualPanel(
                title: 'Kapasitas Provos',
                accent: AppVisualPalettes.provos.primary,
                child: AnimatedRadialMetric(
                  value: 271,
                  max: 320,
                  palette: AppVisualPalettes.provos,
                  label: 'personel',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              rows: const [
                HeatmapRow(
                  label: 'Pomdam I',
                  values: [
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.warning,
                    HeatmapState.good,
                    HeatmapState.warning,
                    HeatmapState.good,
                  ],
                ),
                HeatmapRow(
                  label: 'Pomdam II',
                  values: [
                    HeatmapState.good,
                    HeatmapState.warning,
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.error,
                    HeatmapState.warning,
                  ],
                ),
                HeatmapRow(
                  label: 'Pomdam III',
                  values: [
                    HeatmapState.warning,
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.warning,
                    HeatmapState.good,
                    HeatmapState.error,
                  ],
                ),
                HeatmapRow(
                  label: 'Pomdam IV',
                  values: [
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.good,
                    HeatmapState.good,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
