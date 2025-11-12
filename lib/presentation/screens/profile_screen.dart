// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: const Center(child: Text('Thông tin tài khoản, đăng nhập, đăng xuất')),
    );
  }
}
