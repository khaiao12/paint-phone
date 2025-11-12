// lib/presentation/state/layer_provider.dart
import 'package:flutter/material.dart';

class DrawPoint {
  final Offset? point;
  final Paint paint;
  DrawPoint({required this.point, required this.paint});
}

class LayerProvider extends ChangeNotifier {
  final List<List<DrawPoint>> _layers = [[]];
  int _currentLayerIndex = 0;

  // Lưu lịch sử cho Undo/Redo
  final List<List<List<DrawPoint>>> _history = [];
  int _historyIndex = -1;

  List<List<DrawPoint>> get layers => _layers;
  int get currentLayerIndex => _currentLayerIndex;

  void addPoint(Offset point, Paint paint) {
    _layers[_currentLayerIndex].add(DrawPoint(point: point, paint: paint));
    notifyListeners();
  }

  void endStroke() {
    // Thêm điểm null để ngắt nét
    _layers[_currentLayerIndex].add(DrawPoint(point: null, paint: Paint()));
    _saveHistory();
    notifyListeners();
  }

  void _saveHistory() {
    // Cắt bỏ lịch sử phía sau (nếu đã undo mà lại vẽ mới)
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    // Lưu snapshot
    _history.add(
      _layers.map((layer) => List<DrawPoint>.from(layer)).toList(),
    );
    _historyIndex = _history.length - 1;
  }

  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _restoreFromHistory();
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _restoreFromHistory();
    }
  }

  void _restoreFromHistory() {
    final snapshot = _history[_historyIndex];
    _layers
      ..clear()
      ..addAll(snapshot.map((layer) => List<DrawPoint>.from(layer)));
    notifyListeners();
  }

  void clearAll() {
    for (var layer in _layers) {
      layer.clear();
    }
    _saveHistory();
    notifyListeners();
  }

  void addLayer() {
    _layers.add([]);
    _currentLayerIndex = _layers.length - 1;
    _saveHistory();
    notifyListeners();
  }

  void selectLayer(int index) {
    _currentLayerIndex = index;
    notifyListeners();
  }
}
