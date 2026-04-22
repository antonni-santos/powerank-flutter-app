import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerank/services/auth_service.dart';
import 'package:powerank/services/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _changePassword() async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Alterar senha'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Nova senha',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (newPassword == null || newPassword.isEmpty) return;

    try {
      await AuthService().changePassword(newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao alterar senha. Faz login novamente.')),
      );
    }
  }

  Future<void> _updatePrivacy(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final posts = await FirebaseFirestore.instance
        .collection('feed_posts')
        .where('userId', isEqualTo: user.uid)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    batch.set(
      FirebaseFirestore.instance.collection('users').doc(user.uid),
      {'isPrivate': value},
      SetOptions(merge: true),
    );

    for (final doc in posts.docs) {
      batch.update(doc.reference, {'authorIsPrivate': value});
    }

    await batch.commit();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Conta definida como privada'
            : 'Conta definida como publica'),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sobre o Powerank'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Powerank e uma app de monitorizacao de treinos com sistema de ranking competitivo.'),
            SizedBox(height: 12),
            Text('Desenvolvido por Antonni Santos, Vicente Coutinho e João Neves'),
            SizedBox(height: 8),
            Text('Versao 3.20.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Definicoes'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Conta',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Alterar senha'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _changePassword,
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: currentUser == null
                ? null
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final isPrivate = data?['isPrivate'] == true;

              return SwitchListTile(
                secondary: Icon(isPrivate ? Icons.lock_outline : Icons.public),
                title: const Text('Conta privada'),
                subtitle: Text(
                  isPrivate
                      ? 'So seguidores aprovados veem os teus posts no feed'
                      : 'Os teus posts podem aparecer como sugeridos',
                ),
                value: isPrivate,
                activeThumbColor: Colors.green,
                onChanged: _updatePrivacy,
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aparencia',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Modo escuro'),
            value: isDark,
            activeThumbColor: Colors.green,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sobre',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre o Powerank'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _showAbout,
          ),
          const ListTile(
            leading: Icon(Icons.verified),
            title: Text('Versao'),
            trailing: Text('3.20.0'),
          ),
        ],
      ),
    );
  }
}
