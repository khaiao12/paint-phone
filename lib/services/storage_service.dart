// lib/services/storage_service.dart
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String> uploadDrawing(Uint8List bytes) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw "Bạn chưa đăng nhập!";
    }

    final fileName = "painting_${DateTime.now().millisecondsSinceEpoch}.png";

    final ref = FirebaseStorage.instance
        .ref("drawings")
        .child(user.uid)
        .child(fileName);

    try {
      await ref.putData(
        bytes,
        SettableMetadata(contentType: "image/png"),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      throw "Upload thất bại: $e";
    }
  }
}
