import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.child,
    super.key,
    this.maxWidth = 1440,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 16.0 : width < 1200 ? 24.0 : 32.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontal,
        18,
        horizontal,
        28,
      ).add(padding),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ],
    );
  }
}

class AnalyticsPageHeader extends StatelessWidget {
  const AnalyticsPageHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  container: true,
                  header: true,
                  headingLevel: 2,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                        ),
                  ),
                ],
                if (trailing != null) ...[
                  const SizedBox(height: 14),
                  trailing!,
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.muted,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
    );
  }
}

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({
    required this.title,
    required this.child,
    super.key,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class AnalyticsKpiCard extends StatelessWidget {
  const AnalyticsKpiCard({
    required this.label,
    required this.value,
    super.key,
    this.caption,
    this.icon,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: emphasis ? FontWeight.w900 : FontWeight.w800,
                        ),
                  ),
                  if (caption != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.muted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    super.key,
    this.minWidth = 220,
    this.gap = 12,
  });

  final List<Widget> children;
  final double minWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / (minWidth + gap))
            .floor()
            .clamp(1, children.length)
            .toInt();

        final width =
            (constraints.maxWidth - gap * (count - 1)) / count;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class VisualBarList extends StatelessWidget {
  const VisualBarList({
    required this.items,
    super.key,
    this.maxItems = 6,
    this.height = 34,
  });

  final List<VisualBarItem> items;
  final int maxItems;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 90,
        child: Center(child: Text('Belum ada data visual untuk periode ini.')),
      );
    }

    final visible = items.take(maxItems).toList();
    final max = visible
        .map((item) => item.value)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: height,
              child: Row(
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: max == 0 ? 0 : item.value / max,
                        ),
                        duration: const Duration(milliseconds: 420),
                        builder: (context, value, child) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: value,
                                child: ColoredBox(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    child: Text(
                      item.valueText ?? _formatVisualValue(item.value),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _formatVisualValue(double value) {
  if (value == value.truncateToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

final class VisualBarItem {
  const VisualBarItem({
    required this.label,
    required this.value,
    this.valueText,
  });

  final String label;
  final double value;
  final String? valueText;
}

class StatusDot extends StatelessWidget {
  const StatusDot({
    required this.color,
    super.key,
    this.size = 10,
    this.label,
  });

  final Color color;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (label == null) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(label!),
      ],
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.color,
    this.icon,
  });

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: resolved.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resolved.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: resolved),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: resolved,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
