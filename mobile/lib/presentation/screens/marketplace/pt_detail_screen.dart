import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/physiotherapist_model.dart';
import '../../../data/services/marketplace_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/navigation_provider.dart';

class PtDetailScreen extends ConsumerStatefulWidget {
  final PhysiotherapistModel pt;
  const PtDetailScreen({super.key, required this.pt});

  @override
  ConsumerState<PtDetailScreen> createState() => _PtDetailScreenState();
}

class _PtDetailScreenState extends ConsumerState<PtDetailScreen> {
  bool _isOpening = false;

  Future<void> _startConversation() async {
    setState(() => _isOpening = true);
    try {
      final user = ref.read(currentUserProvider);
      final userName = user?.displayName ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'Kullanıcı';

      final convId = await MarketplaceService.openConversation(
        ptId: widget.pt.uid,
        ptName: widget.pt.name,
        userName: userName,
      );
      ref.invalidate(myConversationsProvider);

      if (mounted) {
        // Store conversation data in provider before navigating to avoid
        // state.extra breakage on deep links.
        ref.read(messagingDataProvider.notifier).state = ConversationModel(
          id: convId,
          ptId: widget.pt.uid,
          userId: '',
          ptName: widget.pt.name,
          userName: '',
          lastMessageAt: DateTime.now(),
        );
        context.push(AppRoutes.messaging);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mesaj başlatılamadı. Tekrar deneyin.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pt = widget.pt;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(pt.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 28, horizontal: 20),
              color: AppColors.surface,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      pt.name.isNotEmpty
                          ? pt.name[0].toUpperCase()
                          : 'F',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pt.name,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    pt.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (pt.city.isNotEmpty) ...[
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Text(
                          pt.city,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.work_outline,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Text(
                        '${pt.yearsExperience} yıl deneyim',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Info sections
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pt.bio.isNotEmpty) ...[
                    _Section(
                      title: 'Hakkımda',
                      child: Text(
                        pt.bio,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (pt.specializations.isNotEmpty) ...[
                    _Section(
                      title: 'Uzmanlık Alanları',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pt.specializations
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (pt.diplomaInstitution.isNotEmpty) ...[
                    _Section(
                      title: 'Eğitim',
                      child: Row(
                        children: [
                          const Icon(Icons.school_outlined,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            pt.diplomaInstitution,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Message button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isOpening ? null : _startConversation,
                      icon: _isOpening
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.chat_outlined,
                              color: Colors.white),
                      label: Text(
                        _isOpening ? 'Bağlanıyor...' : 'Mesaj Gönder',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
