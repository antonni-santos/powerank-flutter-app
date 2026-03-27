import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {

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

  //    pesquisa utilizadores por username
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

    final results = snapshot.docs
        .where((doc) => doc.id != currentUser?.uid) // exclui o próprio utilizador
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();

    setState(() {
      _searchResults = results;
      _searching = false;
    });
  }

  //  envia pedido de amizade
  Future<void> _sendFriendRequest(String toId, String toUsername) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final fromUsername = userDoc.data()?['username'] ?? 'Utilizador';

    // verifica se já existe pedido
    final existing = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('fromId', isEqualTo: currentUser.uid)
        .where('toId', isEqualTo: toId)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido já enviado!")),
      );
      return;
    }

    // verifica se já são amigos
    final userDocData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final friends = List<String>.from(userDocData.data()?['friends'] ?? []);
    if (friends.contains(toId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Já são amigos!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('friendRequests').add({
      'fromId': currentUser.uid,
      'fromUsername': fromUsername,
      'toId': toId,
      'toUsername': toUsername,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pedido enviado para $toUsername!")),
    );
  }

  // aceita pedido de amizade
  Future<void> _acceptRequest(String requestId, String fromId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // atualiza o status do pedido
    await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    // adiciona nas listas de amigos de ambos
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'friends': FieldValue.arrayUnion([fromId])});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(fromId)
        .update({'friends': FieldValue.arrayUnion([currentUser.uid])});
  }

  // rejeita pedido de amizade
  Future<void> _rejectRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  // remove amigo
  Future<void> _removeFriend(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'friends': FieldValue.arrayRemove([friendId])});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .update({'friends': FieldValue.arrayRemove([currentUser.uid])});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Amigos"),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Amigos'),
            Tab(text: 'Pedidos'),
            Tab(text: 'Pesquisar'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          // ===== ABA AMIGOS =====
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
              final friends = List<String>.from(data?['friends'] ?? []);

              if (friends.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, color: Colors.grey, size: 60),
                      SizedBox(height: 16),
                      Text(
                        "Ainda não tens amigos",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Pesquisa utilizadores e adiciona amigos!",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(friends[index])
                        .get(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();
                      final friendData = snap.data?.data() as Map<String, dynamic>?;
                      final username = friendData?['username'] ?? 'Utilizador';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Remover amigo"),
                                content: Text("Queres remover $username?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Remover",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _removeFriend(friends[index]);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          // ===== ABA PEDIDOS =====
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('friendRequests')
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
                    "Sem pedidos de amizade",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final data = request.data() as Map<String, dynamic>;
                  final fromUsername = data['fromUsername'] ?? 'Utilizador';
                  final fromId = data['fromId'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        fromUsername.isNotEmpty ? fromUsername[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      fromUsername,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "Quer ser teu amigo",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ACEITAR
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptRequest(request.id, fromId),
                        ),
                        // REJEITAR
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectRequest(request.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // ===== ABA PESQUISAR =====
          Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pesquisar por username...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
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
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final username = user['username'] ?? 'Utilizador';
                    final uid = user['uid'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        username,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.green),
                        onPressed: () => _sendFriendRequest(uid, username),
                      ),
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