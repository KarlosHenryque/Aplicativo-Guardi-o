import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ble_service.dart';
import '../data/settings_store.dart';
import 'device_picker.dart';
import 'sheet_layout.dart';
import 'theme.dart';

/// Tela principal: a "lanterna" no cabeçalho mostra se o relógio está vigiando.
class StatusView extends StatefulWidget {
  const StatusView({super.key});
  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final _phone = TextEditingController(text: context.read<SettingsStore>().phone);

  @override
  void dispose() {
    _anim.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleService>();
    final status = ble.status;
    final text = Theme.of(context).textTheme;

    // Só anima quando há o que mostrar (conectado/conectando) e o sistema permite.
    final animate = status != BleStatus.disconnected && !MediaQuery.of(context).disableAnimations;
    if (animate && !_anim.isAnimating) _anim.repeat();
    if (!animate && _anim.isAnimating) _anim.stop();

    final (title, subtitle) = switch (status) {
      BleStatus.connected => ('Você está protegido.', 'Se você cair, eu pergunto se está bem.'),
      BleStatus.connecting => ('Conectando…', 'Aguarde um instante.'),
      BleStatus.disconnected => ('Sem proteção.', 'O relógio não está conectado.'),
    };

    return SheetLayout(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(children: [
          Row(children: [
            ClipOval(child: Image.asset('assets/logo.png', width: 44, height: 44)),
            const SizedBox(width: 12),
            const Wordmark(size: 30),
          ]),
          Expanded(
            child: Semantics(
              label: title,
              excludeSemantics: true,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, child) => CustomPaint(size: Size.infinite, painter: _LanternPainter(_anim.value, status)),
              ),
            ),
          ),
        ]),
      ),
      sheet: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
        const SizedBox(height: 8),
        Text(subtitle, style: text.bodyLarge?.copyWith(color: kInk.withValues(alpha: .65))),
        if (ble.error != null) ...[
          const SizedBox(height: 12),
          Text(ble.error!, style: const TextStyle(color: kRedDeep, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 28),
        switch (status) {
          BleStatus.connected => OutlinedButton(onPressed: ble.disconnect, child: const Text('Desconectar')),
          BleStatus.connecting => const FilledButton(onPressed: null, child: Text('Conectando…')),
          BleStatus.disconnected =>
            FilledButton(onPressed: () => showDevicePicker(context), child: const Text('Conectar ao relógio')),
        },
        const SizedBox(height: 32),
        Text('Quem devo avisar numa queda', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '(11) 90000-0000', prefixIcon: Icon(Icons.favorite, color: kRed)),
          onChanged: context.read<SettingsStore>().setPhone,
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 24),
          TextButton(onPressed: ble.simulateFall, child: const Text('Simular queda (debug)')),
        ],
      ]),
    );
  }
}

class _LanternPainter extends CustomPainter {
  _LanternPainter(this.t, this.status);
  final double t; // 0..1, ciclo de 4 s
  final BleStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final lit = status == BleStatus.connected;
    final breath = (1 - math.cos(2 * math.pi * t)) / 2; // 0..1..0

    if (lit) {
      final glow = Paint()
        ..shader = RadialGradient(colors: [kAmber.withValues(alpha: .7), kAmber.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: c, radius: r * (0.8 + 0.2 * breath)));
      canvas.drawCircle(c, r, glow);
    }

    for (var i = 0; i < 3; i++) {
      final radius = r * (0.4 + 0.22 * i) + (lit ? r * 0.04 * breath * (i + 1) : 0);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: lit ? .85 - .22 * i : .25);
      canvas.drawCircle(c, radius, ring);
    }

    if (status == BleStatus.connecting) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = Colors.white;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.62), 2 * math.pi * t * 2, 0.9, false, arc);
    }

    canvas.drawCircle(c, r * 0.16, Paint()..color = Colors.white.withValues(alpha: lit ? 1 : (status == BleStatus.connecting ? .6 : .35)));
  }

  @override
  bool shouldRepaint(_LanternPainter old) => old.t != t || old.status != status;
}
