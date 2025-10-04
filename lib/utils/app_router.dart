import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/create_card_screen.dart';
import '../screens/scan_card_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/card_detail_screen.dart';
import '../screens/document_upload_screen.dart';
import '../screens/colleague_verification_screen.dart';
import '../screens/activity_feed_screen.dart';
import '../screens/company_admin_screen.dart';
import '../screens/company_employee_management_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/my_cards_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.uri.path == '/auth';
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      // Auth Screen
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // Main navigation shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/scan',
            name: 'scan',
            builder: (context, state) => const ScanCardScreen(),
          ),
          GoRoute(
            path: '/activity',
            name: 'activity',
            builder: (context, state) => const ActivityFeedScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Modal screens
      GoRoute(
        path: '/create-card',
        name: 'create-card',
        builder: (context, state) => const CreateCardScreen(),
      ),
      GoRoute(
        path: '/verification',
        name: 'verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/document-upload',
        name: 'document-upload',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: '/colleague-verification',
        name: 'colleague-verification',
        builder: (context, state) => const ColleagueVerificationScreen(),
      ),
      GoRoute(
        path: '/card-detail/:cardId',
        name: 'card-detail',
        builder: (context, state) {
          final cardId = state.pathParameters['cardId']!;
          return CardDetailScreen(cardId: cardId);
        },
      ),
      GoRoute(
        path: '/company-admin',
        name: 'company-admin',
        builder: (context, state) => const CompanyAdminScreen(),
      ),
      GoRoute(
        path: '/company-employees',
        name: 'company-employees',
        builder: (context, state) => const CompanyEmployeeManagementScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/my-cards',
        name: 'my-cards',
        builder: (context, state) => const MyCardsScreen(),
      ),
    ],
  );
}

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_outlined),
            activeIcon: Icon(Icons.timeline),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0;
      case '/scan':
        return 1;
      case '/activity':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/scan');
        break;
      case 2:
        context.go('/activity');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
