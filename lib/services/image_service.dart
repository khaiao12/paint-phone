// lib/services/image_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageService {
  /// chụp ảnh từ canvas
  static Future<Uint8List> captureImage(GlobalKey key) async {
    final boundary =
    key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// lưu file thật vào thư mục app
  static Future<String> saveImageToLocal(Uint8List bytes, String name) async {
    final dir = await getApplicationDocumentsDirectory();

    final filePath = "${dir.path}/$name.png";
    final file = File(filePath);

    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Encode base64 để xem full
  static String toBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// lưu metadata Firestore
  static Future<void> saveToFirestore({
    required Uint8List bytes,
    required String name,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw "Bạn chưa đăng nhập!";

    // Lưu file thật
    final localPath = await saveImageToLocal(bytes, name);

    // Lưu metadata
    await FirebaseFirestore.instance.collection("paintings").add({
      "userId": user.uid,
      "name": name,
      "localPath": localPath,
      "base64": toBase64(bytes),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
