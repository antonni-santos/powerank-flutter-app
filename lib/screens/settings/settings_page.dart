import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Definições"),
        backgroundColor: Colors.black,
      ),

      body: ListView(
        children: [

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Conta",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Editar perfil", style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            onTap: () {
              // TODO: navegar para editar perfil
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock, color: Colors.white),
            title: const Text("Alterar senha", style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            onTap: () {
              // TODO: navegar para alterar senha
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text("Notificações", style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            onTap: () {
              // TODO: configurar notificações
            },
          ),

          const Divider(color: Colors.grey),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Sobre",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text("Sobre o PoweRank", style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            onTap: () {
              // TODO: página sobre
            },
          ),

          const ListTile(
            leading: Icon(Icons.verified, color: Colors.white),
            title: Text("Versão", style: TextStyle(color: Colors.white)),
            trailing: Text("1.0.0", style: TextStyle(color: Colors.grey)),
          ),

        ],
      ),
    );
  }
}