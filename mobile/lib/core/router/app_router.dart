import 'package:flutter/material.dart';
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
import '../../presentation/screens/marketplace/marketplace_screen.dart';
import '../../presentation/screens/marketplace/pt_registration_screen.dart';
import '../../presentation/screens/marketplace/pt_detail_screen.dart';
import '../../presentation/screens/marketplace/messaging_screen.dart';
import '../../presentation/screens/quick_exercise/quick_exercise_screen.dart';
import '../../data/models/physiotherapist_model.dart';
import '../../data/models/message_model.dart';
import '../../presentation/providers/auth_provider.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String bodySelector = '/body-selector';
  static const String chat = '/chat/:bodyArea';
  static const String analysisResult = '/analysis-result';
  static const String videoPlayer = '/video-player';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String paywall = '/paywall';
  static const String marketplace = '/marketplace';
  static const String ptRegistration = '/pt-registration';
  static const String ptDetail = '/pt-detail';
  static const String messaging = '/messaging';
  static const String quickExercise = '/quick-exercise';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenOnboarding = ref.watch(onboardingProvider).valueOrNull ?? false;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Sayfa bulunamadı')),
      body: const Center(
        child: Text(
          'Bu sayfa mevcut değil.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 16),
        ),
      ),
    ),
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
          final bodyArea = state.pathParameters['bodyArea'] ?? 'lower_back';
          return ChatScreen(bodyArea: bodyArea);
        },
      ),
      GoRoute(
        path: AppRoutes.analysisResult,
        builder: (context, state) {
          // state.extra carries a complex object; deep-link / null-extra falls
          // back to an empty map so the screen can show a graceful empty state.
          // TODO: migrate to a provider for proper deep-link support.
          final analysisData = state.extra as Map<String, dynamic>? ?? {};
          return AnalysisResultScreen(analysisData: analysisData);
        },
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          // state.extra carries a complex object; deep-link / null-extra falls
          // back to an empty map so the screen can show a graceful empty state.
          // TODO: migrate to a provider for proper deep-link support.
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
      GoRoute(
        path: AppRoutes.marketplace,
        builder: (context, state) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.ptRegistration,
        builder: (context, state) => const PtRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.ptDetail,
        builder: (context, state) {
          // state.extra carries a complex object that cannot be encoded in query
          // params. This is intentional; deep-link or null-extra scenario falls
          // back to home rather than crashing with a cast error.
          // TODO: migrate to a provider/state manager for proper deep-link support.
          final pt = state.extra;
          if (pt is! PhysiotherapistModel) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(AppRoutes.home);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return PtDetailScreen(pt: pt);
        },
      ),
      GoRoute(
        path: AppRoutes.quickExercise,
        builder: (context, state) => const QuickExerciseScreen(),
      ),
      GoRoute(
        path: AppRoutes.messaging,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return MessagingScreen(
              convId: extra['convId'] as String? ?? '',
              ptName: extra['ptName'] as String? ?? '',
              ptId: extra['ptId'] as String? ?? '',
            );
          }
          if (extra is ConversationModel) {
            return MessagingScreen(
              convId: extra.id,
              ptName: extra.ptName,
              ptId: extra.ptId,
            );
          }
          return const Scaffold(
            body: Center(child: Text('Geçersiz konuşma')),
          );
        },
      ),
    ],
  );
});
