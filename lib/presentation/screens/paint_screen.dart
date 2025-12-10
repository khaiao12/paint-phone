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
  final String? base64Image;

  const PaintScreen({super.key, this.base64Image});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.base64Image != null && mounted) {
        final bytes = base64Decode(widget.base64Image!);
        await context.read<LayerProvider>().addImageLayer(bytes);
      }
    });
  }

  // SAVE IMAGE

  Future<void> _saveImage() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Đặt tên ảnh"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Tên ảnh…"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy")),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
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

  @override
  Widget build(BuildContext context) {
    final layerProv = context.watch<LayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE9F2FF), // nền xanh nhạt

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: const Color(0xFF2196F3),
          elevation: 3,
          centerTitle: true,
          title: const Text(
            "Vẽ tranh",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // TOOLBAR DƯỚI
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  _toolBtn(Icons.save_alt, _saveImage),

                  _toolBtn(Icons.delete, layerProv.clearAll),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth * 0.9;
            final canvasHeight = constraints.maxHeight * 0.75;

            return Container(
              width: canvasWidth,
              height: canvasHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),

                // ZOOM + PAN
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(100),
                  clipBehavior: Clip.hardEdge,
                  child: ClipRect(
                    child: DrawingCanvas(boundaryKey: _boundaryKey),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // CUSTOM TOOL BUTTON

  Widget _toolBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 26, color: Colors.white),
      ),
    );
  }
}
