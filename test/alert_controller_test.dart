import 'dart:async';

import 'package:aplicativo/alert/alert_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<void> falls;
  late int emergencies;
  late AlertController alert;

  setUp(() {
    falls = StreamController<void>.broadcast();
    emergencies = 0;
    alert = AlertController(
      falls: falls.stream,
      secondsToAnswer: 3,
      onEmergency: () => emergencies++,
      tick: const Duration(milliseconds: 10),
    );
  });
  tearDown(() => alert.dispose());

  Future<void> fall() async {
    falls.add(null);
    await Future<void>.delayed(Duration.zero);
  }

  test('queda abre a pergunta', () async {
    await fall();
    expect(alert.state, AlertState.pending);
  });

  test('SIM aciona a emergência', () async {
    await fall();
    alert.confirmFall();
    expect(alert.state, AlertState.emergency);
    expect(emergencies, 1);
  });

  test('NÃO volta ao normal sem emergência', () async {
    await fall();
    alert.dismiss();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(alert.state, AlertState.idle);
    expect(emergencies, 0);
  });

  test('sem resposta aciona a emergência uma única vez', () async {
    await fall();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(alert.state, AlertState.emergency);
    expect(emergencies, 1);
  });

  test('queda durante um alerta é ignorada', () async {
    await fall();
    await fall();
    alert.dismiss();
    expect(alert.state, AlertState.idle);
  });
}
