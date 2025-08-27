// File: lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/l10n/app_localizations.dart';
import 'package:snaprent/models/auth_state.dart';
import 'package:snaprent/providers/auth_provider.dart';
import 'package:snaprent/providers/language_provider.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/services/route_observer.dart';
import 'screens/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'core/themes.dart';

// Use a GlobalKey to manage the NavigatorState
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final onboardingSeenProvider = Provider<bool>((ref) => false);
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => throw UnimplementedError(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWithValue(seenOnboarding),
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(
            prefs,
            WidgetsBinding.instance.platformDispatcher.locale,
          ),
        ),
        authProvider.overrideWith((ref) {
          final notifier = AuthNotifier(
            prefs,
            ApiService.refreshTokenFn, // Pass the static function here
          );
          notifier.loadFromStorage();
          return notifier;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_isRefreshing) return;
      _isRefreshing = true;
      try {
        await ref.read(authProvider.notifier).refreshIfNeeded();
      } catch (e) {
        debugPrint('Error refreshing token: $e');
      } finally {
        _isRefreshing = false;
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seenOnboarding = ref.watch(onboardingSeenProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      // Use the global key directly
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SnapRent',
      theme: lightTheme,
      navigatorObservers: [routeObserver],
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: seenOnboarding
              ? const MainNavigation()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
