import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/physiotherapist_model.dart';

// ─── Existing profile view ────────────────────────────────────────────────────

class PtExistingProfileView extends StatelessWidget {
  final PhysiotherapistModel pt;
  const PtExistingProfileView({super.key, required this.pt});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              pt.isApproved ? Icons.verified : Icons.hourglass_top,
              size: 64,
              color: pt.isApproved ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 16),
            Text(
              pt.isApproved ? 'Profiliniz Aktif' : 'Onay Bekliyor',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pt.isApproved
                  ? 'Adınız fizyoterapist listesinde görünüyor.'
                  : 'Profiliniz inceleniyor. En kısa sürede onaylanacak.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.marketplace),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
              ),
              child: const Text(
                'Fizyoterapistleri Gör',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form field helper ────────────────────────────────────────────────────────

class PtFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String?)? validator;

  const PtFormField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

// ─── Registration form ────────────────────────────────────────────────────────

class PtRegistrationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController bioCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController diplomaCtrl;
  final TextEditingController specCtrl;
  final String title;
  final int years;
  final List<String> specs;
  final bool isSaving;
  final void Function(String?) onTitleChanged;
  final void Function(int) onYearsChanged;
  final VoidCallback onAddSpec;
  final void Function(String) onRemoveSpec;
  final VoidCallback onSave;

  static const List<String> titleOptions = [
    'Fizyoterapist',
    'Uzman Fizyoterapist',
    'Doktor Fizyoterapist',
    'Spor Fizyoterapisti',
  ];

  const PtRegistrationForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.bioCtrl,
    required this.cityCtrl,
    required this.diplomaCtrl,
    required this.specCtrl,
    required this.title,
    required this.years,
    required this.specs,
    required this.isSaving,
    required this.onTitleChanged,
    required this.onYearsChanged,
    required this.onAddSpec,
    required this.onRemoveSpec,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fizyoterapist Profili',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Profiliniz onaylandıktan sonra kullanıcılar sizi bulabilir.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            PtFormField(
              controller: nameCtrl,
              label: 'Ad Soyad',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Ad soyad gerekli' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: title,
              onChanged: onTitleChanged,
              decoration: const InputDecoration(
                labelText: 'Unvan',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: titleOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            PtFormField(
              controller: cityCtrl,
              label: 'Şehir',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Şehir gerekli' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Deneyim (yıl): ',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textPrimary),
                ),
                Expanded(
                  child: Slider(
                    value: years.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: AppColors.primary,
                    label: '$years yıl',
                    onChanged: (v) => onYearsChanged(v.round()),
                  ),
                ),
                Text(
                  '$years',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PtFormField(
              controller: bioCtrl,
              label: 'Hakkımda',
              maxLines: 3,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Kısa biyografi ekleyin' : null,
            ),
            const SizedBox(height: 16),
            PtFormField(
              controller: diplomaCtrl,
              label: 'Mezun Olunan Okul',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Okul adı gerekli' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Uzmanlık Alanları',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: specCtrl,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'örn. Bel ağrısı, Spor yaralanması',
                      hintStyle: const TextStyle(
                          fontFamily: 'Inter', color: AppColors.textHint),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (_) => onAddSpec(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAddSpec,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Ekle',
                      style:
                          TextStyle(fontFamily: 'Inter', color: Colors.white)),
                ),
              ],
            ),
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: specs
                    .map(
                      (s) => Chip(
                        label: Text(s,
                            style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 12)),
                        onDeleted: () => onRemoveSpec(s),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        deleteIconColor: AppColors.primary,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Profili Oluştur',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
