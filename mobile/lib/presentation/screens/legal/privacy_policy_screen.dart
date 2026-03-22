import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// URL for the hosted privacy policy (GitHub Pages).
/// Update this constant after GitHub Pages is activated.
const _kPrivacyUrl = 'https://kaantozoglu3-bit.github.io/nurai';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _loadFailed = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
        actions: [
          if (!_loadFailed && !kIsWeb)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Yenile',
              onPressed: () => setState(() {
                _loadFailed = false;
                _isLoading = true;
              }),
            ),
        ],
      ),
      body: _loadFailed || kIsWeb
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: _PolicyContent(),
            )
          : Stack(
              children: [
                InAppWebView(
                  key: ValueKey(_loadFailed),
                  initialUrlRequest: URLRequest(url: WebUri(_kPrivacyUrl)),
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: true,
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  shouldOverrideUrlLoading: (controller, action) async {
                    final uri = action.request.url;
                    if (uri == null) return NavigationActionPolicy.CANCEL;
                    final host = uri.host;
                    // Only allow the trusted privacy policy host; open everything
                    // else externally so the WebView cannot be used as a proxy.
                    const allowedHost = 'kaantozoglu3-bit.github.io';
                    if (host == allowedHost) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    final externalUri = Uri.tryParse(uri.toString());
                    if (externalUri != null &&
                        await canLaunchUrl(externalUri)) {
                      await launchUrl(externalUri,
                          mode: LaunchMode.externalApplication);
                    }
                    return NavigationActionPolicy.CANCEL;
                  },
                  onLoadStop: (controller, url) {
                    if (mounted) setState(() => _isLoading = false);
                  },
                  onReceivedError: (controller, request, error) {
                    if (mounted) {
                      setState(() {
                        _loadFailed = true;
                        _isLoading = false;
                      });
                    }
                  },
                  onReceivedHttpError: (controller, request, response) {
                    if (response.statusCode != null &&
                        response.statusCode! >= 400) {
                      if (mounted) {
                        setState(() {
                          _loadFailed = true;
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gizlilik Politikası',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Son güncelleme: Mart 2025',
          style: textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _Section(
          title: '1. Giriş',
          body:
              'Nurai ("biz", "uygulama") olarak gizliliğinize saygı duyuyoruz. '
              'Bu politika, Nurai mobil uygulamasını kullanırken hangi verileri '
              'topladığımızı, nasıl kullandığımızı ve koruduğumuzu açıklar.',
        ),
        _Section(
          title: '2. Toplanan Veriler',
          body: '• Hesap bilgileri: e-posta adresi, ad\n'
              '• Sağlık profili: yaş, boy, kilo, fitness seviyesi, yaralanma geçmişi\n'
              '• Kullanım verileri: egzersiz geçmişi, ağrı günlüğü kayıtları\n'
              '• Teknik veriler: cihaz bilgisi, uygulama sürümü, hata logları',
        ),
        _Section(
          title: '3. Verilerin Kullanımı',
          body: 'Topladığımız veriler yalnızca şu amaçlarla kullanılır:\n\n'
              '• Size kişiselleştirilmiş egzersiz önerileri sunmak\n'
              '• AI destekli ağrı analizi gerçekleştirmek\n'
              '• Uygulama performansını iyileştirmek\n'
              '• Yasal yükümlülükleri yerine getirmek',
        ),
        _Section(
          title: '4. Veri Paylaşımı',
          body: 'Kişisel verileriniz üçüncü taraflarla satılmaz veya kiralanmaz. '
              'Yalnızca şu durumlarda paylaşılabilir:\n\n'
              '• Hizmet sağlayıcılarımız (Firebase/Google altyapısı)\n'
              '• AI hizmet sağlayıcısı (yalnızca anonim sağlık verileri)\n'
              '• Yasal zorunluluk halinde yetkili makamlar\n'
              '• Fizyoterapist bağlantısı kurduğunuzda, açıkça onayladığınız veriler',
        ),
        _Section(
          title: '5. Veri Güvenliği',
          body: 'Verileriniz Firebase altyapısı üzerinde şifreli olarak saklanır. '
              'SSL/TLS ile iletim güvenliği sağlanmaktadır. '
              'Hesabınıza yalnızca siz erişebilirsiniz.',
        ),
        _Section(
          title: '6. Veri Saklama',
          body: 'Verileriniz hesabınız aktif olduğu sürece saklanır. '
              'Hesabınızı sildiğinizde tüm kişisel verileriniz kalıcı olarak '
              'silinir. Silme işlemi Ayarlar > Hesap > Hesabı Sil menüsünden yapılabilir.',
        ),
        _Section(
          title: '7. Çocukların Gizliliği',
          body: 'Nurai, 13 yaşın altındaki çocuklara yönelik değildir ve '
              'bu yaş grubundan bilerek veri toplamaz.',
        ),
        _Section(
          title: '8. Haklarınız',
          body: 'Aşağıdaki haklara sahipsiniz:\n\n'
              '• Verilerinize erişim talep etme\n'
              '• Verilerinizin düzeltilmesini isteme\n'
              '• Verilerinizin silinmesini talep etme\n'
              '• Veri işlemeye itiraz etme\n\n'
              'Bu hakları kullanmak için destek@nurai.app adresine e-posta gönderin.',
        ),
        _Section(
          title: '9. Tıbbi Uyarı',
          body: 'Nurai bir tıbbi cihaz veya sağlık hizmeti sağlayıcısı değildir. '
              'Uygulama içindeki AI önerileri bilgilendirme amaçlıdır ve '
              'profesyonel tıbbi tavsiyenin yerini tutmaz.',
          isWarning: true,
        ),
        _Section(
          title: '10. Değişiklikler',
          body: 'Bu politika zaman zaman güncellenebilir. '
              'Önemli değişikliklerde uygulama içi bildirim alırsınız.',
        ),
        _Section(
          title: '11. İletişim',
          body: 'Gizlilik ile ilgili sorularınız için:\n'
              'destek@nurai.app',
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '© 2025 Nurai. Tüm hakları saklıdır.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    this.isWarning = false,
  });

  final String title;
  final String body;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isWarning ? Colors.orange.shade800 : null,
                ),
          ),
          const SizedBox(height: 6),
          if (isWarning)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
