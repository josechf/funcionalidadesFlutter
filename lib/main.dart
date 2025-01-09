import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gyayczezbyxmstzzakax.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5YXljemV6Ynl4bXN0enpha2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU0Nzk0NzksImV4cCI6MjA1MTA1NTQ3OX0.i3jytGYlktlVOrGmpcp89JpX-CD00MlsoHVJ_VKAptI',
  );

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
  String? _imageUrl; // URL de la imagen subida
  final picker = ImagePicker();

  // Seleccionar una imagen de la galería
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Subir la imagen a Supabase Storage
  Future<void> _uploadImage() async {
    if (_image == null) {
      print('No hay imagen seleccionada');
      return;
    }

    final supabase = Supabase.instance.client;
    final imageName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await supabase.storage.from('Prueba1').upload(imageName, _image!);
      final publicUrl =
          supabase.storage.from('Prueba1').getPublicUrl(imageName);

      setState(() {
        _imageUrl = publicUrl;
      });

      print('Imagen subida correctamente: $publicUrl');
    } catch (e) {
      print('Error al subir la imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Imagen a Supabase'),
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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Subir Imagen a Supabase'),
            ),
            SizedBox(height: 20),
            _imageUrl != null
                ? Text('URL de la imagen:\n$_imageUrl')
                : Text('No se ha subido ninguna imagen'),
          ],
        ),
      ),
    );
  }
}
