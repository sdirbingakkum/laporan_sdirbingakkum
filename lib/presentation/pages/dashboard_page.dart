// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../application/providers/commander_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../../domain/entities/commander_entities.dart';

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
      error: (error, stack) => _ErrorView(
        error: error,
        retry: () => ref.invalidate(commanderAccessContextProvider),
      ),
      data: (access) {
        if (!access.canUseCommanderDashboard) {
          return const _AccessStateView();
        }

        final effectivePomdamId = access.isPomdamScoped
            ? (access.pomdamIds.length == 1 ? access.pomdamIds.first : null)
            : _selectedPomdamId;

        if (access.isPomdamScoped && effectivePomdamId == null) {
          return const _AccessStateView(
            message:
                'Scope POMDAM belum dikonfigurasi dengan tepat. '
                'Commander Dashboard membutuhkan tepat satu POMDAM untuk role ini.',
          );
        }

        if (!access.isAllPomdam &&
            effectivePomdamId != null &&
            !access.canReadPomdam(effectivePomdamId)) {
          return const _AccessStateView(
            message: 'Scope POMDAM akun tidak valid.',
          );
        }

        final query = CommanderDashboardQuery(pomdamId: effectivePomdamId);
        final state = ref.watch(commanderDashboardProvider(query));

        void handlePomdamChanged(String? value) {
          if (!access.isAllPomdam) return;

          if (value == null) {
            setState(() => _selectedPomdamId = null);
            return;
          }

          setState(() => _selectedPomdamId = value);
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(commanderDashboardProvider(query)),
          child: state.when(
            loading: () => const _LoadingView(),
            error: (error, stack) => _ErrorView(
              error: error,
              retry: () => ref.invalidate(commanderDashboardProvider(query)),
            ),
            data: (snapshot) {
              final snapshotScopeMatches =
                  access.isPomdamScoped
                      ? snapshot.scope.pomdamId == effectivePomdamId &&
                          !snapshot.scope.isAllPomdam
                      : snapshot.scope.isAllPomdam ==
                          (effectivePomdamId == null);

              if (!snapshotScopeMatches) {
                return const _AccessStateView(
                  message:
                      'Scope snapshot tidak sesuai dengan authorization context.',
                );
              }

              return _CommanderView(
                snapshot: snapshot,
                selectedPomdamId: effectivePomdamId,
                access: access,
                onPomdamChanged: handlePomdamChanged,
              );
            },
          ),
        );
      },
    );
  }
}


class _AccessStateView extends StatelessWidget {
  const _AccessStateView({
    this.message =
        'Akun tidak memiliki akses Commander Dashboard yang sesuai.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Dashboard tidak tersedia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(message),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommanderView extends StatelessWidget {
  const _CommanderView({
    required this.snapshot,
    required this.selectedPomdamId,
    required this.access,
    required this.onPomdamChanged,
  });

  final CommanderDashboardSnapshot snapshot;
  final String? selectedPomdamId;
  final CommanderAccessContext access;
  final ValueChanged<String?> onPomdamChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 700 ? 14.0 : 24.0;
    final gap = 12.0;
    final cardWidth = width >= 1150
        ? (width - horizontal * 2 - gap * 2) / 3
        : width >= 700
            ? (width - horizontal * 2 - gap) / 2
            : width - horizontal * 2;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 30),
      children: [
        _Header(
          snapshot: snapshot,
          selectedPomdamId: selectedPomdamId,
          access: access,
          onPomdamChanged: onPomdamChanged,
        ),
        if (snapshot.attention.isNotEmpty) ...[
          const SizedBox(height: 12),
          _AttentionPanel(items: snapshot.attention),
        ],
        const SizedBox(height: 16),
        Text(
          'SITUATION AT A GLANCE',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final domain in snapshot.domains)
              SizedBox(
                width: cardWidth,
                child: _DomainCard(
                  domain: domain,
                  pomdamId: selectedPomdamId,
                ),
              ),
          ],
        ),
        if (snapshot.domains.any((d) => d.trend.available)) ...[
          const SizedBox(height: 14),
          _TrendPanel(domains: snapshot.domains),
        ],
        const SizedBox(height: 14),
        _TrustPanel(domains: snapshot.domains),
        if (access.isAllPomdam && snapshot.pomdamMatrix.isNotEmpty) ...[
          const SizedBox(height: 14),
          _MatrixPanel(
            rows: snapshot.pomdamMatrix,
            selectedPomdamId: selectedPomdamId,
            onSelected: onPomdamChanged,
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.snapshot,
    required this.selectedPomdamId,
    required this.access,
    required this.onPomdamChanged,
  });

  final CommanderDashboardSnapshot snapshot;
  final String? selectedPomdamId;
  final CommanderAccessContext access;
  final ValueChanged<String?> onPomdamChanged;

  @override
  Widget build(BuildContext context) {
    final scope = snapshot.scope.isAllPomdam
        ? 'SEMUA POMDAM'
        : (snapshot.scope.pomdamShortName ??
            snapshot.scope.pomdamCode ??
            'POMDAM');

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAPORAN SDIRBIN GAKKUM',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: .4,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'COMMANDER COMMON OPERATING PICTURE',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                if (access.isAllPomdam && snapshot.pomdamMatrix.length > 1)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: DropdownButtonFormField<String?>(
                      initialValue: selectedPomdamId,
                      decoration: const InputDecoration(
                        labelText: 'Scope POMDAM',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua POMDAM'),
                        ),
                        for (final row in snapshot.pomdamMatrix)
                          DropdownMenuItem<String?>(
                            value: row.pomdamId,
                            child: Text(row.code + ' · ' + row.shortName),
                          ),
                      ],
                      onChanged: onPomdamChanged,
                    ),
                  )
                else if (access.isAllPomdam && selectedPomdamId != null)
                  OutlinedButton.icon(
                    onPressed: () => onPomdamChanged(null),
                    icon: const Icon(Icons.clear),
                    label: const Text('Kembali ke Semua POMDAM'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                _Badge(
                  icon: Icons.account_balance_outlined,
                  label: scope,
                ),
                _Badge(
                  icon: Icons.person_outline,
                  label: access.role!.displayName,
                ),
                const _Badge(
                  icon: Icons.schedule_outlined,
                  label: 'LATEST AVAILABLE',
                ),
                _Badge(
                  icon: Icons.layers_outlined,
                  label: snapshot.domains.length.toString() + ' DOMAIN',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 9),
            Text(
              'AS-OF PER DOMAIN',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final domain in snapshot.domains)
                  if (domain.asOf != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                      ),
                      label: Text(
                        domain.displayCode + ' · ' + domain.asOf!.label,
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.items});

  final List<CommanderAttention> items;

  @override
  Widget build(BuildContext context) {
    final errors = items.where((item) => item.isError).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ATTENTION',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (errors > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      '· ' + errors.toString() + ' ERROR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 118,
                      child: Text(
                        item.domain,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(child: Text(item.message)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({
    required this.domain,
    required this.pomdamId,
  });

  final CommanderDomainSnapshot domain;
  final String? pomdamId;

  @override
  Widget build(BuildContext context) {
    final trust = domain.dataTrust;
    final route = switch (domain.code) {
      'GAKKUM' => '/gakkum',
      'PELANGGARAN' => '/pelanggaran',
      'SIM_TNI' => '/sim-tni',
      'PROVOS' => '/provos',
      'LAKA_LALIN' => '/laka-lalin',
      'TINDAK_PIDANA' => '/tindak-pidana',
      _ => '/',
    };

    final pidanaCoverage =
        domain.code == 'TINDAK_PIDANA' && trust.notReportedPct != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final query = <String, String>{
            'domain': domain.code,
            if (pomdamId != null) 'pomdamId': pomdamId!,
          };
          context.push(
            Uri(path: '/commander/drilldown', queryParameters: query).toString(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      domain.displayCode,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  if (domain.asOf != null)
                    Text(
                      _shortPeriod(domain.asOf!.label),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
              const SizedBox(height: 9),
              if (domain.code == 'PROVOS')
                _ProvosMetric(metric: domain.primaryMetric)
              else
                _PrimaryMetric(metric: domain.primaryMetric),
              const SizedBox(height: 10),
              _Supporting(domain: domain),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trust.coverageLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  _TrustPill(
                    trust: trust,
                    emphasizeCoverage: pidanaCoverage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryMetric extends StatelessWidget {
  const _PrimaryMetric({required this.metric});

  final CommanderPrimaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.value == null ? '—' : _format(metric.value),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: .95,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          metric.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _ProvosMetric extends StatelessWidget {
  const _ProvosMetric({required this.metric});

  final CommanderPrimaryMetric metric;

  @override
  Widget build(BuildContext context) {
    final ratio = metric.ratioPct;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ratio == null ? '—' : _format(ratio) + '%',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: .95,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          metric.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          _format(metric.numerator) + ' / ' + _format(metric.denominator),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _Supporting extends StatelessWidget {
  const _Supporting({required this.domain});

  final CommanderDomainSnapshot domain;

  @override
  Widget build(BuildContext context) {
    final m = domain.supportingMetrics;

    switch (domain.code) {
      case 'GAKKUM':
      case 'PELANGGARAN':
        return _Bars(items: _items(m['top_categories']));
      case 'SIM_TNI':
        return _Bars(items: _items(m['by_type']));
      case 'TINDAK_PIDANA':
        final items = _items(m['top_categories']);
        return items.isEmpty
            ? const Text('Belum ada nilai valid non-zero.')
            : _Bars(items: items);
      case 'LAKA_LALIN':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Mini(label: 'Korban', value: m['victims']),
            _Mini(label: 'MD', value: m['meninggal_dunia']),
            _Mini(label: 'LB', value: m['luka_berat']),
          ],
        );
      case 'PROVOS':
        final education = m['education'] is Map
            ? Map<String, dynamic>.from(m['education'] as Map)
            : const <String, dynamic>{};

        return Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _Pair(
              label: 'Pendidikan',
              left: 'SUDAH',
              leftValue: education['sudah'],
              right: 'BELUM',
              rightValue: education['belum'],
            ),
            _Pair(
              label: 'Kekuatan',
              left: 'NYATA',
              leftValue: m['nyata'],
              right: 'DSPP',
              rightValue: m['dspp'],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.items});

  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final maxValue = items
        .map((item) => item.value)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _format(item.value),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                LinearProgressIndicator(
                  minHeight: 5,
                  value: maxValue == 0 ? 0 : item.value / maxValue,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Column(
          children: [
            Text(
              _format(value),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _Pair extends StatelessWidget {
  const _Pair({
    required this.label,
    required this.left,
    required this.leftValue,
    required this.right,
    required this.rightValue,
  });

  final String label;
  final String left;
  final dynamic leftValue;
  final String right;
  final dynamic rightValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          left +
              ' ' +
              _format(leftValue) +
              '  ·  ' +
              right +
              ' ' +
              _format(rightValue),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({
    required this.trust,
    required this.emphasizeCoverage,
  });

  final CommanderDataTrust trust;
  final bool emphasizeCoverage;

  @override
  Widget build(BuildContext context) {
    if (emphasizeCoverage && trust.notReportedPct != null) {
      return _Pill(
        icon: Icons.warning_amber_rounded,
        label: _format(trust.notReportedPct) + '% NR',
      );
    }

    if (trust.invalidSourceRows > 0) {
      return _Pill(
        icon: Icons.error_outline,
        label: trust.invalidSourceRows.toString() + ' invalid',
      );
    }

    if (trust.notReportedRows > 0) {
      return _Pill(
        icon: Icons.info_outline,
        label: trust.notReportedRows.toString() + ' NR',
      );
    }

    return const _Pill(
      icon: Icons.verified_outlined,
      label: 'VALID',
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  const _TrendPanel({required this.domains});

  final List<CommanderDomainSnapshot> domains;

  @override
  Widget build(BuildContext context) {
    final rows = domains.where((domain) => domain.trend.available).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHANGE / TREND',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 9),
            for (final domain in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TrendRow(domain: domain),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.domain});

  final CommanderDomainSnapshot domain;

  @override
  Widget build(BuildContext context) {
    final points = domain.trend.series.reversed.toList();
    final values = points
        .map((point) => point.plottedValue)
        .whereType<double>()
        .toList();
    final latest = values.isEmpty ? null : values.last;
    final previous = values.length > 1 ? values[values.length - 2] : null;
    final delta =
        latest != null && previous != null ? latest - previous : null;

    return Row(
      children: [
        SizedBox(
          width: 108,
          child: Text(
            domain.displayCode,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: _MiniTrend(values: values),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                latest == null ? '—' : _format(latest),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                delta == null
                    ? 'tanpa pembanding'
                    : (delta >= 0 ? '+' : '') + _format(delta),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniTrend extends StatelessWidget {
  const _MiniTrend({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return Text(
        'History belum cukup',
        style: Theme.of(context).textTheme.labelSmall,
      );
    }

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = max == min ? 1.0 : max - min;

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final value in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FractionallySizedBox(
                  heightFactor: .28 + ((value - min) / span) * .72,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrustPanel extends StatelessWidget {
  const _TrustPanel({required this.domains});

  final List<CommanderDomainSnapshot> domains;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DATA TRUST / FRESHNESS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 9),
            for (final domain in domains)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(
                        domain.displayCode,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: (domain.dataTrust.validPct ?? 0) / 100,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 56,
                      child: Text(
                        domain.dataTrust.validPct == null
                            ? '—'
                            : _format(domain.dataTrust.validPct) + '%',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatrixPanel extends StatelessWidget {
  const _MatrixPanel({
    required this.rows,
    required this.selectedPomdamId,
    required this.onSelected,
  });

  final List<CommanderPomdamMatrixRow> rows;
  final String? selectedPomdamId;
  final ValueChanged<String?> onSelected;

  static const columns = [
    ('GAKKUM', 'GAK'),
    ('PELANGGARAN', 'PEL'),
    ('SIM_TNI', 'SIM'),
    ('PROVOS', 'PRO'),
    ('LAKA_LALIN', 'LAKA'),
    ('TINDAK_PIDANA', 'PID'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'POMDAM SITUATION MATRIX',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Text(
                  rows.length.toString() + ' POMDAM',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 40,
                dataRowMinHeight: 42,
                dataRowMaxHeight: 46,
                columns: [
                  const DataColumn(label: Text('POMDAM')),
                  for (final column in columns)
                    DataColumn(
                      label: Text(
                        column.$2,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      selected: row.pomdamId == selectedPomdamId,
                      onSelectChanged: (selected) =>
                          onSelected(selected == true ? row.pomdamId : null),
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 155,
                            child: Text(
                              row.code + ' · ' + row.shortName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        for (final column in columns)
                          DataCell(
                            _StateGlyph(row.stateFor(column.$1)),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _Legend(symbol: '●', label: 'COMPLETE'),
                _Legend(symbol: '◐', label: 'GAP'),
                _Legend(symbol: '!', label: 'ERROR'),
                _Legend(symbol: '—', label: 'NO DATA'),
                _Legend(symbol: '≈', label: 'ESTIMATED'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateGlyph extends StatelessWidget {
  const _StateGlyph(this.state);

  final String state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        switch (state) {
          'COMPLETE' => '●',
          'GAP' => '◐',
          'ERROR' => '!',
          'ESTIMATED' => '≈',
          _ => '—',
        },
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.symbol, required this.label});

  final String symbol;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(18),
      children: const [
        _LoadingBlock(168),
        SizedBox(height: 12),
        _LoadingBlock(118),
        SizedBox(height: 12),
        _LoadingBlock(260),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock(this.height);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: height,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.retry});

  final Object error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      AuthorizationException() =>
        'Akses Commander tidak diizinkan untuk scope yang diminta.',
      AppException() => error.message,
      _ => 'Commander snapshot belum dapat dibaca dari Supabase.',
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Snapshot tidak tersedia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(message),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Item {
  const _Item(this.label, this.value);

  final String label;
  final double value;
}

List<_Item> _items(dynamic raw) {
  if (raw is! List) return const [];

  final result = <_Item>[];
  for (final item in raw) {
    if (item is! Map) continue;

    final map = Map<String, dynamic>.from(item);
    final label = (map['name'] ?? map['label'] ?? map['code'])?.toString();
    final value = map['value'];

    if (label == null || value is! num) continue;
    result.add(_Item(label, value.toDouble()));
  }

  return result;
}

String _shortPeriod(String label) {
  final parts = label.split(' ');
  return parts.isEmpty ? label : parts.first;
}

String _format(dynamic value) {
  if (value == null) return '—';

  if (value is int) return _group(value);

  if (value is num) {
    final d = value.toDouble();
    if (d == d.truncateToDouble()) return _group(d.toInt());
    return d.toStringAsFixed(2).replaceAll('.', ',');
  }

  return value.toString();
}

String _group(int value) {
  final sign = value < 0 ? '-' : '';
  final digits = value.abs().toString();
  final parts = <String>[];

  for (var end = digits.length; end > 0; end -= 3) {
    final start = end > 3 ? end - 3 : 0;
    parts.add(digits.substring(start, end));
  }

  return sign + parts.reversed.join('.');
}
