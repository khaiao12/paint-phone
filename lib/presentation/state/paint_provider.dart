import 'package:flutter/material.dart';

class PaintProvider extends ChangeNotifier {
  Color _color = Colors.black;
  double _strokeWidth = 4.0;
  double _opacity = 1.0;
  StrokeCap _strokeCap = StrokeCap.round;

  bool _isEraser = false;

  Color get color => _color;
  double get strokeWidth => _strokeWidth;
  double get opacity => _opacity;
  StrokeCap get strokeCap => _strokeCap;
  bool get isEraser => _isEraser;

  void changeColor(Color c) {
    _color = c;
    _isEraser = false; // tắt gôm
    notifyListeners();
  }

  void changeStrokeWidth(double v) {
    _strokeWidth = v;
    notifyListeners();
  }

  void changeOpacity(double v) {
    _opacity = v;
    notifyListeners();
  }

  void changeStrokeCap(StrokeCap cap) {
    _strokeCap = cap;
    notifyListeners();
  }

  void enableEraser() {
    _isEraser = true;
    notifyListeners();
  }
}
