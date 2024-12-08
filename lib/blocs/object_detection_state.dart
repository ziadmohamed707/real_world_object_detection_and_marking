import 'package:camera/camera.dart';

abstract class ObjectDetectionState {}

class ObjectDetectionInitial extends ObjectDetectionState {}

class ModelLoaded extends ObjectDetectionState {
  final String modelPath;

  ModelLoaded(this.modelPath);
}

class CameraInitialized extends ObjectDetectionState {
  final CameraDescription cameraDescription;

  CameraInitialized(this.cameraDescription);
}

class ModelRunning extends ObjectDetectionState {
  final List<dynamic> recognitions;

  ModelRunning(this.recognitions);
}

class ModelLoadingError extends ObjectDetectionState {
  final String error;

  ModelLoadingError(this.error);
}