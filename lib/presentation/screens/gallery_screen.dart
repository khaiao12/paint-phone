// lib/presentation/screens/gallery_screen.dart
import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bộ sưu tập')),
      body: const Center(child: Text('Hiển thị các tranh đã lưu ở đây')),
    );
  }
}
