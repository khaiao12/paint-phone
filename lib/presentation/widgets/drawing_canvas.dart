// lib/presentation/widgets/drawing_canvas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../state/paint_provider.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LayerProvider, PaintProvider>(
      builder: (context, layer, paintProv, child) {
        return GestureDetector(
          onPanStart: (details) {
            final paint = Paint()
              ..color = paintProv.color
              ..strokeWidth = paintProv.strokeWidth
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true;
            layer.addPoint(details.localPosition, paint);
          },
          onPanUpdate: (details) {
            final paint = Paint()
              ..color = paintProv.color
              ..strokeWidth = paintProv.strokeWidth
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true;
            layer.addPoint(details.localPosition, paint);
          },
          onPanEnd: (_) => layer.endStroke(),
          child: CustomPaint(
            painter: _DrawingPainter(layer),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final LayerProvider provider;
  _DrawingPainter(this.provider);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in provider.layers) {
      for (int i = 0; i < layer.length - 1; i++) {
        final p1 = layer[i];
        final p2 = layer[i + 1];
        if (p1.point != null && p2.point != null) {
          canvas.drawLine(p1.point!, p2.point!, p1.paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
