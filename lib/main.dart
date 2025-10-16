import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/card_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/document_provider.dart';
import 'screens/home_screen.dart';
import 'screens/create_card_screen.dart';
import 'screens/scan_card_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/verification_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_router.dart';
import 'services/firebase_service.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DEBUG: Log to console to verify our app is running
  Logger.info("🚀 TRUSTCARD APP STARTING - This is our TrustCard app, not the demo!");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Logger.info("🔥 Firebase initialized with project: ${Firebase.app().options.projectId}");
  Logger.info("🔥 Firebase messagingSenderId: ${Firebase.app().options.messagingSenderId}");
  await FirebaseService.initialize();
  
  // Initialize Firebase Messaging for push notifications
  await _initializeFirebaseMessaging();
  
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
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
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
            themeMode: ThemeMode.light,
            locale: languageService.currentLocale,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

/// Initialize Firebase Messaging for push notifications
Future<void> _initializeFirebaseMessaging() async {
  try {
    // Request permission for notifications
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('✅ Push notification permission granted');
    } else {
      Logger.warning('❌ Push notification permission denied');
    }

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('📱 Received foreground message: ${message.notification?.title}');
      // Handle foreground message display
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.info('📱 Notification tapped: ${message.notification?.title}');
      // Handle notification tap navigation
    });

    // Get FCM token
    final token = await messaging.getToken();
    if (token != null) {
      Logger.info('🔑 FCM Token: $token');
    }

    Logger.info('✅ Firebase Messaging initialized successfully');
  } catch (e) {
    Logger.error('❌ Error initializing Firebase Messaging: $e');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger.info('📱 Background message received: ${message.notification?.title}');
  // Handle background message processing
}
