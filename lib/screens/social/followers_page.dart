<<<<<<< HEAD
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
=======
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage>
    with SingleTickerProviderStateMixin {
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

<<<<<<< HEAD
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
=======
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _tabController.removeListener(_handleTabChanged);
=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
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

=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
<<<<<<< HEAD

    setState(() => _searching = true);

=======
    setState(() => _searching = true);
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
<<<<<<< HEAD

=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
          const SnackBar(content: Text('Pedido ja enviado!')),
=======
          const SnackBar(content: Text("Pedido já enviado!")),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
        );
        return;
      }

      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
<<<<<<< HEAD
      final myUsername = (myDoc.data()?['username'] ?? 'Utilizador').toString();
=======
      final myUsername = myDoc.data()?['username'] ?? 'Utilizador';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

      await FirebaseFirestore.instance.collection('followRequests').add({
        'fromId': currentUser.uid,
        'fromUsername': myUsername,
        'toId': targetUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

<<<<<<< HEAD
      await NotificationService().sendFollowRequestNotification(
        targetUserId: targetUid,
        senderId: currentUser.uid,
        senderUsername: myUsername,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado para $targetUsername!')),
=======
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pedido enviado para $targetUsername!")),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
        SnackBar(content: Text('Estas a seguir $targetUsername!')),
      );
    }

=======
        SnackBar(content: Text("Estás a seguir $targetUsername!")),
      );
    }
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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

<<<<<<< HEAD
  Future<void> _acceptFollowRequest(String requestId, String fromId) async {
=======
  Future<void> _acceptFollowRequest(
      String requestId, String fromId) async {
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('followRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(fromId)
<<<<<<< HEAD
        .update({'following': FieldValue.arrayUnion([currentUser.uid])});
=======
        .update(
            {'following': FieldValue.arrayUnion([currentUser.uid])});
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'followers': FieldValue.arrayUnion([fromId])});
<<<<<<< HEAD

    await _markFollowRequestNotificationsAsRead();
=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  }

  Future<void> _rejectFollowRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('followRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
<<<<<<< HEAD

    await _markFollowRequestNotificationsAsRead();
=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Seguidores'),
=======
        title: const Text("Seguidores"),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
      body: TabBarView(
        controller: _tabController,
        children: [
=======

      body: TabBarView(
        controller: _tabController,
        children: [

          // ===== A SEGUIR =====
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
<<<<<<< HEAD

              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final following = List<String>.from(data?['following'] ?? []);
=======
              final data =
                  snapshot.data?.data() as Map<String, dynamic>?;
              final following =
                  List<String>.from(data?['following'] ?? []);
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

              if (following.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, color: Colors.grey, size: 60),
                      SizedBox(height: 16),
<<<<<<< HEAD
                      Text(
                        'Nao segues ninguem ainda',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pesquisa utilizadores para seguir!',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
=======
                      Text("Não seguis ninguém ainda",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text("Pesquisa utilizadores para seguir!",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13)),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
                      if (!snap.hasData || !snap.data!.exists) {
                        return const SizedBox();
                      }

                      final userData =
                          snap.data?.data() as Map<String, dynamic>?;
                      final username =
                          (userData?['username'] ?? 'Utilizador').toString();
                      final isPrivate = userData?['isPrivate'] ?? false;
=======
                      if (!snap.hasData) return const SizedBox();
                      final userData =
                          snap.data?.data() as Map<String, dynamic>?;
                      final username =
                          userData?['username'] ?? 'Utilizador';
                      final isPrivate =
                          userData?['isPrivate'] ?? false;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '?',
<<<<<<< HEAD
                            style: const TextStyle(color: Colors.white),
=======
                            style:
                                const TextStyle(color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                          ),
                        ),
                        title: Text(username),
                        subtitle: Text(
<<<<<<< HEAD
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
=======
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
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
<<<<<<< HEAD
=======

          // ===== PEDIDOS =====
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD

=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              final requests = snapshot.data?.docs ?? [];

              if (requests.isEmpty) {
                return const Center(
<<<<<<< HEAD
                  child: Text(
                    'Sem pedidos para seguir',
                    style: TextStyle(color: Colors.grey),
                  ),
=======
                  child: Text("Sem pedidos para seguir",
                      style: TextStyle(color: Colors.grey)),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final data = req.data() as Map<String, dynamic>;
                  final fromUsername =
<<<<<<< HEAD
                      (data['fromUsername'] ?? 'Utilizador').toString();
                  final fromId = data['fromId'].toString();
=======
                      data['fromUsername'] ?? 'Utilizador';
                  final fromId = data['fromId'];
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        fromUsername.isNotEmpty
                            ? fromUsername[0].toUpperCase()
                            : '?',
<<<<<<< HEAD
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(fromUsername),
                    subtitle: const Text(
                      'Quer seguir-te',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
=======
                        style:
                            const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(fromUsername),
                    subtitle: const Text("Quer seguir-te",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12)),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
<<<<<<< HEAD
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptFollowRequest(req.id, fromId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectFollowRequest(req.id),
=======
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
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
<<<<<<< HEAD
=======

          // ===== PESQUISAR =====
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
<<<<<<< HEAD
                    hintText: 'Pesquisar por username...',
=======
                    hintText: "Pesquisar por username...",
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
                            (user['username'] ?? 'Utilizador').toString();
                        final uid = user['uid'].toString();
                        final isPrivate = user['isPrivate'] ?? false;
=======
                            user['username'] ?? 'Utilizador';
                        final uid = user['uid'];
                        final isPrivate =
                            user['isPrivate'] ?? false;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        final isFollowing = following.contains(uid);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
<<<<<<< HEAD
                              style: const TextStyle(color: Colors.white),
=======
                              style: const TextStyle(
                                  color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                            ),
                          ),
                          title: Text(username),
                          subtitle: Text(
<<<<<<< HEAD
                            isPrivate ? 'Privado' : 'Publico',
=======
                            isPrivate ? '🔒 Privado' : '🌍 Público',
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: isFollowing
                              ? OutlinedButton(
<<<<<<< HEAD
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
=======
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
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
