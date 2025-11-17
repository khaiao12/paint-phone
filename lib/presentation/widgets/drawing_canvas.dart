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
        builder: (context, layerProv, _) {
          return CustomPaint(
            painter: _DrawingPainter(layerProv.layers),
            // cho chắc, bọc trong Container full size
            child: Container(),
          );
        },
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<DrawPoint>> layers;

  _DrawingPainter(this.layers);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      for (int i = 0; i < layer.length - 1; i++) {
        final p1 = layer[i];
        final p2 = layer[i + 1];

        // null = ngắt stroke, không nối
        if (p1.point == null || p2.point == null) continue;

        canvas.drawLine(p1.point!, p2.point!, p1.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    // Đơn giản cho chắc chắn: luôn repaint khi gọi
    return true;
  }
}
