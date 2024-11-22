// map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bestlocation/model/location.dart';
import 'package:bestlocation/services/api_service.dart';

class MapScreen extends StatefulWidget {
  final List<Location> locations;
  final bool isAddingLocation;

  const MapScreen({
    Key? key,
    required this.locations,
    this.isAddingLocation = false,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Map controller
  final MapController _mapController = MapController();

  // Selected position
  LatLng? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    // Create markers from existing locations
    List<Marker> markers = widget.locations.map((location) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(
          double.parse(location.lat!),
          double.parse(location.long!),
        ),
        child: Stack(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
            Positioned(
              top: 0,
              child: Text(
                location.pseudo ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();

    // Add selected position marker
    if (_selectedPosition != null) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: _selectedPosition!,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: markers.isNotEmpty
              ? markers.first.point
              : LatLng(35.6324, 10.8960), // Center on the first location
          initialZoom: 15,
          onTap: widget.isAddingLocation
              ? (tapPosition, latLng) {
                  setState(() {
                    _selectedPosition = latLng;
                  });
                  // Open the form to enter additional details
                  _showAddLocationDialog(latLng);
                }
              : null, // Disable onTap if not adding location
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog(LatLng latLng) {
    // Controllers for the input fields
    final _pseudoController = TextEditingController();
    final _numeroController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Location Details'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView( // Added to prevent overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _pseudoController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close dialog
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Create new Location object
                  final newLocation = Location(
                    pseudo: _pseudoController.text,
                    numero: _numeroController.text,
                    lat: latLng.latitude.toString(),
                    long: latLng.longitude.toString(),
                  );

                  // Save to API
                  await ApiService.post(
                      endPoint: "", body: newLocation.toJson());

                  // Return the new location to HomeScreen
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, newLocation); // Close MapScreen
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
