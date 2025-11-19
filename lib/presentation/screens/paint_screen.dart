// lib/presentation/screens/paint_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/layer_list_panel.dart';
import '../widgets/brush_selector.dart';

class PaintScreen extends StatelessWidget {
  const PaintScreen({super.key});

  void _openBrushSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const BrushSelector(),
    );
  }

  void _openLayerPanel(BuildContext context) {
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
      appBar: AppBar(
        title: const Text("Vẽ tranh"),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => layerProv.undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => layerProv.redo(),
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _openLayerPanel(context),
          ),
          IconButton(
            icon: const Icon(Icons.brush),
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const BrushSelector(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => layerProv.clearAll(),
          ),
        ],
      ),

      body: const DrawingCanvas(),
    );
  }
}
