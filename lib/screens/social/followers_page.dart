import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/notification_service.dart';

class FollowersPage extends StatefulWidget {
  final int initialTabIndex;

  const FollowersPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  int _safeInitialIndex(int value) {
    if (value < 0) return 0;
    if (value > 2) return 2;
    return value;
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = _safeInitialIndex(widget.initialTabIndex);

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChanged);

    if (initialIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markFollowRequestNotificationsAsRead();
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      _markFollowRequestNotificationsAsRead();
    }
  }

  Future<void> _markFollowRequestNotificationsAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await NotificationService()
        .markFollowRequestNotificationsAsRead(currentUser.uid);
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
          const SnackBar(content: Text('Pedido ja enviado!')),
        );
        return;
      }

      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final myUsername = (myDoc.data()?['username'] ?? 'Utilizador').toString();

      await FirebaseFirestore.instance.collection('followRequests').add({
        'fromId': currentUser.uid,
        'fromUsername': myUsername,
        'toId': targetUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await NotificationService().sendFollowRequestNotification(
        targetUserId: targetUid,
        senderId: currentUser.uid,
        senderUsername: myUsername,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado para $targetUsername!')),
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
        SnackBar(content: Text('Estas a seguir $targetUsername!')),
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

  Future<void> _acceptFollowRequest(String requestId, String fromId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('followRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(fromId)
        .update({'following': FieldValue.arrayUnion([currentUser.uid])});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'followers': FieldValue.arrayUnion([fromId])});

    await _markFollowRequestNotificationsAsRead();
  }

  Future<void> _rejectFollowRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('followRequests')
        .doc(requestId)
        .update({'status': 'rejected'});

    await _markFollowRequestNotificationsAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguidores'),
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
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final following = List<String>.from(data?['following'] ?? []);

              if (following.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, color: Colors.grey, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'Nao segues ninguem ainda',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pesquisa utilizadores para seguir!',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
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
                      if (!snap.hasData || !snap.data!.exists) {
                        return const SizedBox();
                      }

                      final userData =
                          snap.data?.data() as Map<String, dynamic>?;
                      final username =
                          (userData?['username'] ?? 'Utilizador').toString();
                      final isPrivate = userData?['isPrivate'] ?? false;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(username),
                        subtitle: Text(
                          isPrivate ? 'Privado' : 'Publico',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () => _unfollowUser(following[index]),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Deixar de seguir'),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
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
                  child: Text(
                    'Sem pedidos para seguir',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final data = req.data() as Map<String, dynamic>;
                  final fromUsername =
                      (data['fromUsername'] ?? 'Utilizador').toString();
                  final fromId = data['fromId'].toString();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        fromUsername.isNotEmpty
                            ? fromUsername[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(fromUsername),
                    subtitle: const Text(
                      'Quer seguir-te',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptFollowRequest(req.id, fromId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectFollowRequest(req.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por username...',
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
                            (user['username'] ?? 'Utilizador').toString();
                        final uid = user['uid'].toString();
                        final isPrivate = user['isPrivate'] ?? false;
                        final isFollowing = following.contains(uid);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(username),
                          subtitle: Text(
                            isPrivate ? 'Privado' : 'Publico',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: isFollowing
                              ? OutlinedButton(
                                  onPressed: () => _unfollowUser(uid),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text('Seguindo'),
                                )
                              : ElevatedButton(
                                  onPressed: () => _followUser(uid, username),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text(isPrivate ? 'Pedir' : 'Seguir'),
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
