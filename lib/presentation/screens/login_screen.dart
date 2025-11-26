import 'package:flutter/material.dart';
import 'package:painting_app/presentation/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  void _login() async {
    setState(() => loading = true);
    final auth = context.read<AppAuthProvider>();

    final error = await auth.signIn(emailCtrl.text.trim(), passCtrl.text.trim());

    setState(() => loading = false);

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _loginGoogle() async {
    final auth = context.read<AppAuthProvider>();
    final error = await auth.signInWithGoogle();

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Đăng nhập", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : _login,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Đăng nhập"),
            ),

            TextButton(
              child: const Text("Chưa có tài khoản? Đăng ký ngay"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
            ),


            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text("Đăng nhập bằng Google"),
              onPressed: _loginGoogle,
            )
          ],
        ),
      ),
    );
  }
}
