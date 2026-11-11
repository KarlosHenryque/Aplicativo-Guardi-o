import 'package:url_launcher/url_launcher.dart';

// shortcut: abre o discador com o número pronto (1 toque para ligar);
// envio automático de SMS exigiria a permissão SEND_SMS, adicionar se necessário.
Future<void> callEmergencyContact(String phone) async {
  if (phone.isEmpty) return;
  await launchUrl(Uri(scheme: 'tel', path: phone));
}
