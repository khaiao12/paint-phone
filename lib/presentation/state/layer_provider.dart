// lib/presentation/state/layer_provider.dart
import 'package:flutter/material.dart';

class DrawPoint {
  final Offset? point; // null = ngắt stroke
  final Paint paint;

  DrawPoint({required this.point, required this.paint});
}

class Layer {
  String name;
  bool visible;
  List<DrawPoint> points;

  Layer({
    required this.name,
    this.visible = true,
    List<DrawPoint>? points,
  }) : points = points ?? [];
}

class LayerProvider extends ChangeNotifier {
  final List<Layer> _layers = [
    Layer(name: "Layer 1"),
  ];

  int _currentLayerIndex = 0;

  /// HISTORY (Undo/Redo)
  final List<List<Layer>> _history = [];
  int _historyIndex = -1;

  LayerProvider() {
    _saveHistory();
  }

  List<Layer> get layers => _layers;
  int get currentLayerIndex => _currentLayerIndex;

  /// ===========================
  /// DRAWING
  /// ===========================
  void addPoint(Offset point, Paint paint) {
    _layers[_currentLayerIndex].points.add(
      DrawPoint(point: point, paint: paint),
    );
    notifyListeners();
  }

  void endStroke() {
    final layer = _layers[_currentLayerIndex];
    final hasPoints = layer.points.isNotEmpty && layer.points.last.point != null;

    if (hasPoints) {
      layer.points.add(
        DrawPoint(point: null, paint: layer.points.last.paint),
      );
      _saveHistory();
      notifyListeners();
    }
  }

  /// ===========================
  /// LAYER OPERATIONS
  /// ===========================
  void addLayer() {
    _layers.add(
      Layer(name: "Layer ${_layers.length + 1}"),
    );
    _currentLayerIndex = _layers.length - 1;
    _saveHistory();
    notifyListeners();
  }

  void removeLayer(int index) {
    if (_layers.length <= 1) return;

    _layers.removeAt(index);

    if (_currentLayerIndex >= _layers.length) {
      _currentLayerIndex = _layers.length - 1;
    }

    _saveHistory();
    notifyListeners();
  }

  void selectLayer(int index) {
    _currentLayerIndex = index;
    notifyListeners();
  }

  void toggleLayerVisibility(int index) {
    _layers[index].visible = !_layers[index].visible;
    _saveHistory();
    notifyListeners();
  }

  void renameLayer(int index, String newName) {
    _layers[index].name = newName;
    _saveHistory();
    notifyListeners();
  }

  void clearLayer(int index) {
    _layers[index].points.clear();
    _saveHistory();
    notifyListeners();
  }

  void clearAll() {
    for (final layer in _layers) {
      layer.points.clear();
    }
    _saveHistory();
    notifyListeners();
  }

  /// ===========================
  /// UNDO / REDO
  /// ===========================
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

  /// ===========================
  /// HISTORY MANAGEMENT
  /// ===========================
  void _saveHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final snapshot = _layers
        .map((l) => Layer(
      name: l.name,
      visible: l.visible,
      points: List<DrawPoint>.from(l.points),
    ))
        .toList();

    _history.add(snapshot);
    _historyIndex = _history.length - 1;
  }

  void _restoreFromHistory() {
    final snapshot = _history[_historyIndex];

    _layers
      ..clear()
      ..addAll(snapshot.map(
            (l) => Layer(
          name: l.name,
          visible: l.visible,
          points: List<DrawPoint>.from(l.points),
        ),
      ));

    _currentLayerIndex =
        _currentLayerIndex.clamp(0, _layers.length - 1);

    notifyListeners();
  }
}
