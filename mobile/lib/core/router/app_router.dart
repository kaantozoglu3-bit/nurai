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
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/help/help_support_screen.dart';
import '../../presentation/screens/legal/privacy_policy_screen.dart';
import '../../presentation/screens/notifications/notification_settings_screen.dart';
import '../../presentation/screens/sports_injury/sports_injury_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/navigation_provider.dart';
// navigation_provider.dart is set by callers before pushing analysisResult /
// videoPlayer / ptDetail / messaging routes; the screens read from it directly.

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
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';
  static const String notifications = '/notifications';
  static const String privacyPolicy = '/privacy-policy';
  static const String sportsInjury = '/sports-injury';
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
          // Data is stored in analysisResultDataProvider by the caller
          // (e.g. ChatScreen) before navigating. Passing an empty map here
          // tells the screen to read from the provider instead, which avoids
          // the state.extra breakage on deep links.
          return const AnalysisResultScreen(analysisData: {});
        },
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          // Data is stored in videoPlayerDataProvider by the caller before
          // navigating. Passing an empty map here tells the screen to read
          // from the provider instead of state.extra.
          return const VideoPlayerScreen(videoData: {});
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
          // Data is stored in ptDetailDataProvider by the caller before
          // navigating. No state.extra fallback — deep link safe.
          final pt = ref.read(ptDetailDataProvider);
          if (pt == null) {
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
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.sportsInjury,
        builder: (context, state) => const SportsInjuryScreen(),
      ),
      GoRoute(
        path: AppRoutes.messaging,
        builder: (context, state) {
          // Data is stored in messagingDataProvider by the caller before
          // navigating. No state.extra fallback — deep link safe.
          final conv = ref.read(messagingDataProvider);
          if (conv != null) {
            return MessagingScreen(
              convId: conv.id,
              ptName: conv.ptName,
              ptId: conv.ptId,
            );
          }
          // No conversation data available — redirect to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRoutes.home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    ],
  );
});
