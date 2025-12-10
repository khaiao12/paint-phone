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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -4),
          )
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          //       TITLE

          Text(
            "Cài đặt cọ vẽ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),

          const SizedBox(height: 18),

          //       BRUSH PREVIEW

          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: CustomPaint(
              painter: _BrushPreviewPainter(
                color: paintProv.color.withOpacity(paintProv.opacity),
                width: paintProv.strokeWidth,
                cap: paintProv.strokeCap,
              ),
            ),
          ),

          const SizedBox(height: 18),

          //       SLIDER – STROKE WIDTH

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Độ dày", style: TextStyle(fontSize: 14)),
              Text("${paintProv.strokeWidth.round()}"),
            ],
          ),
          Slider(
            value: paintProv.strokeWidth,
            min: 1,
            max: 40,
            activeColor: Colors.blue,
            label: "${paintProv.strokeWidth.round()}",
            onChanged: (v) => paintProv.changeStrokeWidth(v),
          ),

          //       SLIDER – OPACITY

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Độ đậm (Opacity)", style: TextStyle(fontSize: 14)),
              Text("${(paintProv.opacity * 100).round()}%"),
            ],
          ),
          Slider(
            value: paintProv.opacity,
            min: 0.1,
            max: 1.0,
            divisions: 10,
            activeColor: Colors.blue,
            label: "${(paintProv.opacity * 100).round()}%",
            onChanged: (v) => paintProv.changeOpacity(v),
          ),

          const SizedBox(height: 14),

          //       STROKE CAP

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _capChip(context, StrokeCap.butt, "Butt"),
              _capChip(context, StrokeCap.round, "Round"),
              _capChip(context, StrokeCap.square, "Square"),
            ],
          ),

          const SizedBox(height: 20),

          //       COLOR PALETTE

          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: palette.map((c) {
                final selected = paintProv.color.value == c.value;
                return GestureDetector(
                  onTap: () => paintProv.changeColor(c),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 3,
                        color: selected ? Colors.blue : Colors.transparent,
                      ),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                        )
                      ]
                          : [],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          //          ERASER BUTTON

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_fix_off, color: Colors.white),
              label: const Text("Tẩy", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.read<PaintProvider>().enableEraser();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // CHIP BUTTON FOR STROKE CAP
  Widget _capChip(BuildContext context, StrokeCap cap, String label) {
    final paintProv = context.watch<PaintProvider>();
    final isSelected = paintProv.strokeCap == cap;

    return InkWell(
      onTap: () => paintProv.changeStrokeCap(cap),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade900 : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
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
