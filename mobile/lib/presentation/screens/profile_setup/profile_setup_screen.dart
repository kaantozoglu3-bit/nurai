import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import 'steps/step1_basic_info.dart';
import 'steps/step2_fitness_level.dart';
import 'steps/step3_injury_history.dart';
import 'steps/step4_goals.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Profile data
  final Map<String, dynamic> _profileData = {
    'age': null,
    'gender': null,
    'height': null,
    'weight': null,
    'fitnessLevel': null,
    'injuries': <String>[],
    'otherInjury': '',
    'goal': null,
  };

  static const _stepTitles = [
    'Temel Bilgiler',
    'Aktivite Seviyesi',
    'Sakatlık Geçmişi',
    'Hedefiniz',
  ];

  Future<void> _nextStep() async {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // JSON blob (chat_screen.dart için)
    await prefs.setString('userProfile', jsonEncode(_profileData));

    // Individual keys
    await prefs.setInt('age', (_profileData['age'] as num?)?.toInt() ?? 0);
    await prefs.setString('gender', _profileData['gender']?.toString() ?? '');
    await prefs.setInt('height_cm', (_profileData['height'] as num?)?.toInt() ?? 0);
    await prefs.setInt('weight_kg', (_profileData['weight'] as num?)?.toInt() ?? 0);
    await prefs.setString('fitness_level', _profileData['fitnessLevel']?.toString() ?? '');
    await prefs.setStringList(
      'past_injuries',
      List<String>.from(_profileData['injuries'] as List? ?? []),
    );
    await prefs.setString('other_injury', _profileData['otherInjury']?.toString() ?? '');
    await prefs.setString('goal', _profileData['goal']?.toString() ?? '');
    await prefs.setBool('isProfileComplete', true);

    // Backend'e gönder (hata olursa yerel kayıt geçerli)
    try {
      await ApiService.saveUserProfile({
        'age': _profileData['age'],
        'gender': _profileData['gender'],
        'height_cm': _profileData['height'],
        'weight_kg': _profileData['weight'],
        'fitness_level': _profileData['fitnessLevel'],
        'past_injuries': List<String>.from(_profileData['injuries'] as List? ?? []),
        'other_injury': _profileData['otherInjury'],
        'goal': _profileData['goal'],
      });
    } catch (e) {
      debugPrint('[ProfileSetup] Backend kayıt hatası (yerel kayıt geçerli): $e');
    }

    await ref.read(authStateProvider.notifier).completeProfile();
    if (mounted) context.go(AppRoutes.home);
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 20),
                onPressed: _prevStep,
              )
            : null,
        title: Text(
          'Adım ${_currentStep + 1}/4',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 4,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _stepTitles[_currentStep],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Step1BasicInfo(
                    data: _profileData,
                    onChanged: (key, value) =>
                        setState(() => _profileData[key] = value),
                  ),
                  Step2FitnessLevel(
                    data: _profileData,
                    onChanged: (key, value) =>
                        setState(() => _profileData[key] = value),
                  ),
                  Step3InjuryHistory(
                    data: _profileData,
                    onChanged: (key, value) =>
                        setState(() => _profileData[key] = value),
                  ),
                  Step4Goals(
                    data: _profileData,
                    onChanged: (key, value) =>
                        setState(() => _profileData[key] = value),
                  ),
                ],
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              child: AppButton(
                label: _currentStep == 3 ? 'Başla!' : 'Devam Et',
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
