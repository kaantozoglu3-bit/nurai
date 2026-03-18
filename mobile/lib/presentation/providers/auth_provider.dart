import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Future<AuthState> build() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return const AuthState();

    final prefs = await SharedPreferences.getInstance();
    final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
    final remaining = await QuotaService.getRemainingUses();

    return AuthState(
      isLoggedIn: true,
      isProfileComplete: isProfileComplete,
      user: UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? '',
        isLoggedIn: true,
        isProfileComplete: isProfileComplete,
        dailyAnalysisCount: 3 - remaining,
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
      final prefs = await SharedPreferences.getInstance();
      final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
      final remaining = await QuotaService.getRemainingUses();

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        isProfileComplete: isProfileComplete,
        user: UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? email.split('@').first,
          isLoggedIn: true,
          isProfileComplete: isProfileComplete,
          dailyAnalysisCount: 3 - remaining,
          lastAnalysisDate: DateTime.now(),
        ),
      ));
    } on FirebaseAuthException catch (e) {
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
    } on FirebaseAuthException catch (e) {
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
