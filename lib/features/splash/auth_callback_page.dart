import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  String _status = '인증 처리 중...';

  @override
  void initState() {
    super.initState();
    _waitForSession();
  }

  Future<void> _waitForSession() async {
    final supa = Supabase.instance.client;

    // supabase_flutter가 URL fragment에서 토큰을 처리할 시간을 충분히 기다림
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      if (supa.auth.currentSession != null) {
        setState(() => _status = '로그인 완료, 이동 중...');
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        context.go('/home');
        return;
      }
    }

    // 6초 후에도 세션 없음 → 로그인 페이지로 복귀
    if (!mounted) return;
    setState(() => _status = '인증 정보를 받지 못했어요. 다시 시도해주세요.');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(_status, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
