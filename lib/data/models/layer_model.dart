import 'package:flutter/material.dart';
import '../../presentation/state/layer_provider.dart';

class LayerModel {
  String name;
  bool visible;
  final List<DrawPoint> points;

  LayerModel({
    required this.name,
    this.visible = true,
    List<DrawPoint>? points,
  }) : points = points ?? [];
}
