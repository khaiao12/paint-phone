// lib/presentation/state/layer_provider.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum LayerType { image, draw }

class DrawPoint {
  final Offset? point;
  final Paint paint;

  DrawPoint({required this.point, required this.paint});

  DrawPoint clone() => DrawPoint(
    point: point == null ? null : Offset(point!.dx, point!.dy),
    paint: paint,
  );
}

class Layer {
  LayerType type;
  String name;
  bool visible;

  List<DrawPoint> points;
  Uint8List? imageBytes;
  ui.Image? image;

  Layer({
    required this.name,
    required this.type,
    this.visible = true,
    List<DrawPoint>? points,
    this.imageBytes,
    this.image,
  }) : points = points ?? [];

  Layer clone() {
    return Layer(
      name: name,
      type: type,
      visible: visible,
      points: points.map((p) => p.clone()).toList(),
      imageBytes: imageBytes,
      image: image,
    );
  }
}

class LayerProvider extends ChangeNotifier {
  final List<Layer> _layers = [
    Layer(name: "Layer 1", type: LayerType.draw),
  ];

  int _currentLayerIndex = 0;

  final List<List<Layer>> _history = [];
  int _historyIndex = -1;

  LayerProvider() {
    _saveHistory();
  }

  List<Layer> get layers => _layers;
  int get currentLayerIndex => _currentLayerIndex;

  // ===========================================================
  // DRAWING
  // ===========================================================
  void addPoint(Offset point, Paint paint) {
    final layer = _layers[_currentLayerIndex];
    if (layer.type == LayerType.image) return;

    layer.points.add(DrawPoint(point: point, paint: paint));
    notifyListeners();
  }

  void endStroke() {
    final layer = _layers[_currentLayerIndex];
    if (layer.type == LayerType.image) return;

    if (layer.points.isEmpty) return;

    if (layer.points.last.point != null) {
      layer.points
          .add(DrawPoint(point: null, paint: layer.points.last.paint));
    }

    _saveHistory();
    notifyListeners();
  }

  // ===========================================================
  // LAYER OPERATIONS
  // ===========================================================
  void addLayer() {
    _layers.add(Layer(
      name: "Layer ${_layers.length + 1}",
      type: LayerType.draw,
    ));
    _currentLayerIndex = _layers.length - 1;
    _saveHistory();
    notifyListeners();
  }

  Future<void> addImageLayer(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    _layers.insert(
      0,
      Layer(
        name: "Image Layer",
        type: LayerType.image,
        imageBytes: bytes,
        image: frame.image,
      ),
    );

    _currentLayerIndex++;
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
    _layers[index].image = null;
    _layers[index].imageBytes = null;

    if (_layers[index].type == LayerType.image) {
      _layers[index].type = LayerType.draw;
    }

    _saveHistory();
    notifyListeners();
  }

  void clearAll() {
    for (final l in _layers) {
      l.points.clear();
      l.image = null;
      l.imageBytes = null;
      l.type = LayerType.draw;
    }
    _saveHistory();
    notifyListeners();
  }

  // ===========================================================
  // UNDO / REDO
  // ===========================================================
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

  // ===========================================================
  // HISTORY
  // ===========================================================
  void _saveHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final snapshot = _layers.map((e) => e.clone()).toList();

    _history.add(snapshot);
    _historyIndex = _history.length - 1;
  }

  void _restoreFromHistory() {
    final snapshot = _history[_historyIndex];

    _layers
      ..clear()
      ..addAll(snapshot.map((e) => e.clone()));

    _currentLayerIndex =
        _currentLayerIndex.clamp(0, _layers.length - 1);

    notifyListeners();
  }
}
