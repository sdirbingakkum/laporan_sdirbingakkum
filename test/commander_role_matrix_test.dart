import 'package:flutter_test/flutter_test.dart';

import 'package:laporan_sdirbingakkum/domain/entities/commander_access_context_entities.dart';

void main() {
  const commonReadCapabilities = [
    CommanderCapabilities.viewDomainData,
    CommanderCapabilities.viewReports,
    CommanderCapabilities.viewDataQuality,
    CommanderCapabilities.viewPomdamDirectory,
  ];

  const commanderRoles = {
    'PUSPOMAD_COMMANDER',
    'PUSPOMAD_DEPUTY_COMMANDER',
    'PUSPOMAD_DIRBINGAKKUM',
    'POMDAM_COMMANDER',
  };

  const allPomdamRoles = {
    'PUSPOMAD_COMMANDER',
    'PUSPOMAD_DEPUTY_COMMANDER',
    'PUSPOMAD_DIRBINGAKKUM',
    'PUSPOMAD_OPERATOR',
  };

  const pomdamRoles = {
    'POMDAM_COMMANDER',
    'POMDAM_OPERATOR',
  };

  for (final roleCode in [
    'PUSPOMAD_COMMANDER',
    'PUSPOMAD_DEPUTY_COMMANDER',
    'PUSPOMAD_DIRBINGAKKUM',
    'PUSPOMAD_OPERATOR',
    'POMDAM_COMMANDER',
    'POMDAM_OPERATOR',
  ]) {
    test('$roleCode authorization matrix', () {
      final capabilities = <String>[
        ...commonReadCapabilities,
        if (commanderRoles.contains(roleCode))
          CommanderCapabilities.viewCommanderCop,
      ];

      final isAllPomdam = allPomdamRoles.contains(roleCode);
      final isPomdamScoped = pomdamRoles.contains(roleCode);

      final context = CommanderAccessContext.fromMap({
        'schema_version': 2,
        'authenticated': true,
        'configured': true,
        'role': {
          'code': roleCode,
          'display_name': roleCode,
        },
        'scope': {
          'type': isAllPomdam ? 'ALL_POMDAM' : 'POMDAM',
          'pomdam_ids': isAllPomdam ? [] : ['pomdam-a'],
        },
        'capabilities': capabilities,
      });

      expect(context.isAuthorized, isTrue);
      expect(context.isAllPomdam, isAllPomdam);
      expect(context.isPomdamScoped, isPomdamScoped);
      expect(
        context.canUseCommanderDashboard,
        commanderRoles.contains(roleCode),
      );
      expect(context.isOperator, roleCode.endsWith('OPERATOR'));
      expect(
        context.defaultLocation,
        commanderRoles.contains(roleCode) ? '/' : '/reports',
      );

      for (final capability in commonReadCapabilities) {
        expect(context.hasCapability(capability), isTrue);
      }

      expect(
        context.hasCapability(CommanderCapabilities.manageReportData),
        isFalse,
      );
      expect(
        context.hasCapability(CommanderCapabilities.verifyReportData),
        isFalse,
      );

      expect(context.canReadPomdam('pomdam-a'), isTrue);
      expect(
        context.canReadPomdam('pomdam-b'),
        isAllPomdam ? isTrue : isFalse,
      );
    });
  }
}
