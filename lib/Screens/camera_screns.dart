import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      startAutoCapture();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAutoCapture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      // Kirim gambar ke Firebase Cloud Storage atau Firestore
      // Contoh:
      FirebaseStorage.instance.ref('images').child('auto_image.jpg').putFile(File(image.path));
      print('Foto diambil: ${image.path}');
    } catch (e) {
      print('Error saat mengambil foto otomatis: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Example')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            // Kirim gambar ke Firebase Cloud Storage atau Firestore
            // Contoh:
            FirebaseStorage.instance.ref('images').child('image1.jpg').putFile(File(image.path));
            print('Foto diambil: ${image.path}');
          } catch (e) {
            print('Error: $e');
          }
        },
      ),
    );
  }
}