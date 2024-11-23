import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bestlocation/model/location.dart';
import 'package:geolocator/geolocator.dart';

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
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            distanceFilter: 10, timeLimit: Duration(minutes: 1)),
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
          print(position);
        });
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = widget.locations.sublist(1).map((location) {
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
              size: 30,
            ),
            Positioned(
              bottom: 0,
              left: 5,
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

    if (_currentPosition != null) {
      markers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: Column(
            children: [
              const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 30,
              ),
              const Text(
                "You",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map View'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
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
          initialCenter: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : (markers.isNotEmpty
                  ? markers.first.point
                  : LatLng(35.6324, 10.8960)),
          initialZoom: 15,
          onTap: widget.isAddingLocation
              ? (tapPosition, latLng) {
                  setState(() {
                    _selectedPosition = latLng;
                  });
                  _showAddLocationDialog(latLng);
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  void _showAddLocationDialog(LatLng latLng) {
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
            child: SingleChildScrollView(
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
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newLocation = Location(
                    pseudo: _pseudoController.text,
                    numero: _numeroController.text,
                    lat: latLng.latitude.toString(),
                    long: latLng.longitude.toString(),
                  );

                  Navigator.pop(context);
                  Navigator.pop(context, newLocation);
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
