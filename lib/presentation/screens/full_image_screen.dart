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
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(bytes),
        ),
      ),
    );
  }
}
