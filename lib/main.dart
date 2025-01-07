import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: ImagePickerApp(),
  ));
}

class ImagePickerApp extends StatefulWidget {
  @override
  _ImagePickerAppState createState() => _ImagePickerAppState();
}

class _ImagePickerAppState extends State<ImagePickerApp> {
  File? _image; // Almacena la imagen seleccionada
  final picker = ImagePicker();

  // Método para seleccionar una imagen
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Imagen desde Galería'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : Text('No hay imagen seleccionada'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Seleccionar Imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
