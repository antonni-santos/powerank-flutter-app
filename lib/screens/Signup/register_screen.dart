import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powerank/consts.dart';
import 'package:powerank/screens/Home/main_navigation.dart';
import 'package:powerank/screens/Login/login_screen.dart';
import 'package:powerank/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToMainNavigation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  Future<void> _handleRegister() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche nome, email e senha')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha precisa ter pelo menos 6 caracteres'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas nao coincidem')));
      return;
    }

    setState(() {
      _loading = true;
    });

    final auth = AuthService();
    final created = await auth.register(email, password, username);

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (created) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso')));
      _goToMainNavigation();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nao foi possivel criar a conta. Verifica os dados.'),
      ),
    );
  }

  Future<void> _handleGoogleRegister() async {
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
          const SnackBar(content: Text('Conta iniciada com Google')),
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
          const SnackBar(
            content: Text('Nao foi possivel continuar com o Google'),
          ),
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
      onPressed: _loading || _googleLoading ? null : _handleGoogleRegister,
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
                'Continuar com Google',
                style: TextStyle(
                  color: kInputColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      hintText: hintText,
      fillColor: kWhiteColor,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(37),
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
                  'Bem vindo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: kWhiteColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registrar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    color: kWhiteColor,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                TextField(
                  controller: usernameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: kInputColor),
                  decoration: _inputDecoration(
                    hintText: 'Nome',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kInputColor),
                  decoration: _inputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: kInputColor),
                  decoration: _inputDecoration(
                    hintText: 'Senha',
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
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  style: const TextStyle(color: kInputColor),
                  decoration: _inputDecoration(
                    hintText: 'Confirmar senha',
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPrimaryButton(
                  size: size,
                  onPressed: _loading || _googleLoading
                      ? null
                      : _handleRegister,
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
                          'Criar conta',
                          style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                  'Ja tem uma conta?',
                  style: TextStyle(color: kWhiteColor),
                ),
                const SizedBox(height: 12),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
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
                      'Fazer login',
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
