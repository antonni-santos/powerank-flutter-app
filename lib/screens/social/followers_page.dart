import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    setState(() {
      _searchResults = snapshot.docs
          .where((doc) => doc.id != currentUser?.uid)
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();
      _searching = false;
    });
  }

  Future<void> _followUser(String targetUid, String targetUsername) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final targetDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .get();
    final isPrivate = targetDoc.data()?['isPrivate'] ?? false;

    if (isPrivate) {
      final existing = await FirebaseFirestore.instance
          .collection('followRequests')
          .where('fromId', isEqualTo: currentUser.uid)
          .where('toId', isEqualTo: targetUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido já enviado!")),
        );
        return;
      }

      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final myUsername = myDoc.data()?['username'] ?? 'Utilizador';

      await FirebaseFirestore.instance.collection('followRequests').add({
        'fromId': currentUser.uid,
        'fromUsername': myUsername,
        'toId': targetUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pedido enviado para $targetUsername!")),
      );
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'following': FieldValue.arrayUnion([targetUid])});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .update({'followers': FieldValue.arrayUnion([currentUser.uid])});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estás a seguir $targetUsername!")),
      );
    }
    setState(() {});
  }

  Future<void> _unfollowUser(String targetUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'following': FieldValue.arrayRemove([targetUid])});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .update({'followers': FieldValue.arrayRemove([currentUser.uid])});

    setState(() {});
  }

  Future<void> _acceptFollowRequest(
      String requestId, String fromId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('followRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(fromId)
        .update(
            {'following': FieldValue.arrayUnion([currentUser.uid])});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'followers': FieldValue.arrayUnion([fromId])});
  }

  Future<void> _rejectFollowRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('followRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seguidores"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'A seguir'),
            Tab(text: 'Pedidos'),
            Tab(text: 'Pesquisar'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          // ===== A SEGUIR =====
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data =
                  snapshot.data?.data() as Map<String, dynamic>?;
              final following =
                  List<String>.from(data?['following'] ?? []);

              if (following.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, color: Colors.grey, size: 60),
                      SizedBox(height: 16),
                      Text("Não seguis ninguém ainda",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text("Pesquisa utilizadores para seguir!",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: following.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(following[index])
                        .get(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();
                      final userData =
                          snap.data?.data() as Map<String, dynamic>?;
                      final username =
                          userData?['username'] ?? 'Utilizador';
                      final isPrivate =
                          userData?['isPrivate'] ?? false;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '?',
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(username),
                        subtitle: Text(
                          isPrivate ? '🔒 Privado' : '🌍 Público',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () =>
                              _unfollowUser(following[index]),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side:
                                const BorderSide(color: Colors.red),
                          ),
                          child: const Text("Deixar de seguir"),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          // ===== PEDIDOS =====
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('followRequests')
                .where('toId', isEqualTo: currentUser?.uid)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final requests = snapshot.data?.docs ?? [];

              if (requests.isEmpty) {
                return const Center(
                  child: Text("Sem pedidos para seguir",
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final data = req.data() as Map<String, dynamic>;
                  final fromUsername =
                      data['fromUsername'] ?? 'Utilizador';
                  final fromId = data['fromId'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        fromUsername.isNotEmpty
                            ? fromUsername[0].toUpperCase()
                            : '?',
                        style:
                            const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(fromUsername),
                    subtitle: const Text("Quer seguir-te",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check,
                              color: Colors.green),
                          onPressed: () =>
                              _acceptFollowRequest(req.id, fromId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red),
                          onPressed: () =>
                              _rejectFollowRequest(req.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // ===== PESQUISAR =====
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Pesquisar por username...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _searchUsers,
                ),
              ),
              if (_searching)
                const Center(child: CircularProgressIndicator()),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser?.uid)
                      .snapshots(),
                  builder: (context, mySnap) {
                    final myData =
                        mySnap.data?.data() as Map<String, dynamic>?;
                    final following =
                        List<String>.from(myData?['following'] ?? []);

                    return ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final username =
                            user['username'] ?? 'Utilizador';
                        final uid = user['uid'];
                        final isPrivate =
                            user['isPrivate'] ?? false;
                        final isFollowing = following.contains(uid);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                          ),
                          title: Text(username),
                          subtitle: Text(
                            isPrivate ? '🔒 Privado' : '🌍 Público',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: isFollowing
                              ? OutlinedButton(
                                  onPressed: () =>
                                      _unfollowUser(uid),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(
                                        color: Colors.red),
                                  ),
                                  child: const Text("Seguindo"),
                                )
                              : ElevatedButton(
                                  onPressed: () =>
                                      _followUser(uid, username),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text(
                                      isPrivate ? "Pedir" : "Seguir"),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}