import 'dart:convert';
import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String base64Image;
  final String name;

  const FullImageScreen({
    super.key,
    required this.base64Image,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(base64Image);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // nền trắng xanh nhạt
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3), // xanh dương chính
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: InteractiveViewer(
              maxScale: 4.0,
              minScale: 0.8,
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
