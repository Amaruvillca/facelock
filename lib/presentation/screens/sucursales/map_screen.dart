import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa con flutter_map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-16.5173, -68.125), // CDMX
          initialZoom: 13,
        ),
        children: [
          // Capa de tiles (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          // Marcador
          MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 80,
                point: LatLng(-16.5173, -68.125),
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}