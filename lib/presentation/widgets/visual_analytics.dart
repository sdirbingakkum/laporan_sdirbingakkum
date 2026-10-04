import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import 'analytics_ui.dart';

final class VisualDatum {
  const VisualDatum({
    required this.label,
    required this.value,
    this.detail,
  });

  final String label;
  final double value;
  final String? detail;
}

final class VisualPalette {
  const VisualPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.soft,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color soft;

  List<Color> get chartColors => [primary, secondary, tertiary, soft];
}

abstract final class AppVisualPalettes {
  static const gakkum = VisualPalette(
    primary: AppDomainColors.gakkum,
    secondary: Color(0xFFFF8A65),
    tertiary: Color(0xFFFFCCBC),
    soft: Color(0xFFFBE9E7),
  );

  static const pelanggaran = VisualPalette(
    primary: AppDomainColors.pelanggaran,
    secondary: Color(0xFFFFB74D),
    tertiary: Color(0xFFFFE0B2),
    soft: Color(0xFFFFF3E0),
  );

  static const simTni = VisualPalette(
    primary: AppDomainColors.simTni,
    secondary: Color(0xFF64B5F6),
    tertiary: Color(0xFFBBDEFB),
    soft: Color(0xFFE3F2FD),
  );

  static const provos = VisualPalette(
    primary: AppDomainColors.provos,
    secondary: Color(0xFF81C784),
    tertiary: Color(0xFFC8E6C9),
    soft: Color(0xFFE8F5E9),
  );

  static const laka = VisualPalette(
    primary: AppDomainColors.laka,
    secondary: Color(0xFFBA68C8),
    tertiary: Color(0xFFE1BEE7),
    soft: Color(0xFFF3E5F5),
  );

  static const pidana = VisualPalette(
    primary: AppDomainColors.tindakPidana,
    secondary: Color(0xFFF06292),
    tertiary: Color(0xFFF8BBD0),
    soft: Color(0xFFFCE4EC),
  );
}


class DomainOverviewCard extends StatelessWidget {
  const DomainOverviewCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
    this.kpiValue,
    this.kpiLabel,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? kpiValue;
  final String? kpiLabel;

  @override
  Widget build(BuildContext context) {
    return DomainSignalRow(
      icon: icon,
      label: label,
      color: color,
      value: kpiValue,
      unit: kpiLabel,
      onTap: onTap,
      compact: true,
    );
  }
}

class DomainSignalRow extends StatelessWidget {
  const DomainSignalRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
    this.value,
    this.unit,
    this.trend = const [],
    this.status,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final num? value;
  final String? unit;
  final List<double> trend;
  final HeatmapState? status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final horizontal = compact ? 14.0 : 18.0;
    final numberSize = compact ? 34.0 : 46.0;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: BoxConstraints(minHeight: compact ? 108 : 92),
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: compact ? 13 : 12,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .035),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: color, width: 5),
                top: BorderSide(color: color.withValues(alpha: .08)),
                right: BorderSide(color: color.withValues(alpha: .08)),
                bottom: BorderSide(color: color.withValues(alpha: .08)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 38 : 44,
                  height: compact ? 38 : 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: compact ? 19 : 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ink,
                              letterSpacing: .2,
                            ),
                      ),
                      if (unit != null && unit!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          unit!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trend.length > 1) ...[
                  SizedBox(
                    width: compact ? 80 : 120,
                    child: AnimatedSparkline(
                      points: trend,
                      color: color,
                      height: compact ? 34 : 42,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (status != null) ...[
                  _StatusOrb(state: status!),
                  const SizedBox(width: 14),
                ],
                if (value != null)
                  SizedBox(
                    width: compact ? 92 : 130,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatNumber(value!.toDouble()),
                        style: TextStyle(
                          fontSize: numberSize,
                          fontWeight: FontWeight.w900,
                          color: color,
                          height: 1,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: .65),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: .02, end: 0);
  }
}

class VisualPanel extends StatelessWidget {
  const VisualPanel({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.accent,
    this.padding = const EdgeInsets.fromLTRB(4, 10, 4, 8),
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final Color? accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color.withValues(alpha: .10))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (title != null)
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Semantics(
                              header: true,
                              headingLevel: 3,
                              child: Text(
                                title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.ink,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class AnimatedMetric extends StatelessWidget {
  const AnimatedMetric({
    required this.value,
    super.key,
    this.label,
    this.color,
    this.suffix,
    this.size = 56,
  });

  final num value;
  final String? label;
  final Color? color;
  final String? suffix;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;

    final number = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          '${animated.round()}${suffix ?? ''}',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.8,
            height: .95,
            color: resolvedColor,
          ),
        ),
      ),
    );

    if (label == null) return number;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        number,
        const SizedBox(height: 5),
        Text(
          label!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w900,
                letterSpacing: .35,
              ),
        ),
      ],
    );
  }
}

class AnimatedRankBarChart extends StatelessWidget {
  const AnimatedRankBarChart({
    required this.items,
    required this.palette,
    super.key,
    this.height = 260,
    this.maxItems = 7,
  });

  final List<VisualDatum> items;
  final VisualPalette palette;
  final double height;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final data = [...items]
      ..removeWhere((item) => !item.value.isFinite || item.value <= 0)
      ..sort((a, b) => b.value.compareTo(a.value));

    final visible = data.take(math.min(maxItems, 6).toInt()).toList();
    if (visible.isEmpty) return const _EmptyVisual();

    final maxValue = visible.map((item) => item.value).fold<double>(0, math.max);
    final rowHeight = visible.length <= 4 ? 42.0 : visible.length <= 6 ? 38.0 : 34.0;
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: math.max(height, visible.length * rowHeight).toDouble(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < visible.length; index++)
            Padding(
              padding: EdgeInsets.only(bottom: index == visible.length - 1 ? 0 : 10),
              child: Row(
                children: [
                  SizedBox(
                    width: width < 620 ? 100 : 160,
                    child: Text(
                      visible[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: maxValue == 0 ? 0 : (visible[index].value / maxValue).clamp(0, 1).toDouble(),
                        ),
                        duration: Duration(milliseconds: 380 + index * 55),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Stack(
                          children: [
                            Container(
                              height: rowHeight,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .72),
                            ),
                            FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                  color: palette.chartColors[index % palette.chartColors.length],
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 64,
                    child: Text(
                      _formatNumber(visible[index].value),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
class AnimatedDonutChart extends StatefulWidget {
  const AnimatedDonutChart({
    required this.items,
    required this.palette,
    super.key,
    this.height = 230,
    this.centerLabel,
    this.centerValue,
  });

  final List<VisualDatum> items;
  final VisualPalette palette;
  final double height;
  final String? centerLabel;
  final num? centerValue;

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final items = widget.items.where((item) => item.value > 0).toList();
    if (items.isEmpty) return const _EmptyVisual();

    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sectionsSpace: 3,
                startDegreeOffset: -90,
                sections: [
                  for (var i = 0; i < items.length; i++)
                    PieChartSectionData(
                      value: items[i].value,
                      color: widget.palette.chartColors[
                          i % widget.palette.chartColors.length],
                      radius: i == _touchedIndex ? 76.0 : 66.0,
                      title: '',
                    ),
                ],
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      setState(() => _touchedIndex = -1);
                      return;
                    }
                    setState(
                      () => _touchedIndex =
                          response!.touchedSection!.touchedSectionIndex,
                    );
                  },
                ),
              ),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: widget.centerValue != null
                ? Center(
                    child: AnimatedMetric(
                      value: widget.centerValue!,
                      label: widget.centerLabel,
                      color: widget.palette.primary,
                      size: 27,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length && i < 4; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _LegendRow(
                            color: widget.palette.chartColors[
                                i % widget.palette.chartColors.length],
                            label: items[i].label,
                            value: _formatNumber(items[i].value),
                            selected: i == _touchedIndex,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms).scale(
          begin: const Offset(.97, .97),
          end: const Offset(1, 1),
          duration: 520.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class AnimatedTrendChart extends StatelessWidget {
  const AnimatedTrendChart({
    required this.points,
    required this.palette,
    super.key,
    this.height = 240,
    this.labels,
  });

  final List<double> points;
  final VisualPalette palette;
  final double height;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2 || points.every((point) => point <= 0)) {
      return const _EmptyVisual();
    }

    final maxY = _niceMax(points.fold<double>(0, math.max));

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY <= 4 ? 1 : maxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.border.withValues(alpha: .6),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labels != null,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  final text = labels != null &&
                          index >= 0 &&
                          index < labels!.length
                      ? labels![index]
                      : '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF152235),
              tooltipBorderRadius: BorderRadius.circular(12),
              fitInsideHorizontally: true,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    _formatNumber(spot.y),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              curveSmoothness: .22,
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(index.toDouble(), points[index]),
              ],
              gradient: LinearGradient(
                colors: [palette.secondary, palette.primary],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4.5,
                  color: palette.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    palette.primary.withValues(alpha: .22),
                    palette.primary.withValues(alpha: .015),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      ),
    ).animate().fadeIn(duration: 360.ms).slideY(begin: .04, end: 0);
  }
}


class AnimatedStatusRing extends StatelessWidget {
  const AnimatedStatusRing({
    required this.valid,
    required this.attention,
    required this.error,
    required this.palette,
    super.key,
  });

  final int valid;
  final int attention;
  final int error;
  final VisualPalette palette;

  @override
  Widget build(BuildContext context) {
    final total = valid + attention + error;
    final ratio = total == 0 ? 0.0 : (valid / total).clamp(0, 1).toDouble();
    final percent = (ratio * 100).round();

    return SizedBox(
      height: 132,
      child: Row(
        children: [
          SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => SizedBox(
                    width: 112,
                    height: 112,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 13,
                      backgroundColor: AppTheme.border.withValues(alpha: .55),
                      valueColor: AlwaysStoppedAnimation(palette.primary),
                    ),
                  ),
                ),
                AnimatedMetric(
                  value: percent,
                  suffix: '%',
                  label: 'VALID',
                  color: palette.primary,
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _StatusStat(label: 'Valid', value: valid, color: palette.primary),
                _StatusStat(label: 'Perlu dicek', value: attention, color: AppTheme.warning),
                _StatusStat(label: 'Error', value: error, color: AppTheme.danger),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms);
  }
}

class _StatusStat extends StatelessWidget {
  const _StatusStat({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            '${label} ${_formatNumber(value.toDouble())}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      );
}
class AnimatedRadialMetric extends StatelessWidget {
  const AnimatedRadialMetric({
    required this.value,
    required this.max,
    required this.palette,
    super.key,
    this.label = 'nilai',
    this.unit,
    this.height = 210,
  });

  final num value;
  final num max;
  final VisualPalette palette;
  final String label;
  final String? unit;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0, 1).toDouble();

    return SizedBox(
      height: height,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: ratio),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) {
            return SizedBox(
              width: 166,
              height: 166,
              child: CustomPaint(
                painter: _RadialMetricPainter(
                  progress: progress,
                  color: palette.primary,
                  track: AppTheme.border,
                ),
                child: Center(
                  child: AnimatedMetric(
                    value: value,
                    suffix: unit,
                    label: label,
                    color: palette.primary,
                    size: 27,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 420.ms);
  }
}

class _RadialMetricPainter extends CustomPainter {
  _RadialMetricPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..color = track.withValues(alpha: .4);

    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: .3), color],
      ).createShader(Offset.zero & size);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2,
      false,
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialMetricPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track;
}

class AnimatedSparkline extends StatelessWidget {
  const AnimatedSparkline({
    required this.points,
    required this.color,
    super.key,
    this.height = 54,
  });

  final List<double> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) => CustomPaint(
          painter: _SparklinePainter(
            points: points,
            color: color,
            progress: progress,
          ),
        ),
      ),
    );
  }
}

class AnimatedHeatmap extends StatelessWidget {
  const AnimatedHeatmap({
    required this.columns,
    required this.rows,
    super.key,
  });

  final List<String> columns;
  final List<HeatmapRow> rows;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty || rows.isEmpty) return const _EmptyVisual();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(480.0, (94 + columns.length * 78).toDouble()),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 94),
                for (final column in columns)
                  Expanded(
                    child: Center(
                      child: Text(
                        column,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    SizedBox(
                      width: 94,
                      child: Text(
                        row.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    for (var index = 0; index < columns.length; index++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _HeatmapCell(
                            state: index < row.values.length
                                ? row.values[index]
                                : HeatmapState.none,
                            tooltip: '${row.label} - ${columns[index]}',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms);
  }
}

enum HeatmapState { good, warning, error, none }

final class HeatmapRow {
  const HeatmapRow({required this.label, required this.values});

  final String label;
  final List<HeatmapState> values;
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.state,
    required this.tooltip,
  });

  final HeatmapState state;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      HeatmapState.good => AppTheme.success,
      HeatmapState.warning => AppTheme.warning,
      HeatmapState.error => AppTheme.danger,
      HeatmapState.none => AppTheme.border,
    };

    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: color.withValues(alpha: .75),
          border: Border.all(color: color.withValues(alpha: .22)),
        ),
        child: Icon(
          switch (state) {
            HeatmapState.good => Icons.check_rounded,
            HeatmapState.warning => Icons.remove_rounded,
            HeatmapState.error => Icons.close_rounded,
            HeatmapState.none => Icons.circle_outlined,
          },
          size: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}



class DomainVisualCard extends StatelessWidget {
  const DomainVisualCard({
    required this.title,
    required this.value,
    required this.palette,
    super.key,
    this.unit,
    this.icon,
    required this.trend,
    this.status,
    this.onTap,
  });

  final String title;
  final num? value;
  final String? unit;
  final IconData? icon;
  final VisualPalette palette;
  final List<double> trend;
  final HeatmapState? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            palette.primary.withValues(alpha: .13),
            palette.secondary.withValues(alpha: .045),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.primary.withValues(alpha: .12)),
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: palette.primary, size: 19),
                ),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted,
                      ),
                ),
              ),
              if (status != null) _StatusOrb(state: status!),
            ],
          ),
          const SizedBox(height: 15),
          AnimatedMetric(
            value: value ?? 0,
            suffix: unit,
            color: palette.primary,
            size: 34,
          ),
          if (trend.length > 1) ...[
            const SizedBox(height: 12),
            AnimatedSparkline(
              points: trend,
              color: palette.primary,
              height: 42,
            ),
          ],
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    ).animate().fadeIn(duration: 360.ms).slideY(begin: .06, end: 0);
  }
}

class _StatusOrb extends StatelessWidget {
  const _StatusOrb({required this.state});

  final HeatmapState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      HeatmapState.good => AppTheme.success,
      HeatmapState.warning => AppTheme.warning,
      HeatmapState.error => AppTheme.danger,
      HeatmapState.none => AppTheme.muted,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .30),
            blurRadius: 9,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class VisualStatCluster extends StatelessWidget {
  const VisualStatCluster({
    required this.values,
    super.key,
  });

  final List<VisualStat> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: value.color.withValues(alpha: .075),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusDot(color: value.color, size: 8),
                const SizedBox(width: 6),
                Text(
                  '${value.value}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

final class VisualStat {
  const VisualStat({
    required this.value,
    required this.color,
  });

  final String value;
  final Color color;
}

class VisualFilterButton extends StatelessWidget {
  const VisualFilterButton({
    required this.label,
    required this.onTap,
    super.key,
    this.icon = Icons.tune_rounded,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      label: label,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withValues(alpha: .2)),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.selected,
  });

  final Color color;
  final String label;
  final String value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 180),
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? color : AppTheme.muted,
          ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 11 : 9,
            height: selected ? 11 : 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVisual extends StatelessWidget {
  const _EmptyVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Icon(
          Icons.bar_chart_rounded,
          size: 30,
          color: AppTheme.muted.withValues(alpha: .55),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.color,
    required this.progress,
  });

  final List<double> points;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final span = (maxValue - minValue).abs() < .0001
        ? 1
        : maxValue - minValue;

    final path = Path();

    for (var index = 0; index < points.length; index++) {
      final x = size.width * index / (points.length - 1);
      final normalized = (points[index] - minValue) / span;
      final y = size.height - normalized * (size.height * .8) - size.height * .1;

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = size.width * (index - 1) / (points.length - 1);
        final previousNormalized = (points[index - 1] - minValue) / span;
        final previousY =
            size.height - previousNormalized * (size.height * .8) - size.height * .1;
        final controlX = (previousX + x) / 2;
        path.cubicTo(controlX, previousY, controlX, y, x, y);
      }
    }

    final metric = path.computeMetrics().first;
    final clipped = metric.extractPath(0, metric.length * progress);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    canvas.drawPath(clipped, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.points != points;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

double _niceMax(double value) {
  if (value <= 0) return 1;

  final exponent =
      math.pow(10, math.log(value) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final normalized = value / magnitude;

  final nice = normalized <= 1
      ? 1
      : normalized <= 2
          ? 2
          : normalized <= 5
              ? 5
              : 10;

  return nice * magnitude;
}




class VisualReportFrame extends StatelessWidget {
  const VisualReportFrame({
    required this.title,
    required this.child,
    super.key,
    this.periodControl,
    this.filters = const [],
    this.accent,
    this.contentKey,
  });

  final String title;
  final Widget child;
  final Widget? periodControl;
  final List<Widget> filters;
  final Color? accent;
  final Object? contentKey;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    final compact = MediaQuery.sizeOf(context).width < 650;

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(2, compact ? 4 : 8, 2, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color.withValues(alpha: .16))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 9 : 11,
                        height: compact ? 9 : 11,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Semantics(
                          container: true,
                          header: true,
                          headingLevel: 2,
                          label: title,
                          child: ExcludeSemantics(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                    letterSpacing: -.8,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (periodControl != null) periodControl!,
              ],
            ),
          ),
          if (filters.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(spacing: 7, runSpacing: 7, children: filters),
            ),
          ],
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .015),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(contentKey ?? child.key),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
