import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  MapPage({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación en el Mapa'),
        backgroundColor: Colors.teal,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: 'Tu ubicación',
            ),
          ),
        },
      ),
    );
  }
}
