import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/layer_list_panel.dart';
import '../widgets/brush_selector.dart';
import '../../services/image_service.dart';

class PaintScreen extends StatefulWidget {
  final String? base64Image; // ảnh nền để vẽ đè

  const PaintScreen({super.key, this.base64Image});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _saveImage() async {
    final nameController = TextEditingController();

    final imageName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đặt tên cho ảnh"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: "Nhập tên ảnh...",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text("Hủy")),
          TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                Navigator.pop(ctx, name);
              },
              child: const Text("Lưu")),
        ],
      ),
    );

    if (imageName == null) return;

    final finalName = imageName.isEmpty
        ? "Painting_${DateTime.now().millisecondsSinceEpoch}"
        : imageName;

    try {
      final pngBytes = await ImageService.captureImage(_boundaryKey);

      await ImageService.saveToFirestore(
        bytes: pngBytes,
        name: finalName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã lưu ảnh: $finalName")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Lỗi khi lưu ảnh: $e")));
      }
    }
  }

  void _openBrushSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const BrushSelector(),
    );
  }

  void _openLayerPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => LayerListPanel(onClose: () => Navigator.pop(ctx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layerProv = context.watch<LayerProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          title: const Text("Vẽ tranh"),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.undo), onPressed: layerProv.undo),
                  IconButton(icon: const Icon(Icons.redo), onPressed: layerProv.redo),
                  IconButton(icon: const Icon(Icons.layers), onPressed: _openLayerPanel),
                  IconButton(icon: const Icon(Icons.brush), onPressed: _openBrushSelector),
                  IconButton(icon: const Icon(Icons.save), onPressed: _saveImage),
                  IconButton(icon: const Icon(Icons.delete), onPressed: layerProv.clearAll),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          if (widget.base64Image != null)
            Positioned.fill(
              child: Image.memory(
                base64Decode(widget.base64Image!),
                fit: BoxFit.contain,
              ),
            ),

          DrawingCanvas(boundaryKey: _boundaryKey),
        ],
      ),
    );
  }
}
