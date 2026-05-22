import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/login_page.dart';
import '../features/home/home_shell.dart';
import '../features/home/pages/badges_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/home/pages/map_page.dart';
import '../features/home/pages/more_page.dart';
import '../features/splash/auth_callback_page.dart';
import '../features/splash/splash_page.dart';

/// 로그인/로그아웃 상태 변화를 GoRouter에 알리는 Listenable
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/auth/callback' ||
          state.matchedLocation == '/splash';

      // 비로그인 + 보호 페이지 → 로그인으로
      if (!loggedIn && !goingToAuth) return '/login';
      // 로그인 됨 + 로그인 페이지 → 홈으로
      if (loggedIn && state.matchedLocation == '/login') return '/home';
      // 로그인 됨 + splash → 홈으로
      if (loggedIn && state.matchedLocation == '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/auth/callback',
        builder: (_, __) => const AuthCallbackPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/map', builder: (_, __) => const MapPage()),
          GoRoute(path: '/badges', builder: (_, __) => const BadgesPage()),
          GoRoute(path: '/more', builder: (_, __) => const MorePage()),
        ],
      ),
    ],
  );
});
