import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../home/main_navigation.dart';
import '../../consts.dart';
import '../../services/auth_service.dart';
import '../Reset/reset_password.dart';
import '../Signup/register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _showPassword = false; 

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
                  "Bem vindo de volta!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: kWhiteColor,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    color: kWhiteColor,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

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

                // SENHA 
                TextField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: kInputColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
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

                // BOTÃO LOGIN
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final auth = AuthService();
                    bool logged = await auth.login(
                      emailController.text,
                      passwordController.text,
                    );

                    if (logged) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login realizado com sucesso")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainNavigation()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email ou senha incorretos")),
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
                      "Entrar",
                      style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                // ESQUECEU SENHA
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ResetPasswordPage()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Esqueceu a sua senha? ",
                          style: TextStyle(color: kWhiteColor),
                        ),
                        TextSpan(
                          text: "Recupere agora",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Não tem uma conta?",
                  style: TextStyle(color: kWhiteColor),
                ),

                const SizedBox(height: 12),

                // IR PARA REGISTRO
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
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
                      "Registrar",
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