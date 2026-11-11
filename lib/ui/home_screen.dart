import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../alert/alert_controller.dart';
import '../data/settings_store.dart';
import 'sheet_layout.dart';
import 'status_view.dart';
import 'theme.dart';

/// Uma tela só: o estado do alerta decide o que aparece.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alert = context.watch<AlertController>();
    return Scaffold(
      body: switch (alert.state) {
        AlertState.idle => const StatusView(),
        AlertState.pending => _QuestionView(alert),
        AlertState.emergency => _EmergencyView(alert),
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView(this.alert);
  final AlertController alert;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SheetLayout(
      header: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            width: 190,
            height: 190,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: alert.secondsLeft / alert.secondsToAnswer,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
              Text('${alert.secondsLeft}', style: const TextStyle(fontSize: 76, fontWeight: FontWeight.w900, color: Colors.white)),
            ]),
          ),
        ),
      ),
      sheet: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Você caiu?', style: text.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Sem resposta, vamos avisar o seu contato de emergência.',
            style: text.bodyLarge?.copyWith(color: kInk.withValues(alpha: .65))),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(76), backgroundColor: kRed),
          onPressed: alert.confirmFall,
          child: const Text('Sim, caí'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(76), backgroundColor: kInk),
          onPressed: alert.dismiss,
          child: const Text('Não, estou bem'),
        ),
      ]),
    );
  }
}

class _EmergencyView extends StatelessWidget {
  const _EmergencyView(this.alert);
  final AlertController alert;

  @override
  Widget build(BuildContext context) {
    final noContact = context.read<SettingsStore>().phone.isEmpty;
    final text = Theme.of(context).textTheme;
    return SheetLayout(
      headerFraction: .38,
      headerColors: const [kInk, kRedDeep],
      header: const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.notifications_active_rounded, size: 110, color: Colors.white),
        ),
      ),
      sheet: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Emergência acionada', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
        if (noContact) ...[
          const SizedBox(height: 8),
          const Text('Nenhum contato cadastrado!', style: TextStyle(color: kRedDeep, fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 32),
        FilledButton(onPressed: alert.dismiss, child: const Text('Fechar')),
      ]),
    );
  }
}
