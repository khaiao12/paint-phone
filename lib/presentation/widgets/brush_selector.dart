import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/paint_provider.dart';

class BrushSelector extends StatelessWidget {
  const BrushSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        final paintProv = innerContext.watch<PaintProvider>();

        // ✅ Palette màu có thêm màu đen
        final List<Color> palette = [
          Colors.black,
          ...Colors.primaries,
        ];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Brush Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== Brush Preview =====
              SizedBox(
                height: 60,
                child: CustomPaint(
                  painter: _BrushPreviewPainter(
                    color: paintProv.color.withOpacity(paintProv.opacity),
                    width: paintProv.strokeWidth,
                    cap: paintProv.strokeCap,
                  ),
                  child: Container(),
                ),
              ),

              const SizedBox(height: 16),

              // ===== Stroke Width =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Độ dày"),
                ],
              ),
              Slider(
                value: paintProv.strokeWidth,
                min: 1,
                max: 40,
                divisions: 40,
                label: "${paintProv.strokeWidth.round()}",
                onChanged: (v) => paintProv.changeStrokeWidth(v),
              ),

              const SizedBox(height: 16),

              // ===== Opacity =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Độ mờ (Opacity)"),
                ],
              ),
              Slider(
                value: paintProv.opacity,
                min: 0.1,
                max: 1.0,
                divisions: 10,
                label: "${(paintProv.opacity * 100).round()}%",
                onChanged: (v) => paintProv.changeOpacity(v),
              ),

              const SizedBox(height: 16),

              // ===== StrokeCap Buttons =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _strokeCapButton(innerContext, StrokeCap.butt, "Butt"),
                  _strokeCapButton(innerContext, StrokeCap.round, "Round"),
                  _strokeCapButton(innerContext, StrokeCap.square, "Square"),
                ],
              ),

              const SizedBox(height: 16),

              // ===== Color Picker Mini (có màu đen) =====
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: palette.map((c) {
                    final isSelected = paintProv.color.value == c.value;
                    return GestureDetector(
                      onTap: () => paintProv.changeColor(c),
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// BUTTON CHỌN KIỂU NÉT CỌ
  Widget _strokeCapButton(
      BuildContext context, StrokeCap cap, String label) {
    final paintProv = context.watch<PaintProvider>();
    final isSelected = paintProv.strokeCap == cap;

    return GestureDetector(
      onTap: () => paintProv.changeStrokeCap(cap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label),
      ),
    );
  }
}

class _BrushPreviewPainter extends CustomPainter {
  final Color color;
  final double width;
  final StrokeCap cap;

  _BrushPreviewPainter({
    required this.color,
    required this.width,
    required this.cap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = cap;

    canvas.drawLine(
      Offset(20, size.height / 2),
      Offset(size.width - 20, size.height / 2),
      p,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}
