import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/workout_share_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUsers = {};
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _loading = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      _results = snapshot.docs
          .where((doc) => doc.id != currentUser.uid)
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();
      _loading = false;
    });
  }

  Future<void> _createGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolhe um nome e pelo menos um utilizador.'),
        ),
      );
      return;
    }

    final myDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final myUsername = (myDoc.data()?['username'] ?? 'Utilizador').toString();

    await WorkoutShareService().createWorkoutGroup(
      creatorUid: currentUser.uid,
      creatorUsername: myUsername,
      name: name,
      memberIds: _selectedUsers.toList(),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do grupo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar utilizadores',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 12),
            if (_selectedUsers.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_selectedUsers.length} selecionado(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  final uid = user['uid'].toString();
                  final username = (user['username'] ?? 'Utilizador').toString();
                  final selected = _selectedUsers.contains(uid);

                  return CheckboxListTile(
                    value: selected,
                    title: Text(username),
                    subtitle:
                        Text(user['isPrivate'] == true ? 'Privado' : 'Publico'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUsers.add(uid);
                        } else {
                          _selectedUsers.remove(uid);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.groups),
                label: const Text('Criar grupo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
