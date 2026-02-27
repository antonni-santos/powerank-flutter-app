import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/Login/login_screen.dart';
import '../../consts.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
                  "Esqueceu sua senha?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: kWhiteColor,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Digite seu email e enviaremos um link para redefinir sua senha.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: kWhiteColor,
                  ),
                ),

                SizedBox(height: size.height * 0.04),

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

                const SizedBox(height: 20),

                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                      color: KButtonColor,
                      borderRadius: BorderRadius.circular(37),
                    ),
                    child: const Text(
                      "Enviar link de recuperação",
                      style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

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
                      color: KButtonColor,
                      borderRadius: BorderRadius.circular(37),
                    ),
                    child: const Text(
                      "Voltar para o log in",
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
