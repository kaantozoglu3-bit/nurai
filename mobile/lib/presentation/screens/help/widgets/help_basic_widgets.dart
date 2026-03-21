import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Medical Warning Banner ───────────────────────────────────────────────────

class HelpMedicalWarningBanner extends StatelessWidget {
  const HelpMedicalWarningBanner({super.key});

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

class HelpSectionTitle extends StatelessWidget {
  const HelpSectionTitle({super.key, required this.text});

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

// ─── App Info Expansions ──────────────────────────────────────────────────────

class HelpAppInfoExpansions extends StatelessWidget {
  const HelpAppInfoExpansions({super.key});

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

// ─── Exercise Factors Card ────────────────────────────────────────────────────

class HelpExerciseFactorsCard extends StatelessWidget {
  const HelpExerciseFactorsCard({super.key});

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
