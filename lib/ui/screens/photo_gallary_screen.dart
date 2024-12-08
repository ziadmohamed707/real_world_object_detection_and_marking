import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final List<String> savedPhotos;
  final Function(String) onPhotoDeleted;

  PhotoGalleryScreen({required this.savedPhotos, required this.onPhotoDeleted});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: widget.savedPhotos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.file(
              File(widget.savedPhotos[index]),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(widget.savedPhotos[index].split('/').last),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.onPhotoDeleted(widget.savedPhotos[index]);
                });
              },
            ),
          );
        },
      ),
    );
  }
}