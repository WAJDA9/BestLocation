

import 'package:bestlocation/map_screen.dart';
import 'package:bestlocation/model/location.dart';
import 'package:bestlocation/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Location> locations = [];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _pseudoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  Position? _currentPosition;

  @override
  void initState()  {
    super.initState();
    isLoading = true;
    getLocations();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _numeroController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> getLocations() async {
    try {
      List<Location> fetchedLocations = [];
      await ApiService.get(endPoint: "").then((value) {
        for (var item in value) {
          fetchedLocations.add(Location.fromJson(item));
        }
      });
      setState(() {
        locations = fetchedLocations;
        isLoading = false;
      });
      _startLocationUpdates();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations ${e.toString()}')),
      );
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          distanceFilter: 10, timeLimit: Duration(minutes: 1)),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        print(position);
      });
      _updateCurrentLocation();
    });
  }

  void _updateCurrentLocation() async {
    if (_currentPosition == null) return;

    final currentLocation = Location(
      pseudo: "Current Location",
      numero: "N/A",
      lat: _currentPosition!.latitude.toString(),
      long: _currentPosition!.longitude.toString(),
    );

    setState(() {
      locations
          .removeWhere((location) => location.pseudo == "Current Location");
      locations.insert(0, currentLocation);
     
    });
    //  await ApiService.post(endPoint: "", body: currentLocation.toJson());
  }

  void _showAddLocationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                // Added to handle overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add New Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pseudoController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) is! double) {
                                return 'Invalid Latitude';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _longController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) is! double) {
                                return 'Invalid Longitude';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Location'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final newLocation = Location(
        pseudo: _pseudoController.text,
        numero: _numeroController.text,
        lat: double.parse(_latController.text).toString(),
        long: double.parse(_longController.text).toString(),
      );

      await ApiService.post(endPoint: "", body: newLocation.toJson());

      // Clear form
      _pseudoController.clear();
      _numeroController.clear();
      _latController.clear();
      _longController.clear();
      await getLocations();
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Locations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              getLocations();
            },
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).primaryColor,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.map),
            label: 'View Map',
            onTap: () async {
              final newLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    locations: locations,
                    isAddingLocation: true,
                  ),
                ),
              );
              if (newLocation != null) {
                setState(() {
                  locations.add(newLocation);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location added successfully')),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_location_alt),
            label: 'Add Location on Map',
            onTap: () async {
              final newLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    locations: locations,
                    isAddingLocation: true,
                  ),
                ),
              );
              if (newLocation != null) {
                setState(() {
                  locations.add(newLocation);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location added successfully')),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Location Manually',
            onTap: _showAddLocationSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (locations.isEmpty && !isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder:  (context) => HomeScreen()));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Locations'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (locations.isNotEmpty)
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                await getLocations();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        location.pseudo ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                location.numero ?? 'N/A',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              
                              Text(
                                '${location.lat! ?? 'N/A'}, ${location.long! ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Location'),
                              content: const Text(
                                  'Are you sure you want to delete this location?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await ApiService.delete("/${location.id}");
                                    await getLocations();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          if (isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
