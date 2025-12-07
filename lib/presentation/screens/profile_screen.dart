import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final picker = ImagePicker();

  late TextEditingController usernameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController birthdayCtrl;

  String? avatarUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    usernameCtrl = TextEditingController(text: data["username"] ?? "");
    phoneCtrl = TextEditingController(text: data["phone"] ?? "");
    birthdayCtrl = TextEditingController(text: data["birthday"] ?? "");
    avatarUrl = data["avatarUrl"];

    setState(() => loading = false);
  }

  Future<void> _pickAvatar() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance
        .ref("avatars/${user.uid}.jpg");

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    setState(() => avatarUrl = url);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"avatarUrl": url});
  }

  Future<void> _saveChanges() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "username": usernameCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "birthday": birthdayCtrl.text.trim(),
      "avatarUrl": avatarUrl,
      "email": user.email,
      "updatedAt": DateTime.now(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu thay đổi")),
    );
  }

  void _changePassword() {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: user.email!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email đổi mật khẩu đã được gửi"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =====================
            //      AVATAR
            // =====================
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 25),

            // =====================
            //      EMAIL
            // =====================
            Text(
              user.email ?? "Không có email",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            // =====================
            //   FORM FIELDS
            // =====================
            _inputField("Tên người dùng", usernameCtrl),
            _inputField("Số điện thoại", phoneCtrl, keyboard: TextInputType.phone),
            _inputField("Ngày sinh (dd/mm/yyyy)", birthdayCtrl),

            const SizedBox(height: 25),

            // =====================
            //  CHANGE PASSWORD
            // =====================
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text("Đổi mật khẩu"),
            ),

            const SizedBox(height: 15),

            // =====================
            //  SAVE BUTTON
            // =====================
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Lưu thay đổi"),
            ),
            SizedBox(height: 30),

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

  Widget _inputField(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
