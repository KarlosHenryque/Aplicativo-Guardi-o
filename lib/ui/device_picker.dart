import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../data/ble_service.dart';
import 'theme.dart';

/// Lista para escolher o relógio: aparelhos pareados + os que o Bluetooth encontra por perto.
Future<void> showDevicePicker(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _DevicePicker(),
    );

class _Entry {
  _Entry(this.device, this.name, this.rssi);
  final BluetoothDevice device;
  final String name;
  final int? rssi; // null = só pareado, não visto no scan
}

class _DevicePicker extends StatefulWidget {
  const _DevicePicker();
  @override
  State<_DevicePicker> createState() => _DevicePickerState();
}

class _DevicePickerState extends State<_DevicePicker> {
  late final BleService _ble = context.read<BleService>();
  List<BluetoothDevice> _paired = [];

  @override
  void initState() {
    super.initState();
    _ble.startScan();
    _ble.pairedDevices().then((d) {
      if (mounted) setState(() => _paired = d);
    });
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  List<_Entry> _entries(List<ScanResult> scan) {
    final byId = <String, _Entry>{
      for (final d in _paired) d.remoteId.str: _Entry(d, d.platformName, null),
    };
    for (final r in scan) {
      final name = r.advertisementData.advName.isNotEmpty ? r.advertisementData.advName : r.device.platformName;
      if (name.isNotEmpty) byId[r.device.remoteId.str] = _Entry(r.device, name, r.rssi);
    }
    return byId.values.toList()
      ..sort((a, b) {
        final wa = a.name == 'RelogioQueda' ? 0 : 1, wb = b.name == 'RelogioQueda' ? 0 : 1;
        return wa != wb ? wa - wb : a.name.compareTo(b.name);
      });
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<BleService>().error;
    return SizedBox(
      height: MediaQuery.of(context).size.height * .6,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
          child: Row(children: [
            Expanded(child: Text('Escolha o relógio', style: Theme.of(context).textTheme.titleLarge)),
            StreamBuilder<bool>(
              stream: FlutterBluePlus.isScanning,
              initialData: true,
              builder: (context, s) => s.data!
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(onPressed: _ble.startScan, child: const Text('Procurar de novo')),
            ),
          ]),
        ),
        if (error != null)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(error, style: const TextStyle(color: kRedDeep, fontWeight: FontWeight.w600))),
        Expanded(
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: const [],
            builder: (context, s) {
              final list = _entries(s.data!);
              if (list.isEmpty) return const Center(child: Text('Nenhum aparelho encontrado ainda.'));
              return ListView(children: [
                for (final e in list)
                  ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(e.name),
                    subtitle: Text(e.rssi == null ? 'Pareado' : 'Sinal ${e.rssi} dBm'),
                    onTap: () {
                      Navigator.pop(context);
                      _ble.connectTo(e.device);
                    },
                  ),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}
