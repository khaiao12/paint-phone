// lib/presentation/state/layer_provider.dart
import 'package:flutter/material.dart';

class DrawPoint {
  final Offset? point; // null = ngắt stroke
  final Paint paint;

  DrawPoint({required this.point, required this.paint});
}

class LayerProvider extends ChangeNotifier {
  final List<List<DrawPoint>> _layers = <List<DrawPoint>>[<DrawPoint>[]];
  int _currentLayerIndex = 0;

  // Lịch sử undo/redo: mỗi phần tử là snapshot toàn bộ layers
  final List<List<List<DrawPoint>>> _history = <List<List<DrawPoint>>>[];
  int _historyIndex = -1;

  LayerProvider() {
    // Snapshot canvas rỗng
    _saveHistory();
  }

  List<List<DrawPoint>> get layers => _layers;
  int get currentLayerIndex => _currentLayerIndex;

  // Thêm điểm khi đang vẽ
  void addPoint(Offset point, Paint paint) {
    _layers[_currentLayerIndex].add(
      DrawPoint(point: point, paint: paint),
    );
    notifyListeners();
  }

  // Kết thúc một stroke
  void endStroke() {
    final layer = _layers[_currentLayerIndex];
    final hasPoints = layer.isNotEmpty && layer.last.point != null;

    if (hasPoints) {
      // Thêm điểm null để ngắt stroke
      layer.add(
        DrawPoint(point: null, paint: Paint()),
      );
      _saveHistory();
      notifyListeners();
    }
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

  void clearAll() {
    for (final layer in _layers) {
      layer.clear();
    }
    _saveHistory();
    notifyListeners();
  }

  void addLayer() {
    _layers.add(<DrawPoint>[]);
    _currentLayerIndex = _layers.length - 1;
    _saveHistory();
    notifyListeners();
  }

  void removeLayer(int index) {
    if (_layers.length <= 1) return;

    _layers.removeAt(index);
    _currentLayerIndex = _currentLayerIndex.clamp(0, _layers.length - 1);
    _saveHistory();
    notifyListeners();
  }

  void selectLayer(int index) {
    if (index < 0 || index >= _layers.length) return;
    _currentLayerIndex = index;
    notifyListeners();
  }

  // ============ Helpers ============

  void _saveHistory() {
    // Nếu đã undo rồi vẽ tiếp → cắt nhánh redo
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final snapshot = _layers
        .map((layer) => List<DrawPoint>.from(layer))
        .toList(growable: false);

    _history.add(snapshot);
    _historyIndex = _history.length - 1;
  }

  void _restoreFromHistory() {
    final snap = _history[_historyIndex];

    _layers
      ..clear()
      ..addAll(
        snap.map((layer) => List<DrawPoint>.from(layer)),
      );

    _currentLayerIndex = _currentLayerIndex.clamp(0, _layers.length - 1);
    notifyListeners();
  }
}
