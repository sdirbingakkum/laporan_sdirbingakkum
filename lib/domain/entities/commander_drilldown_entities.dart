import 'package:flutter/foundation.dart';

import 'reference_entities.dart';

@immutable
final class CommanderDrilldownSnapshot {
  const CommanderDrilldownSnapshot({
    required this.schemaVersion,
    required this.domainCode,
    required this.domainName,
    required this.scope,
    required this.asOf,
    required this.selectedDimensionCode,
    required this.dimensions,
    required this.records,
  });

  final int schemaVersion;
  final String domainCode;
  final String domainName;
  final CommanderDrilldownScope scope;
  final CommanderDrilldownPeriod? asOf;
  final String? selectedDimensionCode;
  final List<CommanderDrilldownDimension> dimensions;
  final List<CommanderDrilldownRecord> records;

  factory CommanderDrilldownSnapshot.fromMap(Map<String, dynamic> map) {
    final scopeMap = map['scope'];
    final asOfMap = map['as_of'];

    return CommanderDrilldownSnapshot(
      schemaVersion: _toInt(map['schema_version']),
      domainCode: map['domain'] as String? ?? '',
      domainName: map['domain_name'] as String? ?? '',
      scope: CommanderDrilldownScope.fromMap(
        Map<String, dynamic>.from(scopeMap as Map? ?? const {}),
      ),
      asOf: asOfMap is Map
          ? CommanderDrilldownPeriod.fromMap(
              Map<String, dynamic>.from(asOfMap),
            )
          : null,
      selectedDimensionCode: map['selected_dimension_code'] as String?,
      dimensions: [
        for (final item in _mapList(map['dimensions']))
          CommanderDrilldownDimension.fromMap(item),
      ],
      records: [
        for (final item in _mapList(map['records']))
          CommanderDrilldownRecord.fromMap(item),
      ],
    );
  }
}

@immutable
final class CommanderDrilldownScope {
  const CommanderDrilldownScope({
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

  factory CommanderDrilldownScope.fromMap(Map<String, dynamic> map) {
    final pomdam = map['pomdam'] is Map
        ? Map<String, dynamic>.from(map['pomdam'] as Map)
        : null;

    return CommanderDrilldownScope(
      type: map['type'] as String? ?? 'ALL_POMDAM',
      pomdamId: map['pomdam_id'] as String?,
      pomdamCode: pomdam?['code'] as String?,
      pomdamShortName: pomdam?['short_name'] as String?,
      pomdamFullName: pomdam?['full_name'] as String?,
    );
  }
}

@immutable
final class CommanderDrilldownPeriod {
  const CommanderDrilldownPeriod({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
  });

  final String id;
  final String label;
  final DateTime? start;
  final DateTime? end;

  factory CommanderDrilldownPeriod.fromMap(Map<String, dynamic> map) {
    return CommanderDrilldownPeriod(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      start: _parseDate(map['start']),
      end: _parseDate(map['end']),
    );
  }
}

@immutable
final class CommanderDrilldownDimension {
  const CommanderDrilldownDimension({
    required this.code,
    required this.name,
    required this.group,
    required this.factRows,
    required this.validRows,
    required this.notReportedRows,
    required this.invalidSourceRows,
    required this.estimatedRows,
    required this.validTotal,
  });

  final String code;
  final String name;
  final String group;
  final int factRows;
  final int validRows;
  final int notReportedRows;
  final int invalidSourceRows;
  final int estimatedRows;
  final int validTotal;

  factory CommanderDrilldownDimension.fromMap(Map<String, dynamic> map) {
    return CommanderDrilldownDimension(
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Tanpa nama',
      group: map['group']?.toString() ?? '',
      factRows: _toInt(map['fact_rows']),
      validRows: _toInt(map['valid_rows']),
      notReportedRows: _toInt(map['not_reported_rows']),
      invalidSourceRows: _toInt(map['invalid_source_rows']),
      estimatedRows: _toInt(map['estimated_rows']),
      validTotal: _toInt(map['valid_total']),
    );
  }
}

@immutable
final class CommanderDrilldownRecord {
  const CommanderDrilldownRecord({
    required this.recordId,
    required this.pomdamId,
    required this.pomdamCode,
    required this.pomdamShortName,
    required this.periodId,
    required this.periodLabel,
    required this.dimensionCode,
    required this.dimensionName,
    required this.dimensionGroup,
    required this.secondaryCode,
    required this.secondaryName,
    required this.value,
    required this.dataStatus,
    required this.sourceCellId,
    required this.notes,
  });

  final String recordId;
  final String pomdamId;
  final String pomdamCode;
  final String pomdamShortName;
  final String periodId;
  final String periodLabel;
  final String dimensionCode;
  final String dimensionName;
  final String dimensionGroup;
  final String? secondaryCode;
  final String? secondaryName;
  final num? value;
  final DataStatus dataStatus;
  final String? sourceCellId;
  final String? notes;

  bool get hasSource => sourceCellId != null && sourceCellId!.isNotEmpty;

  factory CommanderDrilldownRecord.fromMap(Map<String, dynamic> map) {
    return CommanderDrilldownRecord(
      recordId: map['record_id'] as String? ?? '',
      pomdamId: map['pomdam_id'] as String? ?? '',
      pomdamCode: map['pomdam_code'] as String? ?? '',
      pomdamShortName: map['pomdam_short_name'] as String? ?? '',
      periodId: map['period_id'] as String? ?? '',
      periodLabel: map['period_label'] as String? ?? '',
      dimensionCode: map['dimension_code']?.toString() ?? '',
      dimensionName: map['dimension_name']?.toString() ?? 'Tanpa nama',
      dimensionGroup: map['dimension_group']?.toString() ?? '',
      secondaryCode: map['secondary_code'] as String?,
      secondaryName: map['secondary_name'] as String?,
      value: map['value'] as num?,
      dataStatus: DataStatus.fromDatabase(
        map['data_status'] as String? ?? 'VALID',
      ),
      sourceCellId: map['source_cell_id'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

@immutable
final class CommanderFactProvenance {
  const CommanderFactProvenance({
    required this.recordId,
    required this.domain,
    required this.pomdamCode,
    required this.pomdamShortName,
    required this.period,
    required this.source,
  });

  final String recordId;
  final String domain;
  final String pomdamCode;
  final String pomdamShortName;
  final CommanderDrilldownPeriod period;
  final CommanderSourceTrace source;

  factory CommanderFactProvenance.fromMap(Map<String, dynamic> map) {
    final pomdamMap = map['pomdam'];
    final periodMap = map['period'];
    final sourceMap = map['source'];

    return CommanderFactProvenance(
      recordId: map['record_id'] as String? ?? '',
      domain: map['domain'] as String? ?? '',
      pomdamCode: pomdamMap is Map
          ? pomdamMap['code']?.toString() ?? ''
          : '',
      pomdamShortName: pomdamMap is Map
          ? pomdamMap['short_name']?.toString() ?? ''
          : '',
      period: CommanderDrilldownPeriod.fromMap(
        Map<String, dynamic>.from(periodMap as Map? ?? const {}),
      ),
      source: CommanderSourceTrace.fromMap(
        Map<String, dynamic>.from(sourceMap as Map? ?? const {}),
      ),
    );
  }
}

@immutable
final class CommanderSourceTrace {
  const CommanderSourceTrace({
    required this.status,
    required this.sourceCellId,
    required this.sourceReportId,
    required this.cell,
    required this.workbook,
  });

  final String status;
  final String? sourceCellId;
  final String? sourceReportId;
  final CommanderSourceCell? cell;
  final CommanderSourceWorkbook? workbook;

  bool get found => status == 'FOUND';

  factory CommanderSourceTrace.fromMap(Map<String, dynamic> map) {
    final cellMap = map['cell'];
    final workbookMap = map['workbook'];

    return CommanderSourceTrace(
      status: map['status'] as String? ?? 'NO_SOURCE_CELL',
      sourceCellId: map['source_cell_id'] as String?,
      sourceReportId: map['source_report_id'] as String?,
      cell: cellMap is Map
          ? CommanderSourceCell.fromMap(Map<String, dynamic>.from(cellMap))
          : null,
      workbook: workbookMap is Map
          ? CommanderSourceWorkbook.fromMap(
              Map<String, dynamic>.from(workbookMap),
            )
          : null,
    );
  }
}

@immutable
final class CommanderSourceCell {
  const CommanderSourceCell({
    required this.ref,
    required this.rowNumber,
    required this.columnLetter,
    required this.rawValue,
    required this.formulaText,
    required this.parsedNumeric,
    required this.dataStatus,
    required this.semanticRole,
    required this.rowLabel,
    required this.columnLabel,
  });

  final String ref;
  final int? rowNumber;
  final String columnLetter;
  final String? rawValue;
  final String? formulaText;
  final int? parsedNumeric;
  final String dataStatus;
  final String? semanticRole;
  final String? rowLabel;
  final String? columnLabel;

  factory CommanderSourceCell.fromMap(Map<String, dynamic> map) {
    return CommanderSourceCell(
      ref: map['ref'] as String? ?? '',
      rowNumber: (map['row_number'] as num?)?.toInt(),
      columnLetter: map['column_letter'] as String? ?? '',
      rawValue: map['raw_value'] as String?,
      formulaText: map['formula_text'] as String?,
      parsedNumeric: (map['parsed_numeric'] as num?)?.toInt(),
      dataStatus: map['data_status'] as String? ?? '',
      semanticRole: map['semantic_role'] as String?,
      rowLabel: map['row_label'] as String?,
      columnLabel: map['column_label'] as String?,
    );
  }
}

@immutable
final class CommanderSourceWorkbook {
  const CommanderSourceWorkbook({
    required this.id,
    required this.name,
    required this.sheet,
    required this.sheetIndex,
    required this.importStatus,
    required this.sheetState,
    required this.sheetRole,
    required this.periodResolutionStatus,
  });

  final String id;
  final String name;
  final String sheet;
  final int? sheetIndex;
  final String importStatus;
  final String sheetState;
  final String sheetRole;
  final String periodResolutionStatus;

  factory CommanderSourceWorkbook.fromMap(Map<String, dynamic> map) {
    return CommanderSourceWorkbook(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      sheet: map['sheet'] as String? ?? '',
      sheetIndex: (map['sheet_index'] as num?)?.toInt(),
      importStatus: map['import_status'] as String? ?? '',
      sheetState: map['sheet_state'] as String? ?? '',
      sheetRole: map['sheet_role'] as String? ?? '',
      periodResolutionStatus:
          map['period_resolution_status'] as String? ?? '',
    );
  }
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const [];

  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
