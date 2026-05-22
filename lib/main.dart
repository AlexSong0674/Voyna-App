import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'core/router.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Path 기반 URL (해시 # 제거) — OAuth 콜백 URL 호환성
  usePathUrlStrategy();

  // 환경변수 로드
  await dotenv.load(fileName: '.env');

  // Supabase 초기화 — 만료된 세션이 있으면 throw 가능. 그 경우 한 번 재시도.
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
    );
  } catch (e) {
    debugPrint('Supabase init failed once, retrying: $e');
    await Future.delayed(const Duration(milliseconds: 500));
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  // 만료된 세션 자동 정리
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.isExpired) {
      try {
        await Supabase.instance.client.auth.refreshSession();
      } catch (_) {
        await Supabase.instance.client.auth
            .signOut(scope: SignOutScope.local);
      }
    }
  } catch (e) {
    debugPrint('Session cleanup error (ignored): $e');
  }

  runApp(const ProviderScope(child: VoynaApp()));
}

class VoynaApp extends ConsumerWidget {
  const VoynaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Voyna',
      debugShowCheckedModeBanner: false,
      theme: voynaLightTheme,
      darkTheme: voynaDarkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
