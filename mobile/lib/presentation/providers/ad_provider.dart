import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ad_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  return service;
});
