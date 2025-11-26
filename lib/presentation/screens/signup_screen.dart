import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import 'main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passConfirmCtrl = TextEditingController();

  bool loading = false;

  void _signup() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final pass2 = passConfirmCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty || pass2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    if (pass != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }

    setState(() => loading = true);

    final auth = context.read<AppAuthProvider>();
    final error = await auth.signUp(email, pass);

    setState(() => loading = false);

    if (error == null) {
      // Đăng ký thành công → chuyển vào MainScreen
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
      appBar: AppBar(
        title: const Text("Tạo tài khoản"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            TextField(
              controller: passConfirmCtrl,
              decoration: const InputDecoration(labelText: "Nhập lại mật khẩu"),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : _signup,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Đăng ký"),
            ),
          ],
        ),
      ),
    );
  }
}
