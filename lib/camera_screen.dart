import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'RecyclingGuideScreen.dart'; // Importa la nueva pantalla

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? galleryImage = await _picker.pickImage(source: ImageSource.gallery);
    if (galleryImage != null) {
      setState(() {
        _image = File(galleryImage.path);
      });
    }
  }

  void _navigateToRecyclingGuide() {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecyclingGuideScreen(image: _image!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Captura o Selección de Foto"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text("No hay imagen seleccionada.")
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePhoto,
              child: Text("Tomar foto"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickFromGallery,
              child: Text("Seleccionar desde galería"),
            ),
            SizedBox(height: 20),
            if (_image != null)
              ElevatedButton(
                onPressed: _navigateToRecyclingGuide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Cambia 'primary' a 'backgroundColor'
                ),
                child: Text("¿Cómo reciclar?"),
              ),
          ],
        ),
      ),
    );
  }
}
