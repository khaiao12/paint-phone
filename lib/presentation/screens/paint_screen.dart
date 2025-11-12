// lib/presentation/screens/paint_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../state/paint_provider.dart';
import '../widgets/drawing_canvas.dart';

class PaintScreen extends StatelessWidget {
  const PaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LayerProvider()),
        ChangeNotifierProvider(create: (_) => PaintProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vẽ tranh'),
          actions: [
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => context.read<LayerProvider>().undo(),
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: () => context.read<LayerProvider>().redo(),
            ),
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () => context.read<LayerProvider>().addLayer(),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => context.read<LayerProvider>().clearAll(),
            ),
          ],
        ),
        body: const DrawingCanvas(),
        floatingActionButton: Consumer<PaintProvider>(
          builder: (context, paintProv, _) {
            return FloatingActionButton(
              backgroundColor: paintProv.color,
              child: const Icon(Icons.color_lens),
              onPressed: () {
                final newColor = Colors.primaries[
                DateTime.now().millisecond % Colors.primaries.length];
                paintProv.changeColor(newColor);
              },
            );
          },
        ),
      ),
    );
  }
}
