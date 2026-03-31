import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/social/public_profile_page.dart';

class UserConnectionsPage extends StatefulWidget {
  final String userId;
  final String username;
  final int initialTabIndex;

  const UserConnectionsPage({
    super.key,
    required this.userId,
    required this.username,
    this.initialTabIndex = 0,
  });

  @override
  State<UserConnectionsPage> createState() => _UserConnectionsPageState();
}

class _UserConnectionsPageState extends State<UserConnectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildUsersList(List<String> ids, String emptyText) {
    if (ids.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      itemCount: ids.length,
      itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(ids[index])
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const SizedBox();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final username = (data['username'] ?? 'Utilizador').toString();
            final photoUrl = (data['photoUrl'] ?? '').toString();
            final isPrivate = data['isPrivate'] == true;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?')
                    : null,
              ),
              title: Text(username),
              subtitle: Text(isPrivate ? 'Privado' : 'Publico'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicProfilePage(userId: ids[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Seguidores'),
            Tab(text: 'A seguir'),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final followers = List<String>.from(data?['followers'] ?? []);
          final following = List<String>.from(data?['following'] ?? []);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUsersList(followers, 'Sem seguidores ainda'),
              _buildUsersList(following, 'Nao segue ninguem ainda'),
            ],
          );
        },
      ),
    );
  }
}
