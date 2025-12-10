import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import 'paint_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // nền xanh nhạt

      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Nút tạo tranh mới
            _homeButton(
              context,
              icon: Icons.brush,
              text: "Tạo tranh mới",
              color: const Color(0xFF2196F3),
              onTap: () {
                context.read<LayerProvider>().resetCanvas();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaintScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Nút tiếp tục tranh trước
            _homeButton(
              context,
              icon: Icons.history,
              text: "Tiếp tục tranh trước",
              color: const Color(0xFF1565C0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaintScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //   CUSTOM HOME BUTTON

  Widget _homeButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required Color color,
        required VoidCallback onTap,
      }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(230, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      onPressed: onTap,
    );
  }
}
