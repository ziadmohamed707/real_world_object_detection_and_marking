import 'package:flutter/material.dart';

class CameraToggleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CameraToggleButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: IconButton(
        icon: Icon(Icons.camera_front, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}