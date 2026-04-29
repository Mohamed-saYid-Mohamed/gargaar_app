import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  final bool readOnly;
  final void Function(
    double lat,
    double lng,
    String label,
    String address,
  )? onConfirm;

  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({
    super.key,
    this.readOnly = false,
    this.onConfirm,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLocation;
  final TextEditingController _labelController = TextEditingController();
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(
      widget.initialLat ?? 2.0469,
      widget.initialLng ?? 45.3182,
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  // ───────── CURRENT LOCATION ─────────
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locating = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedLocation = LatLng(
        position.latitude,
        position.longitude,
      );
      _locating = false;
    });
  }

  void _saveLocation() {
    if (_labelController.text.trim().isEmpty) return;

    widget.onConfirm?.call(
      _selectedLocation.latitude,
      _selectedLocation.longitude,
      _labelController.text.trim(),
      'Selected location',
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Location' : 'Add Location'),
      ),
      body: Stack(
        children: [
          // ───────── MAP ─────────
          FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15,
              onTap: widget.readOnly
                  ? null
                  : (_, point) {
                      setState(() => _selectedLocation = point);
                    },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ───────── CURRENT LOCATION BUTTON ─────────
          if (!widget.readOnly)
            Positioned(
              right: 16,
              bottom: 180,
              child: FloatingActionButton(
                onPressed: _locating ? null : _useCurrentLocation,
                child: _locating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.my_location),
              ),
            ),

          // ───────── SAVE PANEL ─────────
          if (!widget.readOnly)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          labelText: 'Place name (Home, Office, etc.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveLocation,
                          child: const Text('SAVE LOCATION'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
