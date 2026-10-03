import 'package:flutter_test/flutter_test.dart';

import 'package:laporan_sdirbingakkum/domain/entities/commander_access_context_entities.dart';

void main() {
  test('parses Puspomad commander as ALL_POMDAM commander', () {
    final context = CommanderAccessContext.fromMap({
      'schema_version': 1,
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
    });

    expect(context.isAuthorized, isTrue);
    expect(context.isAllPomdam, isTrue);
    expect(context.isPuspomad, isTrue);
    expect(context.canUseCommanderDashboard, isTrue);
    expect(context.defaultLocation, '/');
    expect(context.canReadPomdam('any-id'), isTrue);
  });

  test('parses Pomdam operator as single-POMDAM operator', () {
    final context = CommanderAccessContext.fromMap({
      'schema_version': 1,
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
    });

    expect(context.isAuthorized, isTrue);
    expect(context.isPomdamScoped, isTrue);
    expect(context.isOperator, isTrue);
    expect(context.canUseCommanderDashboard, isFalse);
    expect(context.defaultLocation, '/reports');
    expect(context.canReadPomdam('pomdam-a'), isTrue);
    expect(context.canReadPomdam('pomdam-b'), isFalse);
  });

  test('unknown or unconfigured context fails closed', () {
    final context = CommanderAccessContext.fromMap({
      'schema_version': 1,
      'authenticated': true,
      'configured': false,
      'role': null,
      'scope': {
        'type': null,
        'pomdam_ids': [],
      },
    });

    expect(context.isAuthorized, isFalse);
    expect(context.canUseCommanderDashboard, isFalse);
    expect(context.defaultLocation, '/access-denied');
    expect(context.canReadPomdam('any-id'), isFalse);
  });
}
