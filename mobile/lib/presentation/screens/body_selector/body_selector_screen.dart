import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/analytics_service.dart';
import '../../widgets/app_button.dart';
class BodySelectorScreen extends StatefulWidget {
  const BodySelectorScreen({super.key});

  @override
  State<BodySelectorScreen> createState() => _BodySelectorScreenState();
}

class _BodySelectorScreenState extends State<BodySelectorScreen> {
  final Set<String> _selectedAreas = {};

  static const _bodyAreas = [
    {'key': 'neck', 'label': 'Boyun', 'icon': Icons.accessibility_new},
    {'key': 'left_shoulder', 'label': 'Sol Omuz', 'icon': Icons.sports_handball},
    {'key': 'right_shoulder', 'label': 'Sağ Omuz', 'icon': Icons.sports_handball},
    {'key': 'upper_back', 'label': 'Üst Sırt', 'icon': Icons.airline_seat_recline_normal},
    {'key': 'lower_back', 'label': 'Bel / Alt Sırt', 'icon': Icons.airline_seat_recline_extra},
    {'key': 'hip', 'label': 'Kalça', 'icon': Icons.directions_walk},
    {'key': 'left_knee', 'label': 'Sol Diz', 'icon': Icons.directions_run},
    {'key': 'right_knee', 'label': 'Sağ Diz', 'icon': Icons.directions_run},
    {'key': 'left_elbow', 'label': 'Sol Dirsek', 'icon': Icons.sports_tennis},
    {'key': 'right_elbow', 'label': 'Sağ Dirsek', 'icon': Icons.sports_tennis},
    {'key': 'left_wrist', 'label': 'Sol Bilek', 'icon': Icons.back_hand_outlined},
    {'key': 'right_wrist', 'label': 'Sağ Bilek', 'icon': Icons.back_hand_outlined},
    {'key': 'left_ankle', 'label': 'Sol Ayak Bileği', 'icon': Icons.directions_walk},
    {'key': 'right_ankle', 'label': 'Sağ Ayak Bileği', 'icon': Icons.directions_walk},
    {'key': 'core', 'label': 'Karın / Core', 'icon': Icons.sports_gymnastics},
  ];

  void _toggleArea(String key) {
    setState(() {
      if (_selectedAreas.contains(key)) {
        _selectedAreas.remove(key);
      } else {
        // Single-selection only — routing passes one bodyArea string.
        _selectedAreas
          ..clear()
          ..add(key);
      }
    });
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
        title: const Text('Ağrı Bölgeni Seç'),
      ),
      body: Column(
        children: [
          // Body map visual
          _BodyMapWidget(
            selectedAreas: _selectedAreas,
            onAreaTap: _toggleArea,
          ),

          const Divider(height: 1),

          // Area chips
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ağrıyan bölgeyi seç:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bodyAreas.map((area) {
                      final key = area['key'] as String;
                      final label = area['label'] as String;
                      final isSelected = _selectedAreas.contains(key);
                      return GestureDetector(
                        onTap: () => _toggleArea(key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(Icons.check,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXXL),
            child: AppButton(
              label: _selectedAreas.isEmpty
                  ? 'Bölge Seç'
                  : 'Devam Et',
              onPressed: _selectedAreas.isEmpty
                  ? null
                  : () {
                      // TODO(multi-area): bodyArea routing uses a single String.
                      // To support multiple areas, refactor AppRoutes.chat to
                      // accept List<String> and update ChatNotifier accordingly.
                      final area = _selectedAreas.first;
                      AnalyticsService.instance.logBodyAreaSelected(area);
                      context.go(AppRoutes.chat, extra: area);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMapWidget extends StatelessWidget {
  final Set<String> selectedAreas;
  final void Function(String) onAreaTap;

  const _BodyMapWidget({
    required this.selectedAreas,
    required this.onAreaTap,
  });

  // Figure dimensions: 160 wide, 260 tall
  // Body layout (x, y origin = top-left of SizedBox):
  //   Head:        circle center (80, 22), r=20
  //   Neck:        x:72-88, y:42-54
  //   Torso:       x:48-112, y:54-152
  //   Left arm:    x:14-48, y:54-136
  //   Right arm:   x:112-146, y:54-136
  //   Left leg:    x:48-76, y:152-252
  //   Right leg:   x:84-112, y:152-252
  //
  // Tap zones are strictly non-overlapping:
  //   neck:           x:64-96,   y:40-54   (32×14)
  //   left_shoulder:  x:10-48,   y:50-90   (38×40)
  //   right_shoulder: x:112-150, y:50-90   (38×40)  ← NO overlap with lower_back
  //   upper_back:     x:48-112,  y:50-100  (64×50)
  //   lower_back:     x:48-112,  y:100-152 (64×52)
  //   hip:            x:44-116,  y:152-188 (72×36)
  //   left_knee:      x:22-60,   y:192-230 (38×38)
  //   right_knee:     x:100-138, y:192-230 (38×38)

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: AppColors.surface,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 260),
            painter: _BodyPainter(selectedAreas: selectedAreas),
          ),
          SizedBox(
            width: 160,
            height: 260,
            child: Stack(
              children: [
                _TapZone(area: 'neck',
                  left: 64, top: 40, width: 32, height: 14,
                  isSelected: selectedAreas.contains('neck'),
                  onTap: () => onAreaTap('neck')),
                _TapZone(area: 'left_shoulder',
                  left: 10, top: 50, width: 38, height: 40,
                  isSelected: selectedAreas.contains('left_shoulder'),
                  onTap: () => onAreaTap('left_shoulder')),
                _TapZone(area: 'right_shoulder',
                  left: 112, top: 50, width: 38, height: 40,
                  isSelected: selectedAreas.contains('right_shoulder'),
                  onTap: () => onAreaTap('right_shoulder')),
                _TapZone(area: 'upper_back',
                  left: 48, top: 50, width: 64, height: 50,
                  isSelected: selectedAreas.contains('upper_back'),
                  onTap: () => onAreaTap('upper_back')),
                _TapZone(area: 'lower_back',
                  left: 48, top: 100, width: 64, height: 52,
                  isSelected: selectedAreas.contains('lower_back'),
                  onTap: () => onAreaTap('lower_back')),
                _TapZone(area: 'hip',
                  left: 44, top: 152, width: 72, height: 36,
                  isSelected: selectedAreas.contains('hip'),
                  onTap: () => onAreaTap('hip')),
                _TapZone(area: 'left_knee',
                  left: 22, top: 192, width: 38, height: 38,
                  isSelected: selectedAreas.contains('left_knee'),
                  onTap: () => onAreaTap('left_knee')),
                _TapZone(area: 'right_knee',
                  left: 100, top: 192, width: 38, height: 38,
                  isSelected: selectedAreas.contains('right_knee'),
                  onTap: () => onAreaTap('right_knee')),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            child: Text(
              'Vücutta ağrılı bölgeye dokun',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapZone extends StatelessWidget {
  final String area;
  final double left, top, width, height;
  final bool isSelected;
  final VoidCallback onTap;

  const _TapZone({
    required this.area,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final Set<String> selectedAreas;

  _BodyPainter({required this.selectedAreas});

  void _drawPart(Canvas canvas, RRect rRect, Paint fill, Paint stroke) {
    canvas.drawRRect(rRect, fill);
    canvas.drawRRect(rRect, stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // size = 160 × 260
    final fill = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = AppColors.textHint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final selectedFill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final selectedStroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Head
    final headRect = Rect.fromCenter(
        center: Offset(size.width / 2, 22), width: 40, height: 40);
    canvas.drawOval(headRect, fill);
    canvas.drawOval(headRect, stroke);

    // Neck
    _drawPart(canvas,
      RRect.fromRectAndRadius(Rect.fromLTWH(72, 42, 16, 14), const Radius.circular(4)),
      fill, stroke);

    // Torso
    _drawPart(canvas,
      RRect.fromRectAndRadius(Rect.fromLTWH(48, 54, 64, 98), const Radius.circular(10)),
      fill, stroke);

    // Upper back highlight
    if (selectedAreas.contains('upper_back')) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(48, 54, 64, 48), const Radius.circular(10)),
        selectedFill);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(48, 54, 64, 48), const Radius.circular(10)),
        selectedStroke);
    }
    // Lower back highlight
    if (selectedAreas.contains('lower_back')) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(48, 104, 64, 48), const Radius.circular(10)),
        selectedFill);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(48, 104, 64, 48), const Radius.circular(10)),
        selectedStroke);
    }

    // Left arm
    final leftArmRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 54, 34, 82), const Radius.circular(17));
    _drawPart(canvas, leftArmRRect,
      selectedAreas.contains('left_shoulder') ? selectedFill : fill,
      selectedAreas.contains('left_shoulder') ? selectedStroke : stroke);

    // Right arm
    final rightArmRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(112, 54, 34, 82), const Radius.circular(17));
    _drawPart(canvas, rightArmRRect,
      selectedAreas.contains('right_shoulder') ? selectedFill : fill,
      selectedAreas.contains('right_shoulder') ? selectedStroke : stroke);

    // Hip
    final hipRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(44, 152, 72, 34), const Radius.circular(8));
    _drawPart(canvas, hipRRect,
      selectedAreas.contains('hip') ? selectedFill : fill,
      selectedAreas.contains('hip') ? selectedStroke : stroke);

    // Left leg
    final leftLegRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(48, 152, 28, 100), const Radius.circular(14));
    _drawPart(canvas, leftLegRRect,
      selectedAreas.contains('left_knee') ? selectedFill : fill,
      selectedAreas.contains('left_knee') ? selectedStroke : stroke);

    // Right leg
    final rightLegRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(84, 152, 28, 100), const Radius.circular(14));
    _drawPart(canvas, rightLegRRect,
      selectedAreas.contains('right_knee') ? selectedFill : fill,
      selectedAreas.contains('right_knee') ? selectedStroke : stroke);

    // Neck highlight
    if (selectedAreas.contains('neck')) {
      _drawPart(canvas,
        RRect.fromRectAndRadius(Rect.fromLTWH(72, 42, 16, 14), const Radius.circular(4)),
        selectedFill, selectedStroke);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      !_setEquals(old.selectedAreas, selectedAreas);

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
