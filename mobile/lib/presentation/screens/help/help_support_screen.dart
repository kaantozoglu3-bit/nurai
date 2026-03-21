import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const String _supportEmail = 'destek@nurai.app';
const String _feedbackCollection = 'feedback';

// ─── Screen ───────────────────────────────────────────────────────────────────

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'Versiyon: ${info.version} (build ${info.buildNumber})';
      });
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'Nurai Destek'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _submitFeedback() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final timestamp = DateTime.now();
      final docId = timestamp.millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection(_feedbackCollection)
          .doc(user.id)
          .collection('messages')
          .doc(docId)
          .set({
        'konu': _subjectController.text.trim(),
        'mesaj': _messageController.text.trim(),
        'tarih': timestamp,
        'userId': user.id,
      });

      _subjectController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Geri bildiriminiz alındı. 3-5 iş günü içinde yanıt vereceğiz.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geri bildirim gönderilemedi. Lütfen tekrar deneyin.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Yardım & Destek',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Medical Warning Banner ──────────────────────────────────────
            const _MedicalWarningBanner(),
            const SizedBox(height: 20),

            // ── Section 1: Uygulama Hakkında ───────────────────────────────
            const _SectionTitle(text: 'Uygulama Hakkında'),
            const SizedBox(height: 8),
            const _AppInfoExpansions(),
            const SizedBox(height: 20),

            // ── Section 2: Egzersiz Önerileri ──────────────────────────────
            const _SectionTitle(text: 'Egzersiz Önerileri Nasıl Çalışır?'),
            const SizedBox(height: 8),
            const _ExerciseFactorsCard(),
            const SizedBox(height: 20),

            // ── Section 3: Güvenlik Uyarıları ──────────────────────────────
            const _SectionTitle(text: 'Güvenlik Uyarıları'),
            const SizedBox(height: 8),
            const _SafetyWarningsCard(),
            const SizedBox(height: 20),

            // ── Section 4: Ağrı Seviyesi Rehberi ───────────────────────────
            const _SectionTitle(text: 'Ağrı Seviyesi Rehberi'),
            const SizedBox(height: 8),
            const _PainLevelGuide(),
            const SizedBox(height: 20),

            // ── Section 5: Dikkatli Kullanması Gerekenler ──────────────────
            const _SectionTitle(text: 'Dikkatli Kullanması Gerekenler'),
            const SizedBox(height: 8),
            const _CautionGroupsCard(),
            const SizedBox(height: 20),

            // ── Section 6: SSS ─────────────────────────────────────────────
            const _SectionTitle(text: 'Sık Sorulan Sorular'),
            const SizedBox(height: 8),
            const _FaqSection(),
            const SizedBox(height: 20),

            // ── Section 7: İletişim ────────────────────────────────────────
            const _SectionTitle(text: 'İletişim'),
            const SizedBox(height: 8),
            _ContactSection(
              formKey: _formKey,
              subjectController: _subjectController,
              messageController: _messageController,
              isSubmitting: _isSubmitting,
              onEmailTap: _launchEmail,
              onSubmit: _submitFeedback,
            ),
            const SizedBox(height: 20),

            // ── Section 8: Versiyon ────────────────────────────────────────
            if (_appVersion.isNotEmpty) ...[
              Center(
                child: Text(
                  _appVersion,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Medical Warning Banner ───────────────────────────────────────────────────

class _MedicalWarningBanner extends StatelessWidget {
  const _MedicalWarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu uygulama acil müdahale aracı değildir. Acil bir durumda yerel acil yardım hattını arayın.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7B3F00),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── App Info Expansions (Section 1) ─────────────────────────────────────────

class _AppInfoExpansions extends StatelessWidget {
  const _AppInfoExpansions();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Column(
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              'Uygulama ne yapar?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            children: [
              Text(
                'Nurai, vücut bölgesi, ağrı seviyesi, iyileşme fazı ve mevcut ekipmana göre kişiselleştirilmiş egzersiz önerileri sunar. AI destekli analiz ile durumunuza uygun güvenli egzersiz programları oluşturur.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          Divider(height: 1, color: AppColors.border),
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              'Uygulama ne yapmaz?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            children: [
              Text(
                'Nurai tıbbi teşhis koymaz, doktor veya fizyoterapist yerine geçmez ve acil durumları yönetmez. Sunulan içerikler genel bilgilendirme amaçlıdır; kişisel tıbbi karar için uzman görüşü alınmalıdır.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Factors Card (Section 2) ───────────────────────────────────────

class _ExerciseFactorsCard extends StatelessWidget {
  const _ExerciseFactorsCard();

  static const List<String> _factors = [
    'Vücut bölgesi',
    'Ağrı seviyesi',
    'Kullanıcı tipi',
    'İyileşme fazı',
    'Mevcut ekipman',
    'Seans süresi',
    'Hareket kısıtları',
    'Güvenlik uyarıları',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI, aşağıdaki faktörlere göre size özel egzersiz önerileri oluşturur:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _factors
                  .map(
                    (factor) => Chip(
                      label: Text(
                        factor,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      padding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Safety Warnings Card (Section 3) ────────────────────────────────────────

class _SafetyWarningsCard extends StatelessWidget {
  const _SafetyWarningsCard();

  static const List<String> _warnings = [
    'Keskin veya aniden artan ağrı',
    'Uyuşma veya karıncalanma',
    'Ani güç kaybı',
    'Belirgin şişlik',
    'Baş dönmesi',
    'Kilitlenme hissi',
    'Düşme veya denge kaybı',
    'Nefes darlığı veya göğüs ağrısı',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFBEB),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFCD34D), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
                SizedBox(width: 8),
                Text(
                  'Şu durumlarda dur ve uzmana başvur:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF78350F),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pain Level Guide (Section 4) ────────────────────────────────────────────

class _PainLevelGuide extends StatelessWidget {
  const _PainLevelGuide();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _PainLevelRow(
              range: '0–3 / 10',
              description: 'Hafif, tolere edilebilir — devam et',
              color: AppColors.success,
              bgColor: Color(0xFFF0FDF4),
            ),
            SizedBox(height: 8),
            _PainLevelRow(
              range: '4–6 / 10',
              description: 'Modifiye et veya azalt',
              color: AppColors.warning,
              bgColor: Color(0xFFFFFBEB),
            ),
            SizedBox(height: 8),
            _PainLevelRow(
              range: '7+ / 10',
              description: 'Egzersizi durdur, profesyonel değerlendirme',
              color: AppColors.error,
              bgColor: Color(0xFFFEF2F2),
            ),
          ],
        ),
      ),
    );
  }
}

class _PainLevelRow extends StatelessWidget {
  const _PainLevelRow({
    required this.range,
    required this.description,
    required this.color,
    required this.bgColor,
  });

  final String range;
  final String description;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              range,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color.withAlpha(204),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Caution Groups Card (Section 5) ─────────────────────────────────────────

class _CautionGroupsCard extends StatelessWidget {
  const _CautionGroupsCard();

  static const List<_CautionItem> _items = [
    _CautionItem(Icons.medical_services_outlined, 'Yeni ameliyat geçirenler'),
    _CautionItem(Icons.emergency_outlined, 'Akut yaralanması olanlar'),
    _CautionItem(Icons.balance_outlined, 'Ciddi denge problemi yaşayanlar'),
    _CautionItem(
        Icons.psychology_outlined, 'Kronik nörolojik rahatsızlığı olanlar'),
    _CautionItem(
        Icons.favorite_border, 'Kardiyovasküler risk taşıyanlar'),
    _CautionItem(
        Icons.pregnant_woman_outlined, 'Hamilelik veya doğum sonrası dönem'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(item.icon,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _CautionItem {
  const _CautionItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

// ─── FAQ Section (Section 6) ──────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      'Uygulama tıbbi program oluşturur mu?',
      'Hayır, genel bilgilendirme amaçlıdır. Kişisel tıbbi program için fizyoterapistinize başvurun.',
    ),
    _FaqItem(
      'Ağrım artıyorsa ne yapmalıyım?',
      'Egzersizi hemen bırakın. Ağrı devam ediyorsa mutlaka bir sağlık uzmanına başvurun.',
    ),
    _FaqItem(
      'Uygulamayı her gün kullanabilir miyim?',
      'Mobilite egzersizleri günlük yapılabilir. Kuvvetlendirme egzersizleri arasında dinlenme günü bırakmanız önerilir.',
    ),
    _FaqItem(
      'Ücretsiz planda ne kadar kullanabilirim?',
      'Günde 1 AI analizi ve 3 kütüphane egzersizi ücretsizdir.',
    ),
    _FaqItem(
      'Premium aboneliği nasıl iptal ederim?',
      "App Store veya Google Play Store'dan Abonelikler bölümüne giderek iptal edebilirsiniz.",
    ),
    _FaqItem(
      'Verilerim nerede saklanıyor?',
      "Verileriniz güvenli Firebase altyapısında saklanır. Detaylar için Gizlilik Politikası'nı inceleyin.",
    ),
    _FaqItem(
      'Uygulama çocuklar için uygun mu?',
      '13 yaş altı kullanıcılar için ebeveyn onayı gereklidir.',
    ),
    _FaqItem(
      'Fizyoterapist olarak nasıl başvururum?',
      '"Kayıt ekranında "Fizyoterapist olarak kayıt ol" seçeneğini kullanın.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: _faqs.asMap().entries.map((entry) {
          final isLast = entry.key == _faqs.length - 1;
          return Column(
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  entry.value.question,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                children: [
                  Text(
                    entry.value.answer,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                const Divider(height: 1, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem(this.question, this.answer);

  final String question;
  final String answer;
}

// ─── Contact Section (Section 7) ─────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.formKey,
    required this.subjectController,
    required this.messageController,
    required this.isSubmitting,
    required this.onEmailTap,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final bool isSubmitting;
  final VoidCallback onEmailTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email contact tile
        Card(
          color: AppColors.surface,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.primary),
            title: const Text(
              'Destek E-posta',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              _supportEmail,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
            trailing:
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
            onTap: onEmailTap,
          ),
        ),
        const SizedBox(height: 12),

        // Feedback form
        Card(
          color: AppColors.surface,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Geri Bildirim Gönder',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Konu',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Konu boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Mesaj',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mesaj boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Gönder',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Yanıt süresi: 3-5 iş günü',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
