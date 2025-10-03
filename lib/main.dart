import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/card_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/create_card_screen.dart';
import 'screens/scan_card_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/verification_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_router.dart';
import 'services/firebase_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DEBUG: Print to console to verify our app is running
  print("🚀 TRUSTCARD APP STARTING - This is our TrustCard app, not the demo!");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  await FirebaseService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const TrustCardApp());
}

class TrustCardApp extends StatelessWidget {
  const TrustCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          // Initialize LanguageService if not already initialized
          if (languageService.currentLocale.languageCode == 'en') {
            languageService.initialize();
          }
          
          return MaterialApp.router(
            title: 'TrustCard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: languageService.currentLocale,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
