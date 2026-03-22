import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/firestore_paths.dart';
import '../../data/models/user_model.dart';
import '../../data/services/quota_service.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isProfileComplete;
  final UserModel? user;

  const AuthState({
    this.isLoggedIn = false,
    this.isProfileComplete = false,
    this.user,
  });
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Firestore'dan profil var mı kontrol eder.
  /// SharedPreferences'ı hızlı önbellek olarak kullanır:
  ///   - true ise Firestore'a gitme (zaten tamamlanmış)
  ///   - false ise Firestore'dan gerçek durumu çek ve önbelleği güncelle
  Future<bool> _checkProfileComplete(String uid) async {
    final prefs = await SharedPreferences.getInstance();

    // Önbellek true → direkt döndür (Firestore round-trip'ten kaçın)
    if (prefs.getBool('isProfileComplete') == true) return true;

    // Önbellek false veya yok → Firestore'a sor
    try {
      final doc = await _db.doc(FirestorePaths.userProfile(uid)).get();
      if (!doc.exists) return false;

      final data = doc.data();
      // Profil tamamlanmış sayılması için en az bir temel alan dolu olmalı
      final isComplete = data != null &&
          (data['fitness_level'] != null || data['goal'] != null);

      if (isComplete) {
        // Önbelleği güncelle — bir sonraki açılışta hızlı okuma
        await prefs.setBool('isProfileComplete', true);
      }
      return isComplete;
    } catch (e) {
      // Firestore erişim hatası — varsayılan false, wizard göster
      if (kDebugMode) debugPrint('[AuthProvider] Firestore profil kontrolü başarısız: $e');
      return false;
    }
  }

  /// Firestore users/{uid} dokümanından premium durumunu kontrol eder.
  /// Backend ile aynı field adını kullanır: `premium` (bool) ve `premiumExpiresAt` (Timestamp).
  Future<bool> _checkPremiumStatus(String uid) async {
    try {
      final doc = await _db.doc(FirestorePaths.user(uid)).get();
      if (!doc.exists) return false;
      final data = doc.data();
      if (data == null) return false;

      final isPremium = data['premium'] == true;
      if (!isPremium) return false;

      // Süre dolmuşsa premium sayma
      final expiresAt = data['premiumExpiresAt'];
      if (expiresAt != null) {
        final DateTime expiry = (expiresAt as dynamic).toDate() as DateTime;
        if (expiry.isBefore(DateTime.now())) return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthProvider] Premium kontrol hatası: $e');
      return false;
    }
  }

  @override
  Future<AuthState> build() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return const AuthState();

    final results = await Future.wait([
      _checkProfileComplete(firebaseUser.uid),
      _checkPremiumStatus(firebaseUser.uid),
      QuotaService.getRemainingUses(),
    ]);

    final isProfileComplete = results[0] as bool;
    final isPremium = results[1] as bool;
    final remaining = results[2] as int;

    return AuthState(
      isLoggedIn: true,
      isProfileComplete: isProfileComplete,
      user: UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ??
            firebaseUser.email?.split('@').first ??
            '',
        isLoggedIn: true,
        isProfileComplete: isProfileComplete,
        isPremium: isPremium,
        dailyAnalysisCount: QuotaService.dailyLimit - remaining,
        lastAnalysisDate: DateTime.now(),
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      final results = await Future.wait([
        _checkProfileComplete(firebaseUser.uid),
        _checkPremiumStatus(firebaseUser.uid),
        QuotaService.getRemainingUses(),
      ]);

      final isProfileComplete = results[0] as bool;
      final isPremium = results[1] as bool;
      final remaining = results[2] as int;

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        isProfileComplete: isProfileComplete,
        user: UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? email.split('@').first,
          isLoggedIn: true,
          isProfileComplete: isProfileComplete,
          isPremium: isPremium,
          dailyAnalysisCount: QuotaService.dailyLimit - remaining,
          lastAnalysisDate: DateTime.now(),
        ),
      ));
    } on FirebaseAuthException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      state = AsyncValue.error(_authError(e.code), StackTrace.current);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        isProfileComplete: false,
        user: UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: name,
          isLoggedIn: true,
          isProfileComplete: false,
        ),
      ));
    } on FirebaseAuthException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      state = AsyncValue.error(_authError(e.code), StackTrace.current);
    }
  }

  Future<void> completeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProfileComplete', true);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(AuthState(
        isLoggedIn: current.isLoggedIn,
        isProfileComplete: true,
        user: current.user?.copyWith(isProfileComplete: true),
      ));
    }
  }

  Future<void> logout() async {
    await QuotaService.clearForCurrentUser();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProfileComplete', false);
    state = const AsyncValue.data(AuthState());
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen bekleyin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.user;
});

/// Tracks whether the user has seen the onboarding screens.
/// Loaded once at startup from SharedPreferences.
final onboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenOnboarding') ?? false;
});
