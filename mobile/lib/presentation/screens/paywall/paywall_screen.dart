import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/analytics_service.dart';
import '../../widgets/app_button.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logPaywallViewed('screen');
    AnalyticsService.instance.logScreenView('paywall');
  }
  bool _isYearly = true;

  static const _features = [
    {'icon': Icons.all_inclusive, 'text': 'Sınırsız günlük analiz'},
    {'icon': Icons.menu_book, 'text': 'Tam egzersiz kütüphanesi (tüm bölgeler + filtreler)'},
    {'icon': Icons.calendar_today, 'text': 'Kişiselleştirilmiş haftalık program'},
    {'icon': Icons.bar_chart, 'text': 'İlerleme takibi ve ağrı günlüğü'},
    {'icon': Icons.history, 'text': 'Tüm geçmiş analizler'},
    {'icon': Icons.notifications_active, 'text': 'Egzersiz hatırlatıcıları'},
    {'icon': Icons.block, 'text': 'Reklamsız deneyim'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingXXL,
                0,
                AppDimensions.paddingXXL,
                AppDimensions.paddingXXXL,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Premium\'a Geç',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tüm özelliklere erişim. İstediğin zaman iptal et.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features
                  const Text(
                    'Premium\'a dahil:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                f['icon'] as IconData,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              f['text'] as String,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ))),
                  const SizedBox(height: 24),

                  // Plan toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _PlanToggle(
                          label: 'Aylık',
                          price: '₺89,99',
                          isSelected: !_isYearly,
                          onTap: () => setState(() => _isYearly = false),
                        ),
                        _PlanToggle(
                          label: 'Yıllık',
                          price: '₺599,99',
                          subtext: '%44 tasarruf',
                          isSelected: _isYearly,
                          onTap: () => setState(() => _isYearly = true),
                          isBadge: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _isYearly
                          ? 'Yıllık ödeme — Aylık sadece ₺49,99'
                          : 'Aylık faturalandırılır',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subscribe button
                  AppButton(
                    label: '7 Gün Ücretsiz Dene',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Ödeme entegrasyonu yakında aktif olacak.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  AppButton(
                    label: 'Satın Almayı Geri Yükle',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Abonelik geri yükleme yakında eklenecek. '
                            'Destek için: destek@nurai.app',
                          ),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer
                  const Center(
                    child: Text(
                      'Abonelik, dönem sona ermeden 24 saat önce otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textHint,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanToggle extends StatelessWidget {
  final String label;
  final String price;
  final String? subtext;
  final bool isSelected;
  final bool isBadge;
  final VoidCallback onTap;

  const _PlanToggle({
    required this.label,
    required this.price,
    this.subtext,
    required this.isSelected,
    this.isBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              if (isBadge && !isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'En Popüler',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (subtext != null && isSelected)
                Text(
                  subtext!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
