import 'dart:ui';

class DetectedObject {
  final String label;
  final double confidence;
  final Rect boundingBox;

  DetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
}