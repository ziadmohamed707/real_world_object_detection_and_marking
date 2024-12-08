import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RealTimeObjectDetectionHelper {
  final BuildContext context;

  RealTimeObjectDetectionHelper(this.context);

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


}


class UserHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        const Text('User Info', style: TextStyle(color: Colors.white, fontSize: 30,fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Email: ${user?.email ?? "Not logged in"}', style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

