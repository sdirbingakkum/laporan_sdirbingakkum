import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/reference_data_providers.dart';
import '../../domain/entities/reference_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/analytics_ui.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportTypesProvider);

    return AppPage(
      child: state.when(
        loading: () => const _HubLoading(),
        error: (error, stack) => const _HubMessage(
          title: 'Laporan belum tersedia',
          message: 'Data jenis laporan belum dapat dibaca.',
        ),
        data: (types) {
          final active = types.where((item) => item.active).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AnalyticsPageHeader(
                title: 'Laporan',
                subtitle: 'Pilih analisis yang ingin dilihat.',
              ),
              ResponsiveGrid(
                minWidth: 270,
                children: [
                  for (final type in active)
                    _ReportCard(
                      type: type,
                      icon: _icons[type.code] ?? Icons.analytics_rounded,
                      onTap: _routes[type.code] == null
                          ? null
                          : () => context.go(_routes[type.code]!),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.type,
    required this.icon,
    required this.onTap,
  });

  final ReportType type;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: .58),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.brandDark),
              ),
              const SizedBox(height: 16),
              Text(
                type.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                _description(type.code),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.muted,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Buka analisis',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.brandDark,
                        ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _description(String code) {
    return switch (code) {
      'GAKKUM' => 'Gambaran kegiatan penegakan hukum.',
      'PELANGGARAN' => 'Pola pelanggaran berdasarkan kategori.',
      'SIM_TNI' => 'Distribusi penerbitan SIM TNI.',
      'PROVOS' => 'Kekuatan, personel, dan pendidikan.',
      'LAKA_LALIN' => 'Kejadian, korban, dan akibat.',
      'TINDAK_PIDANA' => 'Peringkat dan distribusi tindak pidana.',
      _ => 'Analisis data laporan.',
    };
  }
}

class _HubLoading extends StatelessWidget {
  const _HubLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        ResponsiveGrid(
          minWidth: 270,
          children: [
            for (var i = 0; i < 6; i++)
              const Card(
                child: SizedBox(
                  height: 190,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HubMessage extends StatelessWidget {
  const _HubMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSection(
      title: title,
      child: Text(message),
    );
  }
}
