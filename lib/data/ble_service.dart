import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants.dart';

enum BleStatus { disconnected, connecting, connected }

const _notTheWatch = 'Este aparelho não é o relógio Guardião';

/// Conecta ao relógio escolhido pelo usuário e emite um evento em [falls] a cada mensagem `QUEDA`.
class BleService extends ChangeNotifier {
  final _falls = StreamController<void>.broadcast();
  Stream<void> get falls => _falls.stream;

  BleStatus status = BleStatus.disconnected;
  String? error;
  bool _wantConnected = false;
  BluetoothDevice? _device;
  StreamSubscription<void>? _stateSub, _valueSub;

  /// Para testar sem o relógio.
  void simulateFall() => _falls.add(null);

  /// Pede permissão e procura aparelhos; o resultado chega em [FlutterBluePlus.scanResults].
  Future<void> startScan() async {
    error = null;
    notifyListeners();
    try {
      await _requestPermissions();
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// Aparelhos já pareados no Android (não anunciam, então o scan não os mostra).
  Future<List<BluetoothDevice>> pairedDevices() async {
    try {
      await _requestPermissions();
      return await FlutterBluePlus.bondedDevices;
    } catch (_) {
      return [];
    }
  }

  Future<void> connectTo(BluetoothDevice device) async {
    _device = device;
    _wantConnected = true;
    error = null;
    _set(BleStatus.connecting);
    try {
      await FlutterBluePlus.stopScan();
      await device.connect(license: License.nonprofit); // licença do flutter_blue_plus: uso pessoal/educacional; comercial exige outra
      _stateSub?.cancel();
      _stateSub = device.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) _onLost();
      });

      final services = await device.discoverServices();
      final char = services
          .firstWhere((s) => s.uuid == Guid(kServiceUuid), orElse: () => throw _notTheWatch)
          .characteristics
          .firstWhere((c) => c.uuid == Guid(kNotifyCharUuid), orElse: () => throw _notTheWatch);
      await char.setNotifyValue(true);
      _valueSub?.cancel();
      _valueSub = char.onValueReceived.listen((v) {
        if (utf8.decode(v, allowMalformed: true).trim() == kFallMessage) _falls.add(null);
      });
      _set(BleStatus.connected);
    } catch (e) {
      error = e.toString();
      if (e == _notTheWatch) {
        _wantConnected = false;
        await device.disconnect();
      }
      _onLost();
    }
  }

  Future<void> disconnect() async {
    _wantConnected = false;
    await _device?.disconnect();
    _set(BleStatus.disconnected);
  }

  Future<void> _requestPermissions() async {
    final perms = await [Permission.bluetoothScan, Permission.bluetoothConnect].request();
    if (perms.values.any((p) => !p.isGranted)) throw 'Permissão de Bluetooth negada';
  }

  // Tenta reconectar sozinho enquanto o usuário não pediu para desconectar.
  void _onLost() {
    _set(BleStatus.disconnected);
    if (!_wantConnected) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (_wantConnected && status == BleStatus.disconnected) connectTo(_device!);
    });
  }

  void _set(BleStatus s) {
    status = s;
    notifyListeners();
  }
}
