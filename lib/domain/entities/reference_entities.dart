enum DataStatus {
  valid,
  notReported,
  invalidSource,
  estimated;

  static DataStatus fromDatabase(String value) {
    return switch (value) {
      'VALID' => DataStatus.valid,
      'NOT_REPORTED' => DataStatus.notReported,
      'INVALID_SOURCE' => DataStatus.invalidSource,
      'ESTIMATED' => DataStatus.estimated,
      _ => throw FormatException('Unknown data_status: $value'),
    };
  }
}

final class Pomdam {
  const Pomdam({
    required this.id,
    required this.reportOrder,
    required this.romanNumeral,
    required this.romanValue,
    required this.code,
    required this.shortName,
    required this.kodamName,
    required this.kodamFullName,
    required this.pomdamFullName,
    required this.active,
    required this.validFrom,
    required this.validTo,
    required this.createdAt,
  });

  final String id;
  final int reportOrder;
  final String? romanNumeral;
  final int? romanValue;
  final String code;
  final String shortName;
  final String kodamName;
  final String kodamFullName;
  final String pomdamFullName;
  final bool active;
  final DateTime? validFrom;
  final DateTime? validTo;
  final DateTime createdAt;

  factory Pomdam.fromMap(Map<String, dynamic> map) {
    return Pomdam(
      id: map['id'] as String,
      reportOrder: (map['report_order'] as num).toInt(),
      romanNumeral: map['roman_numeral'] as String?,
      romanValue: (map['roman_value'] as num?)?.toInt(),
      code: map['code'] as String,
      shortName: map['short_name'] as String,
      kodamName: map['kodam_name'] as String,
      kodamFullName: map['kodam_full_name'] as String,
      pomdamFullName: map['pomdam_full_name'] as String,
      active: map['active'] as bool,
      validFrom: _parseDate(map['valid_from']),
      validTo: _parseDate(map['valid_to']),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class PomdamAlias {
  const PomdamAlias({
    required this.id,
    required this.pomdamId,
    required this.sourceValue,
    required this.aliasType,
    required this.sourcePeriod,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String pomdamId;
  final String sourceValue;
  final String aliasType;
  final String? sourcePeriod;
  final String? notes;
  final DateTime createdAt;

  factory PomdamAlias.fromMap(Map<String, dynamic> map) {
    return PomdamAlias(
      id: map['id'] as String,
      pomdamId: map['pomdam_id'] as String,
      sourceValue: map['source_value'] as String,
      aliasType: map['alias_type'] as String,
      sourcePeriod: map['source_period'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class ReportType {
  const ReportType({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final bool active;
  final DateTime createdAt;

  factory ReportType.fromMap(Map<String, dynamic> map) {
    return ReportType(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class ReportPeriod {
  const ReportPeriod({
    required this.id,
    required this.periodType,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.reportYear,
    required this.fiscalYear,
    required this.sourceLabel,
    required this.createdAt,
  });

  final String id;
  final String periodType;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String periodLabel;
  final int? reportYear;
  final int? fiscalYear;
  final String? sourceLabel;
  final DateTime createdAt;

  factory ReportPeriod.fromMap(Map<String, dynamic> map) {
    return ReportPeriod(
      id: map['id'] as String,
      periodType: map['period_type'] as String,
      periodStart: _parseDate(map['period_start']),
      periodEnd: _parseDate(map['period_end']),
      periodLabel: map['period_label'] as String,
      reportYear: (map['report_year'] as num?)?.toInt(),
      fiscalYear: (map['fiscal_year'] as num?)?.toInt(),
      sourceLabel: map['source_label'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class PersonnelCategory {
  const PersonnelCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory PersonnelCategory.fromMap(Map<String, dynamic> map) {
    return PersonnelCategory(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class SimType {
  const SimType({
    required this.id,
    required this.code,
    required this.displayName,
    required this.sourceLabel,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String displayName;
  final String? sourceLabel;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory SimType.fromMap(Map<String, dynamic> map) {
    return SimType(
      id: map['id'] as String,
      code: map['code'] as String,
      displayName: map['display_name'] as String,
      sourceLabel: map['source_label'] as String?,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class AccidentType {
  const AccidentType({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory AccidentType.fromMap(Map<String, dynamic> map) {
    return AccidentType(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class VictimOutcome {
  const VictimOutcome({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory VictimOutcome.fromMap(Map<String, dynamic> map) {
    return VictimOutcome(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class VehicleCategory {
  const VehicleCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory VehicleCategory.fromMap(Map<String, dynamic> map) {
    return VehicleCategory(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class MaterialDamageType {
  const MaterialDamageType({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory MaterialDamageType.fromMap(Map<String, dynamic> map) {
    return MaterialDamageType(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class EducationStatus {
  const EducationStatus({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory EducationStatus.fromMap(Map<String, dynamic> map) {
    return EducationStatus(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final class ProvosStrengthMeasure {
  const ProvosStrengthMeasure({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final bool active;
  final DateTime createdAt;

  factory ProvosStrengthMeasure.fromMap(Map<String, dynamic> map) {
    return ProvosStrengthMeasure(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      displayOrder: (map['display_order'] as num).toInt(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}
