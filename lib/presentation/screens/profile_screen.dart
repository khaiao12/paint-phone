import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tài khoản",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.email, size: 28),
                const SizedBox(width: 10),
                Text(
                  user?.email ?? "Không có email",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),

                onPressed: () async {
                  await auth.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
