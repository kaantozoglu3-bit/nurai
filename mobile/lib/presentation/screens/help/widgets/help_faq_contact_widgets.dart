import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ─── FAQ Section ──────────────────────────────────────────────────────────────

class HelpFaqSection extends StatelessWidget {
  const HelpFaqSection({super.key});

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
      'Günde 3 AI analizi ve 3 kütüphane egzersizi ücretsizdir.',
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
      'Kayıt ekranında "Fizyoterapist olarak kayıt ol" seçeneğini kullanın.',
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
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              if (!isLast) const Divider(height: 1, color: AppColors.border),
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

// ─── Contact Section ──────────────────────────────────────────────────────────

const String kSupportEmail = 'destek@nurai.app';

class HelpContactSection extends StatelessWidget {
  const HelpContactSection({
    super.key,
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
        Card(
          color: AppColors.surface,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading:
                const Icon(Icons.email_outlined, color: AppColors.primary),
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
              kSupportEmail,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textHint),
            onTap: onEmailTap,
          ),
        ),
        const SizedBox(height: 12),
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
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
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
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
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
