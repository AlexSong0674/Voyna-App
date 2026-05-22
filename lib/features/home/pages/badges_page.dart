import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final supa = Supabase.instance.client;
    final uid = supa.auth.currentUser?.id;

    // 모든 배지 + 사용자 획득 여부
    final badges = await supa
        .from('badges')
        .select('id, name, grade, xp_reward, icon, color_hex, location_id, locations(name, district, category)')
        .order('id');

    Set<int> obtained = {};
    if (uid != null) {
      final ub = await supa
          .from('user_badges')
          .select('badge_id')
          .eq('user_id', uid);
      obtained = (ub as List).map((r) => r['badge_id'] as int).toSet();
    }

    return badges.map<Map<String, dynamic>>((b) {
      return {
        ...Map<String, dynamic>.from(b),
        'obtained': obtained.contains(b['id']),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏅 배지 컬렉션')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('에러: ${snap.error}'));
          }
          final badges = snap.data ?? [];
          final obtainedCount = badges.where((b) => b['obtained'] == true).length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: VoynaColors.blue.withValues(alpha: 0.1),
                child: Text(
                  '$obtainedCount / ${badges.length} 획득',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final Map<String, dynamic> badge;

  @override
  Widget build(BuildContext context) {
    final obtained = badge['obtained'] == true;
    final grade = badge['grade'] as String;
    final icon = badge['icon'] as String? ?? '🏅';
    final name = badge['name'] as String;

    Color bg;
    switch (grade) {
      case 'special':
        bg = VoynaColors.gradeSpecial;
        break;
      case 'rare':
        bg = VoynaColors.gradeRare;
        break;
      case 'premier':
        bg = VoynaColors.gradePremier;
        break;
      default:
        bg = VoynaColors.gradeCommon;
    }

    return Container(
      decoration: BoxDecoration(
        color: obtained ? bg : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: obtained ? 1 : 0.3,
            child: Text(icon, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: obtained ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            obtained ? '+${badge['xp_reward']} XP' : '미수집',
            style: TextStyle(
              fontSize: 9,
              color: obtained ? Colors.black54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
