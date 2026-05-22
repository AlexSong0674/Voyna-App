import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? user?.userMetadata?['email'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('⚙ 더보기')),
      body: ListView(
        children: [
          if (email.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                '로그인: $email',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const _SectionHeader('이벤트 & 미션'),
          const _Tile(icon: Icons.celebration, title: '진행 중 이벤트', subtitle: 'V1.1에서 활성화'),
          const _Tile(icon: Icons.flag, title: '미션 / 퀘스트', subtitle: 'V1.4에서 활성화'),

          const _SectionHeader('소셜'),
          const _Tile(icon: Icons.people, title: '친구', subtitle: 'V1.3에서 활성화'),
          const _Tile(icon: Icons.leaderboard, title: '랭킹', subtitle: 'V1.3에서 활성화'),

          const _SectionHeader('설정'),
          const _Tile(icon: Icons.notifications, title: '알림 설정'),
          const _Tile(icon: Icons.location_on, title: '위치 권한'),
          const _Tile(icon: Icons.language, title: '언어'),

          const _SectionHeader('정보'),
          const _Tile(icon: Icons.privacy_tip, title: '개인정보 처리방침'),
          const _Tile(icon: Icons.description, title: '서비스 이용약관'),
          const _Tile(icon: Icons.info_outline, title: '버전', subtitle: '1.0.0 (MVP)'),

          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                // GoRouter가 자동으로 /login으로 리다이렉트
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title — 추후 구현 예정'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
