import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/physiotherapist_model.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/navigation_provider.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Fizyoterapistler'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Fizyoterapist Bul'),
            Tab(text: 'Mesajlarım'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: AppColors.primary),
            tooltip: 'Fizyoterapist Olarak Kaydol',
            onPressed: () => context.push(AppRoutes.ptRegistration),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PtListTab(searchController: _searchController),
          const _ConversationsTab(),
        ],
      ),
    );
  }
}

// ─── PT listing tab ───────────────────────────────────────────────────────────

class _PtListTab extends ConsumerWidget {
  final TextEditingController searchController;

  const _PtListTab({required this.searchController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(ptListProvider);

    return asyncState.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('Fizyoterapistler yüklenemedi',
                style: TextStyle(
                    fontFamily: 'Inter', color: AppColors.textSecondary)),
            TextButton(
              onPressed: () => ref.invalidate(ptListProvider),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
      data: (state) => Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (v) =>
                  ref.read(ptListProvider.notifier).setFilter(city: v),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Şehre göre ara...',
                hintStyle: const TextStyle(
                    fontFamily: 'Inter', color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textHint, size: 20),
                suffixIcon: state.cityFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textHint, size: 18),
                        onPressed: () {
                          searchController.clear();
                          ref.read(ptListProvider.notifier).clearFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusS),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // PT list
          Expanded(
            child: state.filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search,
                            size: 64,
                            color: AppColors.textHint
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz onaylı fizyoterapist yok',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'İlk fizyoterapist olmak ister misin?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: state.filtered.length +
                        (state.hasMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.filtered.length) {
                        // Load-more footer
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: state.isLoadingMore
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary)
                                : TextButton(
                                    onPressed: () => ref
                                        .read(ptListProvider.notifier)
                                        .loadMore(),
                                    child: const Text(
                                      'Daha Fazla Göster',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }
                      return _PtCard(
                        pt: state.filtered[index],
                        onTap: () {
                          ref.read(ptDetailDataProvider.notifier).state =
                              state.filtered[index];
                          context.push(AppRoutes.ptDetail);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── PT card ──────────────────────────────────────────────────────────────────

class _PtCard extends StatelessWidget {
  final PhysiotherapistModel pt;
  final VoidCallback onTap;

  const _PtCard({required this.pt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                pt.name.isNotEmpty ? pt.name[0].toUpperCase() : 'F',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pt.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${pt.title} · ${pt.yearsExperience} yıl deneyim',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (pt.city.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Text(
                          pt.city,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: pt.specializations
                        .take(3)
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Conversations tab ────────────────────────────────────────────────────────

class _ConversationsTab extends ConsumerWidget {
  const _ConversationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConvs = ref.watch(myConversationsProvider);

    return asyncConvs.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => const Center(
        child: Text('Mesajlar yüklenemedi',
            style: TextStyle(
                fontFamily: 'Inter', color: AppColors.textSecondary)),
      ),
      data: (convs) => convs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    'Henüz mesajın yok',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bir fizyoterapist bulup mesaj gönder.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: convs.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1),
              itemBuilder: (context, i) {
                final conv = convs[i];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      conv.ptName.isNotEmpty
                          ? conv.ptName[0].toUpperCase()
                          : 'F',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(
                    conv.ptName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    conv.lastMessage.isEmpty
                        ? 'Konuşma başlat'
                        : conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textHint, size: 18),
                  onTap: () {
                    ref.read(messagingDataProvider.notifier).state = conv;
                    context.push(AppRoutes.messaging);
                  },
                );
              },
            ),
    );
  }
}
