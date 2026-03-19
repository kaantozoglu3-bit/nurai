import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/physiotherapist_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/marketplace_service.dart';

// ─── PT listing ───────────────────────────────────────────────────────────────

class PtListState {
  final List<PhysiotherapistModel> pts;
  final String cityFilter;
  final String specializationFilter;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  const PtListState({
    this.pts = const [],
    this.cityFilter = '',
    this.specializationFilter = '',
    this.isLoadingMore = false,
    this.hasMore = false,
    this.lastDocument,
  });

  PtListState copyWith({
    List<PhysiotherapistModel>? pts,
    String? cityFilter,
    String? specializationFilter,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    bool clearLastDocument = false,
  }) =>
      PtListState(
        pts: pts ?? this.pts,
        cityFilter: cityFilter ?? this.cityFilter,
        specializationFilter:
            specializationFilter ?? this.specializationFilter,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        lastDocument:
            clearLastDocument ? null : (lastDocument ?? this.lastDocument),
      );

  List<PhysiotherapistModel> get filtered {
    return pts.where((pt) {
      if (cityFilter.isNotEmpty &&
          !pt.city.toLowerCase().contains(cityFilter.toLowerCase())) {
        return false;
      }
      if (specializationFilter.isNotEmpty &&
          !pt.specializations.any((s) =>
              s.toLowerCase().contains(specializationFilter.toLowerCase()))) {
        return false;
      }
      return true;
    }).toList();
  }
}

class PtListNotifier extends AutoDisposeAsyncNotifier<PtListState> {
  @override
  Future<PtListState> build() async {
    final page = await MarketplaceService.getApprovedPts();
    return PtListState(
      pts: page.pts,
      hasMore: page.hasMore,
      lastDocument: page.lastDocument,
    );
  }

  void setFilter({String? city, String? specialization}) {
    final current = state.valueOrNull ?? const PtListState();
    state = AsyncValue.data(current.copyWith(
      cityFilter: city ?? current.cityFilter,
      specializationFilter:
          specialization ?? current.specializationFilter,
    ));
  }

  void clearFilters() {
    final current = state.valueOrNull ?? const PtListState();
    state = AsyncValue.data(
        current.copyWith(cityFilter: '', specializationFilter: ''));
  }

  /// Loads the next page and appends results to the existing list.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    if (current.lastDocument == null) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final page = await MarketplaceService.getApprovedPtsNextPage(
        lastDocument: current.lastDocument!,
        city: current.cityFilter.isNotEmpty ? current.cityFilter : null,
        specialization: current.specializationFilter.isNotEmpty
            ? current.specializationFilter
            : null,
      );

      final updated = current.copyWith(
        pts: [...current.pts, ...page.pts],
        hasMore: page.hasMore,
        lastDocument: page.lastDocument,
        isLoadingMore: false,
      );
      state = AsyncValue.data(updated);
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }
}

final ptListProvider =
    AsyncNotifierProvider.autoDispose<PtListNotifier, PtListState>(
  PtListNotifier.new,
);

// ─── My PT profile ────────────────────────────────────────────────────────────

final myPtProfileProvider =
    FutureProvider.autoDispose<PhysiotherapistModel?>((ref) async {
  return MarketplaceService.getMyPtProfile();
});

// ─── My conversations ─────────────────────────────────────────────────────────

final myConversationsProvider =
    FutureProvider.autoDispose<List<ConversationModel>>((ref) async {
  return MarketplaceService.getMyConversations();
});

// ─── Messages stream ──────────────────────────────────────────────────────────

final messagesProvider =
    StreamProvider.autoDispose.family<List<MessageModel>, String>(
  (ref, convId) => MarketplaceService.messagesStream(convId),
);
