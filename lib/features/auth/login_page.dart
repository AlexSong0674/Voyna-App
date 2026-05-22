import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _busy = false;

  Future<void> _signIn(OAuthProvider provider) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // 웹: URL 리다이렉트, 모바일: 외부 브라우저 → 딥링크 콜백
      final redirectTo = kIsWeb ? '${Uri.base.origin}/auth/callback' : null;

      // 카카오 email 스코프 제외는 Supabase 측 설정(external_kakao_email_optional=true)으로 처리됨
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectTo,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Center(child: Text('🗺', style: TextStyle(fontSize: 72))),
              const SizedBox(height: 16),
              Text(
                'Voyna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: VoynaColors.blue,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '발걸음이 기록이 되고,\n기록이 추억이 된다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
              const Spacer(flex: 3),
              _LoginButton(
                label: 'Google로 시작하기',
                background: Colors.white,
                foreground: Colors.black87,
                icon: 'G',
                border: BorderSide(color: Colors.grey.shade300),
                onTap: _busy ? null : () => _signIn(OAuthProvider.google),
              ),
              const SizedBox(height: 12),
              // 카카오 로그인은 V1.1에서 비즈 앱 인증 또는 커스텀 OAuth로 지원 예정
              _LoginButton(
                label: '카카오로 시작 (곧 출시)',
                background: const Color(0xFFFEE500).withValues(alpha: 0.4),
                foreground: const Color(0xFF666666),
                icon: '💬',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('카카오 로그인은 곧 출시됩니다. 지금은 Google로 시작해주세요.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                '계속 진행하면 서비스 이용약관 및 개인정보 처리방침에 동의합니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const Spacer(flex: 1),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final String icon;
  final BorderSide? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: border ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
