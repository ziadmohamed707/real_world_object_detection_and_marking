import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ObjectDetectionRepository {
  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/detect.tflite',
      labels: 'assets/labelmap.txt',
    );
  }

  Future<CameraController> initializeCamera(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    return controller;
  }

  Future<CameraDescription> getFrontCamera() async {
    final cameras = await availableCameras();
    return cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
  }

  Future<CameraDescription> getBackCamera() async {
    final cameras = await availableCameras();
    return cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
  }

  Future<List<dynamic>?> detectObjectsOnFrame(CameraImage image) async {
    if (image.planes.isEmpty) return [];
    final recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      model: 'SSDMobileNet',
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );
    return recognitions;
  }
}