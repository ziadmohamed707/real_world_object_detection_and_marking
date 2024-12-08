import 'package:camera/camera.dart';

abstract class ObjectDetectionEvent {}

class LoadModelEvent extends ObjectDetectionEvent {}

class InitializeCameraEvent extends ObjectDetectionEvent {
  final CameraDescription? cameraDescription;

  InitializeCameraEvent(this.cameraDescription);
}

class ToggleCameraEvent extends ObjectDetectionEvent {}

class RunModelEvent extends ObjectDetectionEvent {
  final CameraImage image;

  RunModelEvent(this.image);
}