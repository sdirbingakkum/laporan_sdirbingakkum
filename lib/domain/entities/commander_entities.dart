import 'package:flutter/foundation.dart';

@immutable
final class CommanderDashboardSnapshot {
  const CommanderDashboardSnapshot({
    required this.schemaVersion,
    required this.generatedAt,
    required this.scope,
    required this.domains,
    required this.attention,
    required this.pomdamMatrix,
    required this.rules,
  });

  final String schemaVersion;
  final DateTime generatedAt;
  final CommanderScope scope;
  final List<CommanderDomainSnapshot> domains;
  final List<CommanderAttention> attention;
  final List<CommanderPomdamMatrixRow> pomdamMatrix;
  final CommanderRules rules;

  factory CommanderDashboardSnapshot.fromMap(Map<String, dynamic> map) {
    return CommanderDashboardSnapshot(
      schemaVersion: map['schema_version'] as String? ?? '1.0',
      generatedAt: DateTime.tryParse(map['generated_at'] as String? ?? '') ??
          DateTime.now(),
      scope: CommanderScope.fromMap(
        Map<String, dynamic>.from(map['scope'] as Map? ?? const {}),
      ),
      domains: [
        for (final item in _mapList(map['domains']))
          CommanderDomainSnapshot.fromMap(item),
      ],
      attention: [
        for (final item in _mapList(map['attention']))
          CommanderAttention.fromMap(item),
      ],
      pomdamMatrix: [
        for (final item in _mapList(map['pomdam_matrix']))
          CommanderPomdamMatrixRow.fromMap(item),
      ],
      rules: CommanderRules.fromMap(
        Map<String, dynamic>.from(map['rules'] as Map? ?? const {}),
      ),
    );
  }
}

@immutable
final class CommanderScope {
  const CommanderScope({
    required this.type,
    required this.pomdamId,
    required this.pomdamCode,
    required this.pomdamShortName,
    required this.pomdamFullName,
  });

  final String type;
  final String? pomdamId;
  final String? pomdamCode;
  final String? pomdamShortName;
  final String? pomdamFullName;

  bool get isAllPomdam => type == 'ALL_POMDAM';

  factory CommanderScope.fromMap(Map<String, dynamic> map) {
    final pomdam = map['pomdam'] is Map
        ? Map<String, dynamic>.from(map['pomdam'] as Map)
        : null;

    return CommanderScope(
      type: map['type'] as String? ?? 'ALL_POMDAM',
      pomdamId: map['pomdam_id'] as String?,
      pomdamCode: pomdam?['code'] as String?,
      pomdamShortName: pomdam?['short_name'] as String?,
      pomdamFullName: pomdam?['full_name'] as String?,
    );
  }
}

@immutable
final class CommanderDomainSnapshot {
  const CommanderDomainSnapshot({
    required this.code,
    required this.name,
    required this.asOf,
    required this.primaryMetric,
    required this.supportingMetrics,
    required this.trend,
    required this.dataTrust,
    required this.aggregationRule,
  });

  final String code;
  final String name;
  final CommanderAsOf? asOf;
  final CommanderPrimaryMetric primaryMetric;
  final Map<String, dynamic> supportingMetrics;
  final CommanderTrend trend;
  final CommanderDataTrust dataTrust;
  final String aggregationRule;

  factory CommanderDomainSnapshot.fromMap(Map<String, dynamic> map) {
    final asOfMap = map['as_of'];
    final primaryMap = map['primary_metric'];
    final trendMap = map['trend'];
    final trustMap = map['data_trust'];

    return CommanderDomainSnapshot(
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      asOf: asOfMap is Map
          ? CommanderAsOf.fromMap(Map<String, dynamic>.from(asOfMap))
          : null,
      primaryMetric: CommanderPrimaryMetric.fromMap(
        Map<String, dynamic>.from(primaryMap as Map? ?? const {}),
      ),
      supportingMetrics: Map<String, dynamic>.from(
        map['supporting_metrics'] as Map? ?? const {},
      ),
      trend: CommanderTrend.fromMap(
        Map<String, dynamic>.from(trendMap as Map? ?? const {}),
      ),
      dataTrust: CommanderDataTrust.fromMap(
        Map<String, dynamic>.from(trustMap as Map? ?? const {}),
      ),
      aggregationRule: map['aggregation_rule'] as String? ?? '',
    );
  }

  String get displayCode => switch (code) {
        'GAKKUM' => 'GAKKUM',
        'PELANGGARAN' => 'PELANGGARAN',
        'SIM_TNI' => 'SIM TNI',
        'PROVOS' => 'PROVOS',
        'LAKA_LALIN' => 'LAKA LALIN',
        'TINDAK_PIDANA' => 'TINDAK PIDANA',
        _ => code,
      };
}

@immutable
final class CommanderAsOf {
  const CommanderAsOf({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
  });

  final String id;
  final String label;
  final DateTime? start;
  final DateTime? end;

  factory CommanderAsOf.fromMap(Map<String, dynamic> map) {
    return CommanderAsOf(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      start: _parseDate(map['start']),
      end: _parseDate(map['end']),
    );
  }
}

@immutable
final class CommanderPrimaryMetric {
  const CommanderPrimaryMetric({
    required this.value,
    required this.numerator,
    required this.denominator,
    required this.ratioPct,
    required this.label,
    required this.unit,
  });

  final num? value;
  final num? numerator;
  final num? denominator;
  final double? ratioPct;
  final String label;
  final String unit;

  factory CommanderPrimaryMetric.fromMap(Map<String, dynamic> map) {
    return CommanderPrimaryMetric(
      value: map['value'] as num?,
      numerator: map['numerator'] as num?,
      denominator: map['denominator'] as num?,
      ratioPct: _toDouble(map['ratio_pct']),
      label: map['label'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
    );
  }
}

@immutable
final class CommanderTrend {
  const CommanderTrend({
    required this.available,
    required this.metric,
    required this.series,
  });

  final bool available;
  final String? metric;
  final List<CommanderTrendPoint> series;

  factory CommanderTrend.fromMap(Map<String, dynamic> map) {
    return CommanderTrend(
      available: map['available'] as bool? ?? false,
      metric: map['metric'] as String?,
      series: [
        for (final item in _mapList(map['series']))
          CommanderTrendPoint.fromMap(item),
      ],
    );
  }
}

@immutable
final class CommanderTrendPoint {
  const CommanderTrendPoint({
    required this.periodId,
    required this.periodLabel,
    required this.periodStart,
    required this.value,
    required this.valuePct,
  });

  final String periodId;
  final String periodLabel;
  final DateTime? periodStart;
  final double? value;
  final double? valuePct;

  double? get plottedValue => valuePct ?? value;

  factory CommanderTrendPoint.fromMap(Map<String, dynamic> map) {
    return CommanderTrendPoint(
      periodId: map['period_id'] as String? ?? '',
      periodLabel: map['period_label'] as String? ?? '',
      periodStart: _parseDate(map['period_start']),
      value: _toDouble(map['value']),
      valuePct: _toDouble(map['value_pct']),
    );
  }
}

@immutable
final class CommanderDataTrust {
  const CommanderDataTrust({
    required this.factRows,
    required this.validRows,
    required this.notReportedRows,
    required this.invalidSourceRows,
    required this.estimatedRows,
    required this.validPct,
    required this.notReportedPct,
    required this.invalidPct,
  });

  final int factRows;
  final int validRows;
  final int notReportedRows;
  final int invalidSourceRows;
  final int estimatedRows;
  final double? validPct;
  final double? notReportedPct;
  final double? invalidPct;

  String get coverageLabel => '$validRows / $factRows valid';

  factory CommanderDataTrust.fromMap(Map<String, dynamic> map) {
    return CommanderDataTrust(
      factRows: _toInt(map['fact_rows']),
      validRows: _toInt(map['valid_rows']),
      notReportedRows: _toInt(map['not_reported_rows']),
      invalidSourceRows: _toInt(map['invalid_source_rows']),
      estimatedRows: _toInt(map['estimated_rows']),
      validPct: _toDouble(map['valid_pct']),
      notReportedPct: _toDouble(map['not_reported_pct']),
      invalidPct: _toDouble(map['invalid_pct']),
    );
  }
}

@immutable
final class CommanderAttention {
  const CommanderAttention({
    required this.domain,
    required this.severity,
    required this.kind,
    required this.count,
    required this.message,
  });

  final String domain;
  final String severity;
  final String kind;
  final int count;
  final String message;

  bool get isError => severity == 'ERROR';

  factory CommanderAttention.fromMap(Map<String, dynamic> map) {
    return CommanderAttention(
      domain: map['domain'] as String? ?? '',
      severity: map['severity'] as String? ?? 'ATTENTION',
      kind: map['kind'] as String? ?? '',
      count: _toInt(map['count']),
      message: map['message'] as String? ?? '',
    );
  }
}

@immutable
final class CommanderPomdamMatrixRow {
  const CommanderPomdamMatrixRow({
    required this.pomdamId,
    required this.code,
    required this.shortName,
    required this.states,
  });

  final String pomdamId;
  final String code;
  final String shortName;
  final Map<String, String> states;

  factory CommanderPomdamMatrixRow.fromMap(Map<String, dynamic> map) {
    final rawStates = Map<String, dynamic>.from(
      map['states'] as Map? ?? const {},
    );

    return CommanderPomdamMatrixRow(
      pomdamId: map['pomdam_id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      shortName: map['short_name'] as String? ?? '',
      states: {
        for (final entry in rawStates.entries)
          entry.key: entry.value?.toString() ?? 'NO_DATA',
      },
    );
  }

  String stateFor(String domain) => states[domain] ?? 'NO_DATA';
}

@immutable
final class CommanderRules {
  const CommanderRules({
    required this.notReportedIsZero,
    required this.invalidSourceIsValid,
    required this.factRowsAreOperationalCounts,
    required this.operationalRiskThresholdsDefined,
  });

  final bool notReportedIsZero;
  final bool invalidSourceIsValid;
  final bool factRowsAreOperationalCounts;
  final bool operationalRiskThresholdsDefined;

  factory CommanderRules.fromMap(Map<String, dynamic> map) {
    return CommanderRules(
      notReportedIsZero: map['not_reported_is_zero'] as bool? ?? false,
      invalidSourceIsValid: map['invalid_source_is_valid'] as bool? ?? false,
      factRowsAreOperationalCounts:
          map['fact_rows_are_operational_counts'] as bool? ?? false,
      operationalRiskThresholdsDefined:
          map['operational_risk_thresholds_defined'] as bool? ?? false,
    );
  }
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return [
    for (final item in value)
      if (item is Map)
        Map<String, dynamic>.from(item),
  ];
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

double? _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

int _toInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
