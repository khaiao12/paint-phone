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
      backgroundColor: const Color(0xFFF5F9FF), // nền trắng xanh nhạt

      appBar: AppBar(
        title: const Text(
          "Bộ sưu tập",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("paintings")
            .where("userId", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có ảnh nào",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index];
              final base64Img = data["base64"];
              final name = data["name"];
              final docId = data.id;

              return GestureDetector(
                onTap: () => _showImageOptions(context, docId, name, base64Img),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Image.memory(
                          base64Decode(base64Img),
                          fit: BoxFit.cover,
                        ),
                      ),

                      // FOOTER OVERLAY
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.55)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  //   MENU LỰA CHỌN BOTTOM SHEET

  void _showImageOptions(
      BuildContext context, String docId, String name, String base64Img) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionItem(
              ctx,
              icon: Icons.fullscreen,
              text: "Xem toàn màn hình",
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
            _optionItem(
              ctx,
              icon: Icons.brush,
              text: "Vẽ tiếp tranh này",
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
            _optionItem(
              ctx,
              icon: Icons.edit,
              text: "Đổi tên",
              onTap: () {
                Navigator.pop(ctx);
                _rename(context, docId, name);
              },
            ),
            _optionItem(
              ctx,
              icon: Icons.delete,
              text: "Xóa",
              onTap: () {
                Navigator.pop(ctx);
                _delete(context, docId, name);
              },
            ),
            _optionItem(
              ctx,
              icon: Icons.close,
              text: "Hủy",
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionItem(BuildContext ctx,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2196F3)),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  // ĐỔI TÊN

  void _rename(BuildContext context, String docId, String oldName) async {
    final controller = TextEditingController(text: oldName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Đổi tên ảnh",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Tên mới",
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2196F3)),
            ),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("Lưu", style: TextStyle(color: Color(0xFF2196F3))),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
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

  //  XÓA

  void _delete(BuildContext context, String docId, String name) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Xóa ảnh",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Xóa '$name'?"),
        actions: [
          TextButton(
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
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
