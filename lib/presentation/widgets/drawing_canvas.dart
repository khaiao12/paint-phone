// lib/presentation/widgets/drawing_canvas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';
import '../state/paint_provider.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final paintProv = context.read<PaintProvider>();
        final layerProv = context.read<LayerProvider>();

        final paint = Paint()
          ..color = paintProv.color
          ..strokeWidth = paintProv.strokeWidth
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true;

        layerProv.addPoint(details.localPosition, paint);
      },
      onPanUpdate: (details) {
        final paintProv = context.read<PaintProvider>();
        final layerProv = context.read<LayerProvider>();

        final paint = Paint()
          ..color = paintProv.color
          ..strokeWidth = paintProv.strokeWidth
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true;

        layerProv.addPoint(details.localPosition, paint);
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
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final LayerProvider provider;

  _DrawingPainter(this.provider);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in provider.layers) {
      if (!layer.visible) continue;

      final points = layer.points;

      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        if (p1.point == null || p2.point == null) continue;

        canvas.drawLine(p1.point!, p2.point!, p1.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
