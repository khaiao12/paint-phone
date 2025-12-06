import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../state/paint_provider.dart';

class DrawingCanvas extends StatelessWidget {
  final GlobalKey boundaryKey;

  const DrawingCanvas({super.key, required this.boundaryKey});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: GestureDetector(
        onPanStart: (details) => _addPoint(context, details.localPosition),
        onPanUpdate: (details) => _addPoint(context, details.localPosition),
        onPanEnd: (_) => context.read<LayerProvider>().endStroke(),
        child: Consumer<LayerProvider>(
          builder: (_, provider, __) {
            return CustomPaint(
              painter: _DrawingPainter(provider),
              child: Container(), // full screen canvas
            );
          },
        ),
      ),
    );
  }

  void _addPoint(BuildContext context, Offset pos) {
    final paintProv = context.read<PaintProvider>();
    final layerProv = context.read<LayerProvider>();

    final paint = Paint()
      ..color = paintProv.isEraser
          ? Colors.transparent
          : paintProv.color.withOpacity(paintProv.opacity)
      ..strokeWidth = paintProv.strokeWidth
      ..strokeCap = paintProv.strokeCap
      ..blendMode = paintProv.isEraser ? BlendMode.clear : BlendMode.srcOver
      ..isAntiAlias = true;

    layerProv.addPoint(pos, paint);
  }
}

class _DrawingPainter extends CustomPainter {
  final LayerProvider provider;

  _DrawingPainter(this.provider);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in provider.layers) {
      if (!layer.visible) continue;

      // ===== 1. Layer ảnh =====
      if (layer.type == LayerType.image && layer.image != null) {
        final img = layer.image!;
        final src =
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
        final dst = Rect.fromLTWH(0, 0, size.width, size.height);

        canvas.drawImageRect(img, src, dst, Paint());
        continue;
      }

      // ===== 2. Layer vẽ =====
      if (layer.type == LayerType.draw) {
        for (int i = 0; i < layer.points.length - 1; i++) {
          final p1 = layer.points[i];
          final p2 = layer.points[i + 1];

          if (p1.point == null || p2.point == null) continue;
          canvas.drawLine(p1.point!, p2.point!, p1.paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
