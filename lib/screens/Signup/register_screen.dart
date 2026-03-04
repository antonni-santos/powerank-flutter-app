import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../consts.dart';
import '../Login/login_screen.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [g1, g2],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.03),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(image1),

                const SizedBox(height: 16),

                const Text(
                  "Bem vindo!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: kWhiteColor,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Registrar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    color: kWhiteColor,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                //Espaço para o Usuario inserir o nome
                TextField(
                  keyboardType: TextInputType.name,
                  style: const TextStyle(color: kInputColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    hintText: "Nome",
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                //Espaço para colocar o Email
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kInputColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    hintText: "Email",
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                //Senha
                TextField(
                  obscureText: true,
                  style: const TextStyle(color: kInputColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    hintText: "Senha",
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                //Confirmar a senha
                TextField(
                  obscureText: true,
                  style: const TextStyle(color: kInputColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    hintText: "Confirmar Senha",
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botão para registrar
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final auth = AuthService();

                    bool created = await auth.register(
                      "Teste",
                      "teste@email.com",
                      "1234",
                    );

                    print("Criado: $created");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                      color: KButtonColor,
                      borderRadius: BorderRadius.circular(37),
                    ),
                    child: const Text(
                      "Registrar",
                      style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Já tem uma conta?",
                  style: TextStyle(color: kWhiteColor),
                ),

                const SizedBox(height: 12),

                //Botão para acesso da pagina de login
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(37),
                      color: const Color.fromRGBO(225, 225, 225, 0.28),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 45,
                          color: Color.fromRGBO(120, 37, 139, 0.25),
                          offset: Offset(0, 25),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
