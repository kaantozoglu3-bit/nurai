import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/profile_setup/profile_setup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/body_selector/body_selector_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/analysis_result/analysis_result_screen.dart';
import '../../presentation/screens/video_player/video_player_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/paywall/paywall_screen.dart';
import '../../presentation/providers/auth_provider.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String bodySelector = '/body-selector';
  static const String chat = '/chat';
  static const String analysisResult = '/analysis-result';
  static const String videoPlayer = '/video-player';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String paywall = '/paywall';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenOnboarding = ref.watch(onboardingProvider).valueOrNull ?? false;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final isProfileComplete = authState.valueOrNull?.isProfileComplete ?? false;
      final currentPath = state.matchedLocation;

      if (currentPath == AppRoutes.splash) return null;

      if (!hasSeenOnboarding && currentPath != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      if (!isLoggedIn &&
          currentPath != AppRoutes.login &&
          currentPath != AppRoutes.register &&
          currentPath != AppRoutes.onboarding) {
        return AppRoutes.login;
      }

      if (isLoggedIn && !isProfileComplete && currentPath != AppRoutes.profileSetup) {
        return AppRoutes.profileSetup;
      }

      if (isLoggedIn &&
          (currentPath == AppRoutes.login || currentPath == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.bodySelector,
        builder: (context, state) => const BodySelectorScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final bodyArea = state.extra as String? ?? 'lower_back';
          return ChatScreen(bodyArea: bodyArea);
        },
      ),
      GoRoute(
        path: AppRoutes.analysisResult,
        builder: (context, state) {
          final analysisData = state.extra as Map<String, dynamic>? ?? {};
          return AnalysisResultScreen(analysisData: analysisData);
        },
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          final videoData = state.extra as Map<String, dynamic>? ?? {};
          return VideoPlayerScreen(videoData: videoData);
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
});
