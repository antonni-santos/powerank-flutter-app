import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/utils/workout_metrics.dart';

import 'rank_page.dart';
import 'rank_style.dart';

class FriendsRankPage extends StatefulWidget {
  const FriendsRankPage({super.key});

  @override
  State<FriendsRankPage> createState() => _FriendsRankPageState();
}

class _FriendsRankPageState extends State<FriendsRankPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<RankUser>> fetchFriendsRanking() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final friends = List<String>.from(userDoc.data()?['friends'] ?? []);
    final allIds = <String>{currentUser.uid, ...friends};

    return Future.wait(
      allIds.map((uid) async {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final username = (doc.data()?['username'] ?? 'Utilizador').toString();
        final stats = await _firestoreService.getUserWorkoutStats(uid);
        final division = rankDivisionForPoints(stats.points);

        return RankUser(
          uid: uid,
          username: username,
          totalWeight: stats.totalWeight,
          totalDays: stats.checkIns,
          totalLikes: stats.totalLikes,
          points: stats.points,
          division: division.name,
        );
      }),
    );
  }

  List<RankUser> sortUsers(List<RankUser> users, int category) {
    final sorted = List<RankUser>.from(users);
    switch (category) {
      case 0:
        sorted.sort((a, b) => b.points.compareTo(a.points));
      case 1:
        sorted.sort((a, b) => b.totalWeight.compareTo(a.totalWeight));
      case 2:
        sorted.sort((a, b) => b.totalDays.compareTo(a.totalDays));
      case 3:
        sorted.sort((a, b) => b.totalLikes.compareTo(a.totalLikes));
    }
    return sorted;
  }

  String _metricLabel(RankUser rankUser, int category) {
    switch (category) {
      case 0:
        return '${rankUser.points} pts';
      case 1:
        return '${WorkoutMetrics.formatWeight(rankUser.totalWeight)} kg';
      case 2:
        return '${rankUser.totalDays} dias';
      default:
        return '${rankUser.totalLikes} likes';
    }
  }

  Widget _buildRankCard(RankUser rankUser, int position, bool isCurrentUser) {
    final divisionStyle = rankDivisionForName(rankUser.division);
    final metricLabel = _metricLabel(rankUser, _selectedCategory);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            divisionStyle.backgroundColor,
            isCurrentUser ? const Color(0xFF14261E) : const Color(0xFF12161D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? Colors.green.withValues(alpha: 0.75)
              : divisionStyle.color.withValues(alpha: 0.18),
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            buildPositionBadge(position),
            const SizedBox(width: 12),
            buildRankAvatar(username: rankUser.username, style: divisionStyle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          rankUser.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.green : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '(Tu)',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  buildRankDivisionPill(style: divisionStyle, compact: true),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: divisionStyle.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: divisionStyle.color.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                metricLabel,
                style: TextStyle(
                  color: divisionStyle.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPositionCard(RankUser myUser, int myPosition) {
    final divisionStyle = rankDivisionForName(myUser.division);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A tua posicao',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  buildPositionBadge(myPosition + 1),
                  const SizedBox(width: 10),
                  buildRankDivisionPill(style: divisionStyle),
                ],
              ),
            ],
          ),
          Text(
            '${myUser.points} pts',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Rank de Amigos'),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Geral'),
            Tab(text: 'Peso'),
            Tab(text: 'Dias'),
            Tab(text: 'Likes'),
          ],
        ),
      ),
      body: FutureBuilder<List<RankUser>>(
        future: fetchFriendsRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Sem amigos no ranking ainda',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final sorted = sortUsers(snapshot.data!, _selectedCategory);
          final myPosition = sorted.indexWhere(
            (u) => u.uid == currentUser?.uid,
          );
          final myUser = myPosition >= 0 ? sorted[myPosition] : null;

          return Column(
            children: [
              if (myUser != null) ...[
                const SizedBox(height: 12),
                _buildMyPositionCard(myUser, myPosition),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (tabIndex) {
                    final tabSorted = sortUsers(snapshot.data!, tabIndex);
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: tabSorted.length,
                      itemBuilder: (context, index) {
                        final rankUser = tabSorted[index];
                        final isCurrentUser = rankUser.uid == currentUser?.uid;
                        return _buildRankCard(
                          rankUser,
                          index + 1,
                          isCurrentUser,
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
