import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'alert/alert_controller.dart';
import 'core/constants.dart';
import 'data/ble_service.dart';
import 'data/emergency_service.dart';
import 'data/settings_store.dart';
import 'ui/home_screen.dart';
import 'ui/splash_gate.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsStore.load();
  final ble = BleService();
  final alert = AlertController(
    falls: ble.falls,
    secondsToAnswer: kResponseSeconds,
    onEmergency: () => callEmergencyContact(settings.phone),
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: ble),
      ChangeNotifierProvider.value(value: alert),
    ],
    child: MaterialApp(
      title: 'Guardião',
      theme: guardiaoTheme,
      home: const SplashGate(child: HomeScreen()),
    ),
  ));
}
