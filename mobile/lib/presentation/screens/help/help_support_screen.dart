import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/help_content_widgets.dart';

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
            const HelpMedicalWarningBanner(),
            const SizedBox(height: 20),

            // ── Section 1: Uygulama Hakkında ───────────────────────────────
            const HelpSectionTitle(text: 'Uygulama Hakkında'),
            const SizedBox(height: 8),
            const HelpAppInfoExpansions(),
            const SizedBox(height: 20),

            // ── Section 2: Egzersiz Önerileri ──────────────────────────────
            const HelpSectionTitle(text: 'Egzersiz Önerileri Nasıl Çalışır?'),
            const SizedBox(height: 8),
            const HelpExerciseFactorsCard(),
            const SizedBox(height: 20),

            // ── Section 3: Güvenlik Uyarıları ──────────────────────────────
            const HelpSectionTitle(text: 'Güvenlik Uyarıları'),
            const SizedBox(height: 8),
            const HelpSafetyWarningsCard(),
            const SizedBox(height: 20),

            // ── Section 4: Ağrı Seviyesi Rehberi ───────────────────────────
            const HelpSectionTitle(text: 'Ağrı Seviyesi Rehberi'),
            const SizedBox(height: 8),
            const HelpPainLevelGuide(),
            const SizedBox(height: 20),

            // ── Section 5: Dikkatli Kullanması Gerekenler ──────────────────
            const HelpSectionTitle(text: 'Dikkatli Kullanması Gerekenler'),
            const SizedBox(height: 8),
            const HelpCautionGroupsCard(),
            const SizedBox(height: 20),

            // ── Section 6: SSS ─────────────────────────────────────────────
            const HelpSectionTitle(text: 'Sık Sorulan Sorular'),
            const SizedBox(height: 8),
            const HelpFaqSection(),
            const SizedBox(height: 20),

            // ── Section 7: İletişim ────────────────────────────────────────
            const HelpSectionTitle(text: 'İletişim'),
            const SizedBox(height: 8),
            HelpContactSection(
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
