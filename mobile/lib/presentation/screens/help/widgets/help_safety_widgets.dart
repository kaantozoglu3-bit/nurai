import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Safety Warnings Card ─────────────────────────────────────────────────────

class HelpSafetyWarningsCard extends StatelessWidget {
  const HelpSafetyWarningsCard({super.key});

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

// ─── Pain Level Guide ─────────────────────────────────────────────────────────

class HelpPainLevelGuide extends StatelessWidget {
  const HelpPainLevelGuide({super.key});

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
            HelpPainLevelRow(
              range: '0–3 / 10',
              description: 'Hafif, tolere edilebilir — devam et',
              color: AppColors.success,
              bgColor: Color(0xFFF0FDF4),
            ),
            SizedBox(height: 8),
            HelpPainLevelRow(
              range: '4–6 / 10',
              description: 'Modifiye et veya azalt',
              color: AppColors.warning,
              bgColor: Color(0xFFFFFBEB),
            ),
            SizedBox(height: 8),
            HelpPainLevelRow(
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

class HelpPainLevelRow extends StatelessWidget {
  const HelpPainLevelRow({
    super.key,
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

// ─── Caution Groups Card ──────────────────────────────────────────────────────

class HelpCautionGroupsCard extends StatelessWidget {
  const HelpCautionGroupsCard({super.key});

  static const List<_CautionItem> _items = [
    _CautionItem(Icons.medical_services_outlined, 'Yeni ameliyat geçirenler'),
    _CautionItem(Icons.emergency_outlined, 'Akut yaralanması olanlar'),
    _CautionItem(Icons.balance_outlined, 'Ciddi denge problemi yaşayanlar'),
    _CautionItem(
        Icons.psychology_outlined, 'Kronik nörolojik rahatsızlığı olanlar'),
    _CautionItem(Icons.favorite_border, 'Kardiyovasküler risk taşıyanlar'),
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
                      Icon(item.icon, color: AppColors.primary, size: 20),
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
