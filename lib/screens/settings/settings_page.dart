import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_notifier.dart';
import '../Login/login_screen.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _changePassword() async {
    final user = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Alterar senha"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Nova senha",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (user != null && user.isNotEmpty) {
      try {
        await AuthService().changePassword(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Senha alterada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao alterar senha. Faz login novamente."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sobre o PoweRank"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PoweRank é uma app de monitorização de treinos com sistema de ranking competitivo."),
            SizedBox(height: 12),
            Text("Desenvolvido por Antonni Santos"),
            SizedBox(height: 8),
            Text("Versão 1.0.0"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Definições"),
      ),

      body: ListView(
        children: [

          // CONTA
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Conta",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Alterar senha"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _changePassword,
          ),

          // APARÊNCIA
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Aparência",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 👈 toggle modo claro/escuro
          SwitchListTile(
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            title: const Text("Modo escuro"),
            value: isDark,
            activeThumbColor: Colors.green,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),

          // SOBRE
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Sobre",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Sobre o PoweRank"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _showAbout,
          ),

          const ListTile(
            leading: Icon(Icons.verified),
            title: Text("Versão"),
            trailing: Text("1.0.0"),
          ),

        ],
      ),
    );
  }
}