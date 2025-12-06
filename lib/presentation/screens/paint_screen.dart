// lib/presentation/screens/paint_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/layer_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/layer_list_panel.dart';
import '../widgets/brush_selector.dart';
import '../../services/image_service.dart';

class PaintScreen extends StatefulWidget {
  final String? base64Image; // ảnh từ gallery để vẽ đè

  const PaintScreen({super.key, this.base64Image});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Nếu mở từ Gallery → thêm vào image-layer
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.base64Image != null && mounted) {
        final bytes = base64Decode(widget.base64Image!);
        await context.read<LayerProvider>().addImageLayer(bytes);
      }
    });
  }

  // ==============================================================
  // SAVE IMAGE
  // ==============================================================
  Future<void> _saveImage() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đặt tên ảnh"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Tên ảnh…"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );

    if (name == null) return;

    final finalName = name.isEmpty
        ? "Painting_${DateTime.now().millisecondsSinceEpoch}"
        : name;

    try {
      final pngBytes = await ImageService.captureImage(_boundaryKey);
      await ImageService.saveToFirestore(bytes: pngBytes, name: finalName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã lưu: $finalName")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu: $e")),
      );
    }
  }

  // ==============================================================
  // UI
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final layerProv = context.watch<LayerProvider>();

    return Scaffold(
      backgroundColor: Colors.black,

      // ==========================================================
      // APP BAR 2 TẦNG
      // ==========================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          title: const Text("Vẽ tranh"),
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.blue,

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.blue.shade600,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 5),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _toolBtn(Icons.undo, layerProv.undo),
                  _toolBtn(Icons.redo, layerProv.redo),

                  _toolBtn(Icons.layers, () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => LayerListPanel(
                        onClose: () => Navigator.pop(context),
                      ),
                    );
                  }),

                  _toolBtn(Icons.brush, () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const BrushSelector(),
                    );
                  }),

                  _toolBtn(Icons.save, _saveImage),

                  _toolBtn(Icons.delete, layerProv.clearAll),
                ],
              ),
            ),
          ),
        ),
      ),

      // ==========================================================
      // CANVAS VẼ
      // ==========================================================
        body: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.white)), // nền trắng
            DrawingCanvas(boundaryKey: _boundaryKey),
          ],
        )

    );
  }

  /// Nút tool gọn đẹp
  Widget _toolBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 26, color: Colors.white),
      onPressed: onTap,
      splashRadius: 24,
    );
  }
}
