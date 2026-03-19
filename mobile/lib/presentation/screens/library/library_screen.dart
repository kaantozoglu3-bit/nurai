import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/exercise_library_data.dart';
import '../../../data/models/exercise_library_model.dart';
import '../../providers/auth_provider.dart';

/// Free users see 3 exercises per area; filter locked.
/// Premium users see all exercises + Akut/Kronik filter.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  BodyAreaLibrary? _selected;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  bool get _isPremium =>
      ref.watch(currentUserProvider)?.isPremium ?? false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        leading: _selected != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => setState(() {
                  _selected = null;
                  _searchQuery = '';
                  _searchCtrl.clear();
                }),
              )
            : null,
        title: Text(_selected?.label ?? 'Egzersiz Kütüphanesi'),
        bottom: _selected == null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Bölge ara… (boyun, diz, omuz…)',
                      hintStyle: const TextStyle(
                          fontFamily: 'Inter', color: AppColors.textHint),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textHint, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textHint, size: 18),
                              onPressed: () => setState(() {
                                _searchQuery = '';
                                _searchCtrl.clear();
                              }),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: _selected == null
          ? _BodyMap(
              onSelect: (area) => setState(() => _selected = area),
              searchQuery: _searchQuery,
            )
          : _ExerciseList(area: _selected!, isPremium: _isPremium),
    );
  }
}

// ── Vücut Haritası ─────────────────────────────────────────────────────────────

class _BodyMap extends StatelessWidget {
  final ValueChanged<BodyAreaLibrary> onSelect;
  final String searchQuery;

  const _BodyMap({required this.onSelect, required this.searchQuery});

  static const Map<String, IconData> _icons = {
    'neck': Icons.accessibility_new,
    'left_shoulder': Icons.sports_handball,
    'right_shoulder': Icons.sports_handball,
    'upper_back': Icons.airline_seat_recline_normal,
    'lower_back': Icons.self_improvement,
    'hip': Icons.directions_walk,
    'left_knee': Icons.directions_run,
    'right_knee': Icons.directions_run,
    'left_elbow': Icons.fitness_center,
    'right_elbow': Icons.fitness_center,
    'left_wrist': Icons.pan_tool,
    'right_wrist': Icons.pan_tool,
    'left_ankle': Icons.directions_walk,
    'right_ankle': Icons.directions_walk,
    'core': Icons.sports_gymnastics,
  };

  List<BodyAreaLibrary> get _filteredAreas {
    if (searchQuery.isEmpty) return exerciseLibrary;
    final q = searchQuery.toLowerCase();
    return exerciseLibrary
        .where((a) => a.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final areas = _filteredAreas;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            searchQuery.isEmpty ? 'Bölge Seç' : '${areas.length} sonuç',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Egzersizleri görmek istediğin bölgeye dokun',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (areas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  children: [
                    Icon(Icons.search_off,
                        size: 48,
                        color: AppColors.textHint.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    const Text(
                      'Aradığın bölge bulunamadı',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: areas.length,
              itemBuilder: (context, i) {
                final area = areas[i];
                return _BodyAreaTile(
                  area: area,
                  icon: _icons[area.key] ?? Icons.healing,
                  onTap: () => onSelect(area),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BodyAreaTile extends StatelessWidget {
  final BodyAreaLibrary area;
  final IconData icon;
  final VoidCallback onTap;

  const _BodyAreaTile({
    required this.area,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              area.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${area.exercises.length} egzersiz',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Egzersiz Listesi ───────────────────────────────────────────────────────────

class _ExerciseList extends StatefulWidget {
  final BodyAreaLibrary area;
  final bool isPremium;

  const _ExerciseList({required this.area, required this.isPremium});

  @override
  State<_ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<_ExerciseList> {
  String _phase = 'Akut';

  static const int _freeLimit = 3;

  List<ExerciseLibraryItem> get _filtered =>
      widget.area.exercises.where((e) => e.phase == _phase).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final visibleCount =
        widget.isPremium ? filtered.length : filtered.length.clamp(0, _freeLimit);
    final lockedCount = widget.isPremium ? 0 : (filtered.length - visibleCount).clamp(0, filtered.length);

    return Column(
      children: [
        // Filtre satırı
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXXL,
            vertical: AppDimensions.paddingM,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'Akut',
                selected: _phase == 'Akut',
                locked: false,
                onTap: () => setState(() => _phase = 'Akut'),
              ),
              const SizedBox(width: 10),
              _FilterChip(
                label: 'Kronik',
                selected: _phase == 'Kronik',
                locked: !widget.isPremium,
                onTap: () {
                  if (!widget.isPremium) {
                    context.go(AppRoutes.paywall);
                  } else {
                    setState(() => _phase = 'Kronik');
                  }
                },
              ),
              const Spacer(),
              Text(
                '${filtered.length} egzersiz',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Bu filtre için egzersiz yok',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                  itemCount: visibleCount + (lockedCount > 0 ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i < visibleCount) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: _ExerciseCard(exercise: filtered[i]),
                      );
                    }
                    // Locked banner
                    return _LockedBanner(
                      lockedCount: lockedCount,
                      onUnlock: () => context.go(AppRoutes.paywall),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locked) ...[
              const Icon(Icons.lock, size: 12, color: AppColors.textHint),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: locked
                    ? AppColors.textHint
                    : selected
                        ? Colors.white
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Locked Banner ──────────────────────────────────────────────────────────────

class _LockedBanner extends StatelessWidget {
  final int lockedCount;
  final VoidCallback onUnlock;

  const _LockedBanner({required this.lockedCount, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUnlock,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$lockedCount egzersiz daha kilitledi',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Premium\'a geç, tüm egzersizleri gör',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Egzersiz Kartı ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final ExerciseLibraryItem exercise;

  const _ExerciseCard({required this.exercise});

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case 'Kolay':
        return AppColors.success;
      case 'Zor':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData get _difficultyIcon {
    switch (exercise.difficulty) {
      case 'Kolay':
        return Icons.sentiment_satisfied_alt;
      case 'Zor':
        return Icons.local_fire_department;
      default:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _difficultyColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_difficultyIcon, color: _difficultyColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  exercise.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.repeat_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      exercise.sets,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
