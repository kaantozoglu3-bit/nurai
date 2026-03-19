import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/physiotherapist_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/marketplace_service.dart';

// ─── PT listing ───────────────────────────────────────────────────────────────

class PtListState {
  final List<PhysiotherapistModel> pts;
  final String cityFilter;
  final String specializationFilter;

  const PtListState({
    this.pts = const [],
    this.cityFilter = '',
    this.specializationFilter = '',
  });

  PtListState copyWith({
    List<PhysiotherapistModel>? pts,
    String? cityFilter,
    String? specializationFilter,
  }) =>
      PtListState(
        pts: pts ?? this.pts,
        cityFilter: cityFilter ?? this.cityFilter,
        specializationFilter:
            specializationFilter ?? this.specializationFilter,
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
    final pts = await MarketplaceService.getApprovedPts();
    return PtListState(pts: pts);
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
