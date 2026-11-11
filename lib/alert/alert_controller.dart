import 'dart:async';

import 'package:flutter/foundation.dart';

enum AlertState { idle, pending, emergency }

/// Regra do alerta: queda → pergunta com contagem → SIM/tempo esgotado = emergência, NÃO = alarme falso.
class AlertController extends ChangeNotifier {
  AlertController({
    required Stream<void> falls,
    required this.secondsToAnswer,
    required this.onEmergency,
    this.tick = const Duration(seconds: 1),
  }) {
    _sub = falls.listen((_) => _start());
  }

  final int secondsToAnswer;
  final VoidCallback onEmergency;
  final Duration tick; // injetável para o teste não esperar 30 s

  AlertState state = AlertState.idle;
  int secondsLeft = 0;
  Timer? _timer;
  late final StreamSubscription<void> _sub;

  void _start() {
    if (state != AlertState.idle) return; // ignora quedas durante um alerta
    state = AlertState.pending;
    secondsLeft = secondsToAnswer;
    _timer = Timer.periodic(tick, (_) {
      if (--secondsLeft <= 0) {
        _emergency();
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Botão SIM.
  void confirmFall() {
    if (state == AlertState.pending) _emergency();
  }

  /// Botão NÃO (alarme falso) ou fechar a tela de emergência.
  void dismiss() {
    _timer?.cancel();
    state = AlertState.idle;
    notifyListeners();
  }

  void _emergency() {
    _timer?.cancel();
    state = AlertState.emergency;
    notifyListeners();
    onEmergency();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub.cancel();
    super.dispose();
  }
}
