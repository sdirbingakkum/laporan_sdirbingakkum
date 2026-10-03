import 'package:flutter_test/flutter_test.dart';

import 'package:laporan_sdirbingakkum/domain/entities/commander_access_context_entities.dart';

void main() {
  test('Puspomad commander gets Commander COP capability', () {
    final context = CommanderAccessContext.fromMap({
      'schema_version': 2,
      'authenticated': true,
      'configured': true,
      'role': {
        'code': 'PUSPOMAD_COMMANDER',
        'display_name': 'Komandan Puspomad',
      },
      'scope': {
        'type': 'ALL_POMDAM',
        'pomdam_ids': [],
      },
      'capabilities': [
        CommanderCapabilities.viewCommanderCop,
        CommanderCapabilities.viewDomainData,
        CommanderCapabilities.viewReports,
        CommanderCapabilities.viewDataQuality,
        CommanderCapabilities.viewPomdamDirectory,
      ],
    });

    expect(context.isAuthorized, isTrue);
    expect(context.isAllPomdam, isTrue);
    expect(context.isPuspomad, isTrue);
    expect(context.canUseCommanderDashboard, isTrue);
    expect(
      context.hasCapability(CommanderCapabilities.viewReports),
      isTrue,
    );
    expect(context.defaultLocation, '/');
    expect(context.canReadPomdam('any-id'), isTrue);
  });

  test('Pomdam operator gets read capabilities but not Commander COP', () {
    final context = CommanderAccessContext.fromMap({
      'schema_version': 2,
      'authenticated': true,
      'configured': true,
      'role': {
        'code': 'POMDAM_OPERATOR',
        'display_name': 'Operator Pomdam',
      },
      'scope': {
        'type': 'POMDAM',
        'pomdam_ids': ['pomdam-a'],
      },
      'capabilities': [
        CommanderCapabilities.viewDomainData,
        CommanderCapabilities.viewReports,
        CommanderCapabilities.viewDataQuality,
        CommanderCapabilities.viewPomdamDirectory,
      ],
    });

    expect(context.isAuthorized, isTrue);
    expect(context.isPomdamScoped, isTrue);
    expect(context.isOperator, isTrue);
    expect(context.canUseCommanderDashboard, isFalse);
    expect(
      context.hasCapability(CommanderCapabilities.viewCommanderCop),
      isFalse,
    );
    expect(
      context.hasCapability(CommanderCapabilities.manageReportData),
      isFalse,
    );
    expect(context.defaultLocation, '/reports');
    expect(context.canReadPomdam('pomdam-a'), isTrue);
    expect(context.canReadPomdam('pomdam-b'), isFalse);
  });

  test('unknown or unconfigured context fails closed', () {
    final context = CommanderAccessContext.fromMap({
      'schema_version': 2,
      'authenticated': true,
      'configured': false,
      'role': null,
      'scope': {
        'type': null,
        'pomdam_ids': [],
      },
      'capabilities': [],
    });

    expect(context.isAuthorized, isFalse);
    expect(context.canUseCommanderDashboard, isFalse);
    expect(context.defaultLocation, '/access-denied');
    expect(context.canReadPomdam('any-id'), isFalse);
  });
}
