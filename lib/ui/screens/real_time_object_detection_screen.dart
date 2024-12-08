import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/object_detection_bloc.dart';
import '../../blocs/object_detection_event.dart';
import '../../blocs/object_detection_state.dart';
import '../../helper/RealTimeObjectDetectionHelper.dart';
import 'login_screen.dart';

class RealTimeObjectDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RealTimeObjectDetectionScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _RealTimeObjectDetectionScreenState createState() => _RealTimeObjectDetectionScreenState();
}

class _RealTimeObjectDetectionScreenState extends State<RealTimeObjectDetectionScreen> {
  CameraController? _cameraController;
  List<String> savedPhotos = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _initializeCamera(widget.cameras.first);
    BlocProvider.of<ObjectDetectionBloc>(context).add(LoadModelEvent());
    _loadSavedPhotos(); // Load previously saved photos
    user = FirebaseAuth.instance.currentUser; // Get current user
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false);
    await _cameraController!.initialize();
    BlocProvider.of<ObjectDetectionBloc>(context).add(InitializeCameraEvent(camera));

    _cameraController!.startImageStream((CameraImage image) {
      BlocProvider.of<ObjectDetectionBloc>(context).add(RunModelEvent(image));
    });

    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final image = await _cameraController!.takePicture();
      await _savePhoto(image.path);
    } catch (e) {
      _showError("Error taking photo: ${e.toString()}");
    }
  }

  Future<void> _savePhoto(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/photos/${DateTime.now().millisecondsSinceEpoch}.png';
    await File(imagePath).copy(path);
    setState(() {
      savedPhotos.add(path); // Update saved photos list
    });
  }

  Future<void> _loadSavedPhotos() async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');
    if (await photosDir.exists()) {
      final photos = await photosDir.list().toList();
      setState(() {
        savedPhotos = photos.map((file) => file.path).toList();
      });
    } else {
      await photosDir.create();
    }
  }

  void _deletePhoto(String path) {
    File(path).delete();
    setState(() {
      savedPhotos.remove(path);
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen(cameras: widget.cameras)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ObjectDetectionBloc, ObjectDetectionState>(
      listener: (context, state) {
        if (state is ModelLoadingError) {
          _showError('Error: ${state.error}');
        }
      },
      builder: (context, state) {
        if (_cameraController == null || !_cameraController!.value.isInitialized) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
          body: _buildBody(state),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Live Cam Object Detection',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
      actions: [_buildPhotoAlbumButton()],
    );
  }

  IconButton _buildPhotoAlbumButton() {
    return IconButton(
      icon: const Icon(Icons.photo_album),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PhotoGalleryScreen(savedPhotos: savedPhotos, onPhotoDeleted: _deletePhoto),
        ));
      },
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Stack(
        children:[ ListView(
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: UserHeader(),
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
          Container(
              height: MediaQuery.sizeOf(context).height*0.28,
              alignment: Alignment.bottomRight,
              child: Icon(Icons.account_circle, size: 110, color: Colors.black,))
        
        ]
      ),
    );
  }

  Center _buildBody(ObjectDetectionState state) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CameraPreview(_cameraController!),
            if (state is ModelRunning) _buildBoundingBoxes(state),
            Positioned(
              bottom: 20,
              child: ElevatedButton(
                onPressed: _takePhoto,
                child: const Text('Take Photo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoundingBoxes(ModelRunning state) {
    return BoundingBoxes(
      recognitions: state.recognitions,
      previewH: _cameraController!.value.previewSize!.height,
      previewW: _cameraController!.value.previewSize!.width,
      screenH: MediaQuery.of(context).size.height * 0.80,
      screenW: MediaQuery.of(context).size.width * 0.80,
    );
  }
}

class BoundingBoxes extends StatelessWidget {
  final List<dynamic> recognitions;
  final double previewH;
  final double previewW;
  final double screenH;
  final double screenW;

  const BoundingBoxes({
    required this.recognitions,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: recognitions.map((rec) {
        final rect = rec["rect"];
        final x = rect["x"] * screenW;
        final y = rect["y"] * screenH;
        final w = rect["w"] * screenW;
        final h = rect["h"] * screenH;

        return Positioned(
          left: x,
          top: y,
          width: w,
          height: h,
          child: _buildBoundingBox(rec),
        );
      }).toList(),
    );
  }

  Widget _buildBoundingBox(dynamic rec) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 3),
      ),
      child: Text(
        "${rec["detectedClass"]} ${(rec["confidenceInClass"] * 100).toStringAsFixed(0)}%",
        style: const TextStyle(color: Colors.red, fontSize: 15, backgroundColor: Colors.black),
      ),
    );
  }
}



class PhotoGalleryScreen extends StatelessWidget {
  final List<String> savedPhotos;
  final Function(String) onPhotoDeleted;

  const PhotoGalleryScreen({Key? key, required this.savedPhotos, required this.onPhotoDeleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Photos')),
      body: ListView.builder(
        itemCount: savedPhotos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.file(
              File(savedPhotos[index]),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(savedPhotos[index].split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                onPhotoDeleted(savedPhotos[index]);
              },
            ),
          );
        },
      ),
    );
  }
}