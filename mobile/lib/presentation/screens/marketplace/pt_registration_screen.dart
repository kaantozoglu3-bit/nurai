import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/physiotherapist_model.dart';
import '../../../data/services/marketplace_service.dart';
import '../../providers/marketplace_provider.dart';
import 'pt_registration_widgets.dart';

class PtRegistrationScreen extends ConsumerStatefulWidget {
  const PtRegistrationScreen({super.key});

  @override
  ConsumerState<PtRegistrationScreen> createState() =>
      _PtRegistrationScreenState();
}

class _PtRegistrationScreenState
    extends ConsumerState<PtRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _diplomaCtrl = TextEditingController();
  final _specCtrl = TextEditingController();

  String _title = PtRegistrationForm.titleOptions.first;
  int _years = 1;
  final List<String> _specs = [];
  bool _isSaving = false;

  void _addSpec() {
    final s = _specCtrl.text.trim();
    if (s.isNotEmpty && !_specs.contains(s)) {
      setState(() {
        _specs.add(s);
        _specCtrl.clear();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_specs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('En az bir uzmanlık alanı ekleyin.'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final authName = FirebaseAuth.instance.currentUser?.displayName ?? '';
      final name = authName.isNotEmpty ? authName : _nameCtrl.text.trim();

      await MarketplaceService.registerAsPhysiotherapist(
        PhysiotherapistModel(
          uid: uid,
          name: name,
          title: _title,
          bio: _bioCtrl.text.trim(),
          specializations: List.from(_specs),
          yearsExperience: _years,
          city: _cityCtrl.text.trim(),
          diplomaInstitution: _diplomaCtrl.text.trim(),
          status: PtStatus.approved,
          createdAt: DateTime.now(),
        ),
      );
      ref.invalidate(myPtProfileProvider);
      ref.invalidate(ptListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profiliniz oluşturuldu! Artık platformda görünürsünüz.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt sırasında hata oluştu. Tekrar deneyin.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    _diplomaCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existingProfile = ref.watch(myPtProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Fizyoterapist Kaydı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: existingProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Profil kontrol edilemedi')),
        data: (existing) => existing != null
            ? PtExistingProfileView(pt: existing)
            : PtRegistrationForm(
                formKey: _formKey,
                nameCtrl: _nameCtrl,
                bioCtrl: _bioCtrl,
                cityCtrl: _cityCtrl,
                diplomaCtrl: _diplomaCtrl,
                specCtrl: _specCtrl,
                title: _title,
                years: _years,
                specs: _specs,
                isSaving: _isSaving,
                onTitleChanged: (v) => setState(() => _title = v ?? _title),
                onYearsChanged: (v) => setState(() => _years = v),
                onAddSpec: _addSpec,
                onRemoveSpec: (s) => setState(() => _specs.remove(s)),
                onSave: _save,
              ),
      ),
    );
  }
}
