// lib/presentation/screens/paint_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/layer_provider.dart';
import '../state/paint_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/layer_list_panel.dart';

class PaintScreen extends StatelessWidget {
  const PaintScreen({super.key});

  void _openLayerPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return LayerListPanel(
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final layerProvider = context.read<LayerProvider>();
    final paintProvider = context.read<PaintProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vẽ tranh"),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => layerProvider.undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => layerProvider.redo(),
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _openLayerPanel(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => layerProvider.clearAll(),
          ),
        ],
      ),

      body: Container(
        color: Colors.white,
        child: const DrawingCanvas(),
      ),

      floatingActionButton: Consumer<PaintProvider>(
        builder: (context, paintProv, _) {
          return FloatingActionButton(
            backgroundColor: paintProv.color,
            child: const Icon(Icons.color_lens),
            onPressed: () {
              final newColor = Colors.primaries[
              DateTime.now().millisecond % Colors.primaries.length
              ];
              paintProv.changeColor(newColor);
            },
          );
        },
      ),
    );
  }
}
