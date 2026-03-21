import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityLinksSection extends StatelessWidget {
  const SecurityLinksSection({
    super.key,
    required this.onDeleteAccount,
    required this.sectionHeader,
  });

  final VoidCallback onDeleteAccount;
  final Widget Function(String title) sectionHeader;

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final messenger = ScaffoldMessenger.of(context);
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Şifre sıfırlama e-postası $email adresine gönderildi.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeader('Güvenlik & Gizlilik'),
        ListTile(
          leading: const Icon(Icons.lock_reset),
          title: const Text('Şifre Değiştir'),
          onTap: () => _sendPasswordReset(context),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Gizlilik Politikası'),
          onTap: () => launchUrl(Uri.parse('https://nurai.app/privacy')),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Kullanım Şartları'),
          onTap: () => launchUrl(Uri.parse('https://nurai.app/terms')),
        ),
        ListTile(
          leading: const Icon(Icons.support_agent),
          title: const Text('Destek / Geri Bildirim'),
          onTap: () => launchUrl(
            Uri.parse('mailto:destek@nurai.app?subject=Nurai Destek'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Hata Bildir'),
          onTap: () => launchUrl(
            Uri.parse('mailto:destek@nurai.app?subject=Hata Bildirimi'),
          ),
        ),
        sectionHeader('Hesap'),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Hesabı Sil',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Tüm verileriniz kalıcı olarak silinir'),
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}
