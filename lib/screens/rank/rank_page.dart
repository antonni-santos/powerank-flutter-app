import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friends_rank_page.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class RankUser {
  final String uid;
  final String username;
  final double totalWeight;
  final int totalDays;     
  final int totalLikes;
  final int points;
  final String division;
  final String divisionEmoji;

  RankUser({
    required this.uid,
    required this.username,
    required this.totalWeight,
    required this.totalDays,
    required this.totalLikes,
    required this.points,
    required this.division,
    required this.divisionEmoji,
  });
}

class _RankPageState extends State<RankPage> with SingleTickerProviderStateMixin {

  late TabController _tabController;
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

  int calculatePoints({
    required double totalWeight,
    required int totalDays,
    required int totalLikes,
  }) {
    final weightPoints = (totalWeight / 100).floor();
    final daysPoints = totalDays * 50;     // 👈 agora usa dias de check-in
    final likesPoints = totalLikes * 10;
    return weightPoints + daysPoints + likesPoints;
  }

  Map<String, String> getDivision(int points) {
    if (points >= 150000) return {'name': 'Champion', 'emoji': '👑'};
    if (points >= 70000) return {'name': 'Diamond', 'emoji': '💠'};
    if (points >= 35000) return {'name': 'Platinum', 'emoji': '💎'};
    if (points >= 15000) return {'name': 'Gold', 'emoji': '🥇'};
    if (points >= 5000) return {'name': 'Silver', 'emoji': '🥈'};
    if (points >= 1000) return {'name': 'Bronze', 'emoji': '🥉'};
    return {'name': 'Iron', 'emoji': '🪨'};
  }

  Color getDivisionColor(String division) {
    switch (division) {
      case 'Champion': return const Color(0xFFFFD700);
      case 'Diamond': return const Color(0xFF00CFFF);
      case 'Platinum': return const Color(0xFF00E5CC);
      case 'Gold': return const Color(0xFFFFB300);
      case 'Silver': return const Color(0xFFB0BEC5);
      case 'Bronze': return const Color(0xFFCD7F32);
      default: return const Color(0xFF78909C);
    }
  }

  // 👈 busca os dias de check-in de um utilizador
  Future<int> _fetchCheckInDays(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('checkins')
        .doc(uid)
        .get();
    final dates = List<String>.from(doc.data()?['dates'] ?? []);
    return dates.length;
  }

  Future<List<RankUser>> fetchRanking() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final List<RankUser> rankUsers = [];

    for (final userDoc in usersSnapshot.docs) {
      final uid = userDoc.id;
      final username = userDoc.data()['username'] ?? 'Utilizador';

      final workoutsSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('userId', isEqualTo: uid)
          .get();

      double totalWeight = 0;
      int totalLikes = 0;

      for (final workout in workoutsSnapshot.docs) {
        final data = workout.data();
        totalWeight += (data['totalWeight'] ?? 0).toDouble();
        totalLikes += (data['likes'] ?? 0) as int;
      }

      final totalDays = await _fetchCheckInDays(uid); // 👈 usa check-ins

      final points = calculatePoints(
        totalWeight: totalWeight,
        totalDays: totalDays,
        totalLikes: totalLikes,
      );

      final division = getDivision(points);

      rankUsers.add(RankUser(
        uid: uid,
        username: username,
        totalWeight: totalWeight,
        totalDays: totalDays,
        totalLikes: totalLikes,
        points: points,
        division: division['name']!,
        divisionEmoji: division['emoji']!,
      ));
    }

    return rankUsers;
  }

  List<RankUser> sortUsers(List<RankUser> users, int category) {
    final sorted = List<RankUser>.from(users);
    switch (category) {
      case 0: sorted.sort((a, b) => b.points.compareTo(a.points)); break;
      case 1: sorted.sort((a, b) => b.totalWeight.compareTo(a.totalWeight)); break;
      case 2: sorted.sort((a, b) => b.totalDays.compareTo(a.totalDays)); break; // 👈
      case 3: sorted.sort((a, b) => b.totalLikes.compareTo(a.totalLikes)); break;
    }
    return sorted.take(50).toList();
  }

  Widget _buildRankCard(RankUser rankUser, int position, bool isCurrentUser) {
    final divisionColor = getDivisionColor(rankUser.division);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green.withOpacity(0.15) : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: Colors.green, width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [

            SizedBox(
              width: 36,
              child: Text(
                position <= 3
                    ? ['🥇', '🥈', '🥉'][position - 1]
                    : '#$position',
                style: TextStyle(
                  color: position <= 3 ? Colors.amber : Colors.grey,
                  fontSize: position <= 3 ? 20 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(width: 12),

            CircleAvatar(
              backgroundColor: divisionColor.withOpacity(0.3),
              child: Text(
                rankUser.username.isNotEmpty
                    ? rankUser.username[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: divisionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rankUser.username,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
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
                  Text(
                    '${rankUser.divisionEmoji} ${rankUser.division}',
                    style: TextStyle(color: divisionColor, fontSize: 12),
                  ),
                ],
              ),
            ),

            Text(
              _selectedCategory == 0
                  ? '${rankUser.points} pts'
                  : _selectedCategory == 1
                      ? '${rankUser.totalWeight.toStringAsFixed(0)} kg'
                      : _selectedCategory == 2
                          ? '${rankUser.totalDays} dias'  // 👈
                          : '${rankUser.totalLikes} likes',
              style: TextStyle(
                color: divisionColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('🏆 Rank'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: Colors.white),
            tooltip: 'Rank de Amigos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendsRankPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Geral'),
            Tab(text: '💪 Peso'),
            Tab(text: '📅 Dias'),
            Tab(text: '❤️ Likes'),
          ],
        ),
      ),

      body: FutureBuilder<List<RankUser>>(
        future: fetchRanking(),
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
                'Sem utilizadores no ranking ainda',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final sorted = sortUsers(snapshot.data!, _selectedCategory);
          final myPosition = sorted.indexWhere((u) => u.uid == currentUser?.uid);
          final myUser = myPosition >= 0 ? sorted[myPosition] : null;

          return Column(
            children: [

              if (myUser != null) ...[
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A tua posição',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            '#${myPosition + 1} — ${myUser.divisionEmoji} ${myUser.division}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                ),
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
                        return _buildRankCard(rankUser, index + 1, isCurrentUser);
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