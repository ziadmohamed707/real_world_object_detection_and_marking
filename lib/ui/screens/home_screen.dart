import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/object_detection_bloc.dart';
import '../../blocs/object_detection_event.dart';
import '../../repositories/object_detection_repository.dart';
import 'real_time_object_detection_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ObjectDetectionBloc(ObjectDetectionRepository())..add(LoadModelEvent()),
      child: RealTimeObjectDetectionScreen(cameras: cameras,),
    );
  }
}