import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powerank/consts.dart';
import 'package:powerank/screens/Home/main_navigation.dart';
import 'package:powerank/screens/Reset/reset_password.dart';
import 'package:powerank/screens/Signup/register_screen.dart';
import 'package:powerank/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _goToRegisterBecauseUserDoesNotExist() async {
    final shouldGo =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Conta nao encontrada'),
            content: const Text(
              'Nao existe nenhuma conta com este email. Queres ir para a tela de registro?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ir para registro'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldGo) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _goToMainNavigation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  Future<void> _handleLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preenche email e senha')));
      return;
    }

    setState(() {
      _loading = true;
    });

    final auth = AuthService();
    final result = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    switch (result) {
      case LoginResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso')),
        );
        _goToMainNavigation();
        break;
      case LoginResult.userNotFound:
        await _goToRegisterBecauseUserDoesNotExist();
        break;
      case LoginResult.wrongPassword:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Senha incorreta')));
        break;
      case LoginResult.invalidEmail:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email invalido')));
        break;
      case LoginResult.cancelled:
        break;
      case LoginResult.googleConfigurationError:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Google Sign-In nao configurado. No Firebase, ativa o provedor Google, adiciona SHA-1/SHA-256 e baixa um novo google-services.json.',
            ),
          ),
        );
        break;
      case LoginResult.accountExistsWithDifferentProvider:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este email ja esta associado a outro metodo de login.',
            ),
          ),
        );
        break;
      case LoginResult.error:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao fazer login')));
        break;
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _googleLoading = true;
    });

    final result = await AuthService().signInWithGoogle();

    if (!mounted) return;

    setState(() {
      _googleLoading = false;
    });

    switch (result) {
      case LoginResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login com Google realizado')),
        );
        _goToMainNavigation();
        break;
      case LoginResult.cancelled:
        break;
      case LoginResult.googleConfigurationError:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Google Sign-In nao configurado. No Firebase, ativa o provedor Google, adiciona SHA-1/SHA-256 e baixa um novo google-services.json.',
            ),
          ),
        );
        break;
      case LoginResult.accountExistsWithDifferentProvider:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este email ja esta associado a outro metodo de login.',
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nao foi possivel entrar com o Google')),
        );
        break;
    }
  }

  Widget _buildPrimaryButton({
    required Size size,
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.08,
        decoration: BoxDecoration(
          color: KButtonColor,
          borderRadius: BorderRadius.circular(37),
        ),
        child: child,
      ),
    );
  }

  Widget _buildGoogleButton(Size size) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _loading || _googleLoading ? null : _handleGoogleLogin,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.08,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(37),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: _googleLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: KButtonColor,
                ),
              )
            : const Text(
                'Entrar com Google',
                style: TextStyle(
                  color: kInputColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
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
                  'Bem vindo de volta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: kWhiteColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    color: kWhiteColor,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
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
                    hintText: 'Email',
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                    hintText: 'Senha',
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPrimaryButton(
                  size: size,
                  onPressed: _loading || _googleLoading ? null : _handleLogin,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 13),
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
                          text: 'Esqueceu a sua senha? ',
                          style: TextStyle(color: kWhiteColor),
                        ),
                        TextSpan(
                          text: 'Recupere agora',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou', style: TextStyle(color: kWhiteColor)),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildGoogleButton(size),
                const SizedBox(height: 24),
                const Text(
                  'Nao tem uma conta?',
                  style: TextStyle(color: kWhiteColor),
                ),
                const SizedBox(height: 12),
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
                      'Registrar',
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
