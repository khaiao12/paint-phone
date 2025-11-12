// lib/presentation/state/paint_provider.dart
import 'package:flutter/material.dart';

class PaintProvider extends ChangeNotifier {
  Color _color = Colors.black;
  double _strokeWidth = 4.0;

  Color get color => _color;
  double get strokeWidth => _strokeWidth;

  void changeColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void changeStrokeWidth(double width) {
    _strokeWidth = width;
    notifyListeners();
  }
}
