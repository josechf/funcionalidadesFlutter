import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'mapa.dart';

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
  final _nameController = TextEditingController();
  final _ubicacionController = TextEditingController();
  File? _image; // Almacena la imagen seleccionada
  String? _imageUrl; // URL de la imagen subida
  final picker = ImagePicker();
  double? _latitude;
  double? _longitude;

//posicion

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Solicitar permisos y obtener la ubicación
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Los servicios de ubicación no están habilitados
      print('Los servicios de ubicación están desactivados.');
      return;
    }

    // Verificar el permiso de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Solicitar permiso
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permiso denegado
        print('Permiso de ubicación denegado.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permiso denegado permanentemente
      print('Permiso de ubicación denegado permanentemente.');
      return;
    }

    // Obtener la posición actual
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    print('Ubicación obtenida: $_latitude, $_longitude');
  }

//posicion

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
    final supabase = Supabase.instance.client;
    final imageName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final name = _nameController.text.trim();
    final ubicacion = _ubicacionController.text.trim();

    if (_image == null ||
        name.isEmpty ||
        ubicacion.isEmpty ||
        _longitude == null ||
        _latitude == null) {
      print('rellene los datos');
      return;
    }

    try {
      await supabase.storage.from('Prueba1').upload(imageName, _image!);
      final publicUrl =
          supabase.storage.from('Prueba1').getPublicUrl(imageName);

      final Query = await supabase.from('Arbol').insert({
        'nombre': name,
        'imagen_url': publicUrl,
        'ubicacion': ubicacion,
        'latitude': _latitude,
        'longitude': _longitude,
      });

      setState(() {
        _imageUrl = publicUrl;
        _nameController.clear();
        _ubicacionController.clear();
        _image = null;
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'nombre del arbol'),
            ),
            TextField(
              controller: _ubicacionController,
              decoration: InputDecoration(labelText: 'ubicacion del arbol'),
            ),
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
            _latitude != null && _longitude != null
                ? Text('Ubicación actual: $_latitude, $_longitude')
                : Text('Obteniendo ubicación...'),
            ElevatedButton(
              onPressed: () {
                if (_latitude != null && _longitude != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(
                        latitude: _latitude!,
                        longitude: _longitude!,
                      ),
                    ),
                  );
                } else {
                  print('No se pudo obtener la ubicación.');
                }
              },
              child: Text('Ver Mapa'),
            ),
          ],
        ),
      ),
    );
  }
}
