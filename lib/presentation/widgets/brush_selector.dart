// lib/presentation/widgets/brush_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/paint_provider.dart';

class BrushSelector extends StatelessWidget {
  const BrushSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final paintProv = context.watch<PaintProvider>();

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
          const Text(
            "Brush Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Preview
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: _BrushPreviewPainter(
                color: paintProv.color.withOpacity(paintProv.opacity),
                width: paintProv.strokeWidth,
                cap: paintProv.strokeCap,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stroke width
          Slider(
            value: paintProv.strokeWidth,
            min: 1,
            max: 40,
            divisions: 40,
            label: "${paintProv.strokeWidth.round()}",
            onChanged: (v) => paintProv.changeStrokeWidth(v),
          ),

          // Opacity
          Slider(
            value: paintProv.opacity,
            min: 0.1,
            max: 1.0,
            divisions: 10,
            label: "${(paintProv.opacity * 100).round()}%",
            onChanged: (v) => paintProv.changeOpacity(v),
          ),

          const SizedBox(height: 12),

          // StrokeCap
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _capButton(context, StrokeCap.butt, "Butt"),
              _capButton(context, StrokeCap.round, "Round"),
              _capButton(context, StrokeCap.square, "Square"),
            ],
          ),

          const SizedBox(height: 16),

          // Color palette
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: palette.map((c) {
                final selected = paintProv.color.value == c.value;
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
                        color: selected ? Colors.black : Colors.transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ⭐ ERASER BUTTON ⭐
          IconButton(
            icon: Icon(Icons.auto_fix_off, color: Colors.red),
            onPressed: () {
              context.read<PaintProvider>().enableEraser();
              Navigator.pop(context); // đóng panel
            },
          ),
        ],
      ),
    );
  }

  Widget _capButton(BuildContext context, StrokeCap cap, String label) {
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
