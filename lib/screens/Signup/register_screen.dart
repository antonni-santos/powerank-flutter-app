import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../consts.dart';
import '../Login/login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

                // USERNAME
                TextField(
                  controller: usernameController,
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

                // EMAIL
                TextField(
                  controller: emailController,
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

                // PASSWORD
                TextField(
                  controller: passwordController,
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

                const SizedBox(height: 20),

                // BOTÃO REGISTRAR
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {

                    final auth = AuthService();

                    bool created = await auth.register(
                      usernameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    print("Criado: $created");

                    if(created){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Usuário criado!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email já existe")),
                      );
                    }
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

                // BOTÃO LOGIN
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