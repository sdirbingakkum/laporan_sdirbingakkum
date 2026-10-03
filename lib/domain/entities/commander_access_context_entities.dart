import 'package:flutter/foundation.dart';

abstract final class CommanderCapabilities {
  static const viewCommanderCop = 'VIEW_COMMANDER_COP';
  static const viewDomainData = 'VIEW_DOMAIN_DATA';
  static const viewReports = 'VIEW_REPORTS';
  static const viewDataQuality = 'VIEW_DATA_QUALITY';
  static const viewPomdamDirectory = 'VIEW_POMDAM_DIRECTORY';
  static const manageReportData = 'MANAGE_REPORT_DATA';
  static const verifyReportData = 'VERIFY_REPORT_DATA';
}

enum CommanderAccessScopeType {
  allPomdam,
  pomdam,
  none;

  static CommanderAccessScopeType fromCode(String? value) {
    return switch (value) {
      'ALL_POMDAM' => CommanderAccessScopeType.allPomdam,
      'POMDAM' => CommanderAccessScopeType.pomdam,
      _ => CommanderAccessScopeType.none,
    };
  }
}

enum CommanderAccessRole {
  puspomadCommander('PUSPOMAD_COMMANDER'),
  puspomadDeputyCommander('PUSPOMAD_DEPUTY_COMMANDER'),
  puspomadDirbingakkum('PUSPOMAD_DIRBINGAKKUM'),
  puspomadOperator('PUSPOMAD_OPERATOR'),
  pomdamCommander('POMDAM_COMMANDER'),
  pomdamOperator('POMDAM_OPERATOR'),
  unknown('');

  const CommanderAccessRole(this.code);

  final String code;

  static CommanderAccessRole fromCode(String? value) {
    return CommanderAccessRole.values.firstWhere(
      (role) => role.code.isNotEmpty && role.code == value,
      orElse: () => CommanderAccessRole.unknown,
    );
  }

  bool get isPuspomad => switch (this) {
        CommanderAccessRole.puspomadCommander ||
        CommanderAccessRole.puspomadDeputyCommander ||
        CommanderAccessRole.puspomadDirbingakkum ||
        CommanderAccessRole.puspomadOperator =>
          true,
        _ => false,
      };

  bool get isPomdam => switch (this) {
        CommanderAccessRole.pomdamCommander ||
        CommanderAccessRole.pomdamOperator =>
          true,
        _ => false,
      };

  bool get isOperator => switch (this) {
        CommanderAccessRole.puspomadOperator ||
        CommanderAccessRole.pomdamOperator =>
          true,
        _ => false,
      };
}

@immutable
final class CommanderAccessRoleInfo {
  const CommanderAccessRoleInfo({
    required this.code,
    required this.displayName,
  });

  final String code;
  final String displayName;

  CommanderAccessRole get role => CommanderAccessRole.fromCode(code);

  factory CommanderAccessRoleInfo.fromMap(Map<String, dynamic> map) {
    return CommanderAccessRoleInfo(
      code: map['code'] as String? ?? '',
      displayName: map['display_name'] as String? ?? '',
    );
  }
}

@immutable
final class CommanderAccessContext {
  const CommanderAccessContext({
    required this.schemaVersion,
    required this.authenticated,
    required this.configured,
    required this.role,
    required this.scopeType,
    required this.pomdamIds,
    required this.capabilities,
  });

  final int schemaVersion;
  final bool authenticated;
  final bool configured;
  final CommanderAccessRoleInfo? role;
  final CommanderAccessScopeType scopeType;
  final List<String> pomdamIds;
  final Set<String> capabilities;

  bool get isAuthorized =>
      authenticated &&
      configured &&
      role != null &&
      role!.role != CommanderAccessRole.unknown;

  bool get isAllPomdam =>
      isAuthorized && scopeType == CommanderAccessScopeType.allPomdam;

  bool get isPomdamScoped =>
      isAuthorized && scopeType == CommanderAccessScopeType.pomdam;

  bool get isPuspomad => isAuthorized && role!.role.isPuspomad;

  bool get isPomdam => isAuthorized && role!.role.isPomdam;

  bool hasCapability(String capability) =>
      isAuthorized && capabilities.contains(capability);

  bool get canUseCommanderDashboard =>
      hasCapability(CommanderCapabilities.viewCommanderCop);

  bool get isOperator => isAuthorized && role!.role.isOperator;

  String get defaultLocation {
    if (canUseCommanderDashboard) return '/';
    if (hasCapability(CommanderCapabilities.viewReports)) return '/reports';
    if (hasCapability(CommanderCapabilities.viewDomainData)) return '/gakkum';
    if (hasCapability(CommanderCapabilities.viewDataQuality)) {
      return '/data-quality';
    }
    if (hasCapability(CommanderCapabilities.viewPomdamDirectory)) {
      return '/pomdam';
    }
    return '/access-denied';
  }

  bool canReadPomdam(String pomdamId) {
    if (!isAuthorized) return false;
    if (isAllPomdam) return true;
    return pomdamIds.contains(pomdamId);
  }

  factory CommanderAccessContext.fromMap(Map<String, dynamic> map) {
    final roleMap = map['role'];
    final scopeMap = map['scope'];
    final rawPomdamIds = scopeMap is Map ? scopeMap['pomdam_ids'] : null;
    final rawCapabilities = map['capabilities'];

    final pomdamIds = <String>[
      if (rawPomdamIds is List)
        for (final item in rawPomdamIds)
          if (item is String && item.isNotEmpty) item,
    ];

    final capabilities = <String>{
      if (rawCapabilities is List)
        for (final item in rawCapabilities)
          if (item is String && item.isNotEmpty) item,
    };

    return CommanderAccessContext(
      schemaVersion: _toInt(map['schema_version'], fallback: 1),
      authenticated: map['authenticated'] as bool? ?? false,
      configured: map['configured'] as bool? ?? false,
      role: roleMap is Map
          ? CommanderAccessRoleInfo.fromMap(
              Map<String, dynamic>.from(roleMap),
            )
          : null,
      scopeType: CommanderAccessScopeType.fromCode(
        scopeMap is Map ? scopeMap['type'] as String? : null,
      ),
      pomdamIds: List.unmodifiable(pomdamIds),
      capabilities: Set.unmodifiable(capabilities),
    );
  }
}

int _toInt(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
