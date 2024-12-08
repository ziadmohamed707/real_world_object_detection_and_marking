import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:realtime_obj_detection/repositories/object_detection_repository.dart';
import 'package:tflite_v2/tflite_v2.dart';

import 'object_detection_event.dart';
import 'object_detection_state.dart';



class ObjectDetectionBloc extends Bloc<ObjectDetectionEvent, ObjectDetectionState> {
  bool _isModelLoaded = false;

  ObjectDetectionBloc(ObjectDetectionRepository objectDetectionRepository) : super(ObjectDetectionInitial()) {
    on<LoadModelEvent>(_onLoadModel);
    on<InitializeCameraEvent>(_onInitializeCamera);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<RunModelEvent>(_onRunModel);
  }

  Future<void> _onLoadModel(LoadModelEvent event, Emitter<ObjectDetectionState> emit) async {
    emit(ObjectDetectionInitial());
    try {
      String? res = await Tflite.loadModel(
        model: 'assets/detect.tflite',
        labels: 'assets/labelmap.txt',
      );

      _isModelLoaded = res != null;

      if (_isModelLoaded) {
        emit(ModelLoaded('Model loaded successfully'));
      } else {
        emit(ModelLoadingError('Failed to load model'));
      }
    } catch (error) {
      emit(ModelLoadingError(error.toString()));
    }
  }

  Future<void> _onInitializeCamera(InitializeCameraEvent event, Emitter<ObjectDetectionState> emit) async {
    if (event.cameraDescription != null) {
      emit(CameraInitialized(event.cameraDescription!));
    } else {
      emit(ModelLoadingError('No camera description provided.'));
    }
  }

  Future<void> _onToggleCamera(ToggleCameraEvent event, Emitter<ObjectDetectionState> emit) async {
    // Toggle camera logic can be handled here
  }

  Future<void> _onRunModel(RunModelEvent event, Emitter<ObjectDetectionState> emit) async {
    if (!_isModelLoaded) return;

    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: event.image.planes.map((plane) => plane.bytes).toList(),
      model: 'SSDMobileNet',
      imageHeight: event.image.height,
      imageWidth: event.image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    emit(ModelRunning(recognitions!));
  }
}