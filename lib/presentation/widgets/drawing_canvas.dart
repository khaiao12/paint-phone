// lib/presentation/widgets/drawing_canvas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../state/paint_provider.dart';
import 'dart:ui' as ui;

class DrawingCanvas extends StatelessWidget {
  final GlobalKey boundaryKey;

  const DrawingCanvas({super.key, required this.boundaryKey});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: GestureDetector(
        onPanStart: (details) {
          _addPoint(context, details.localPosition);
        },
        onPanUpdate: (details) {
          _addPoint(context, details.localPosition);
        },
        onPanEnd: (_) {
          context.read<LayerProvider>().endStroke();
        },
        child: Consumer<LayerProvider>(
          builder: (context, provider, _) {
            return CustomPaint(
              painter: _DrawingPainter(provider),
              child: Container(),
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
      ..color = paintProv.color
      ..strokeWidth = paintProv.strokeWidth
      ..strokeCap = StrokeCap.round
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

      // 1. Layer ảnh
      if (layer.type == LayerType.image && layer.image != null) {
        final img = layer.image!;
        final src = Rect.fromLTWH(
            0, 0, img.width.toDouble(), img.height.toDouble());
        final dst =
        Rect.fromLTWH(0, 0, size.width, size.height);

        canvas.drawImageRect(img, src, dst, Paint());
        continue;
      }

      // 2. Layer vẽ
      if (layer.type == LayerType.draw) {
        final points = layer.points;

        for (int i = 0; i < points.length - 1; i++) {
          final p1 = points[i];
          final p2 = points[i + 1];

          if (p1.point == null || p2.point == null) continue;

          canvas.drawLine(p1.point!, p2.point!, p1.paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
