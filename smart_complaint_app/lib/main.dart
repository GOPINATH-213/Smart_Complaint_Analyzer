import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/config/app_config.dart';
import 'firebase_options.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // GoogleFonts runtime fetching is enabled by default.
  
  // Initialize configuration and validate variables
  await AppConfig.initialize();

  // Initialize Shared Preferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('----------------------------------------------------');
    debugPrint('Warning: Firebase could not be initialized.');
    debugPrint('Error: $e');
    debugPrint('----------------------------------------------------');
  }

  // Initialize Google Sign-In (optional/conditional on platform client configuration)
  try {
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint('----------------------------------------------------');
    debugPrint('Warning: GoogleSignIn could not be initialized (Web/Desktop credentials may be missing).');
    debugPrint('Error: $e');
    debugPrint('----------------------------------------------------');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // Initialize notifications (won't block UI)
    ref.listenManual(initializeNotificationsProvider, (_, __) {});
    
    // Bind notification tap handler
    ref.listenManual(notificationTapHandlerProvider, (_, __) {});

    return MaterialApp.router(
      title: 'Smart Complaint Analyzer',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
