import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'full_image_screen.dart';
import 'paint_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Bộ sưu tập")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("paintings")
            .where("userId", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Chưa có ảnh nào"));

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index];
              final base64Img = data["base64"];
              final name = data["name"];
              final docId = data.id;

              return GestureDetector(
                onTap: () => _showImageOptions(context, docId, name, base64Img),

                child: GridTile(
                  footer: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.black54,
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  child: Image.memory(base64Decode(base64Img), fit: BoxFit.cover),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// MENU lựa chọn
  void _showImageOptions(
      BuildContext context, String docId, String name, String base64Img) {

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.fullscreen),
              title: const Text("Xem toàn màn hình"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageScreen(
                      base64Image: base64Img,
                      name: name,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.brush),
              title: const Text("Vẽ tiếp tranh này"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaintScreen(base64Image: base64Img),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Đổi tên"),
              onTap: () {
                Navigator.pop(ctx);
                _rename(context, docId, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Xóa"),
              onTap: () {
                Navigator.pop(ctx);
                _delete(context, docId, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Hủy"),
              onTap: () => Navigator.pop(ctx),
            )
          ],
        ),
      ),
    );
  }

  // ĐỔI TÊN
  void _rename(BuildContext context, String docId, String oldName) async {
    final controller = TextEditingController(text: oldName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đổi tên ảnh"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text("Lưu")),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("paintings")
        .doc(docId)
        .update({"name": newName});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã đổi tên thành $newName")),
    );
  }

  // XÓA
  void _delete(BuildContext context, String docId, String name) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa ảnh"),
        content: Text("Xóa '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection("paintings").doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã xóa ảnh '$name'")),
    );
  }
}
