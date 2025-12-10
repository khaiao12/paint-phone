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
    final ref = FirebaseStorage.instance.ref("avatars/${user.uid}.jpg");

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    setState(() => avatarUrl = url);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"avatarUrl": url});
  }

  Future<void> _saveChanges() async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
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
    FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email đổi mật khẩu đã được gửi")),
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
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          "Thông tin cá nhân",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2196F3),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            //           AVATAR

            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.camera_alt, size: 38, color: Colors.grey)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Email
            Text(
              user.email ?? "Không có email",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 25),

            //         PROFILE FORM CARD

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _inputField("Tên người dùng", usernameCtrl, icon: Icons.person),
                  _inputField("Số điện thoại", phoneCtrl,
                      keyboard: TextInputType.phone, icon: Icons.phone),
                  _inputField("Ngày sinh (dd/mm/yyyy)", birthdayCtrl,
                      icon: Icons.calendar_today),
                ],
              ),
            ),

            const SizedBox(height: 25),

            //     CHANGE PASSWORD BUTTON

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock_reset, color: Color(0xFF1565C0)),
                label: const Text(
                  "Đổi mật khẩu",
                  style: TextStyle(color: Color(0xFF1565C0)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            //       SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Lưu thay đổi",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            //         LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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
        IconData? icon,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          labelText: label,
          floatingLabelStyle: const TextStyle(color: Color(0xFF2196F3)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
