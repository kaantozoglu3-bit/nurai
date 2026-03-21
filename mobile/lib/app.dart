import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/locale_provider.dart';

class PainReliefApp extends ConsumerWidget {
  const PainReliefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'PainRelief AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: locale,
      supportedLocales: const [Locale('tr'), Locale('en')],
    );
  }
}
