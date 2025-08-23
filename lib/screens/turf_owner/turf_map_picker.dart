import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class TurfMapPicker extends StatefulWidget {
  @override
  _TurfMapPickerState createState() => _TurfMapPickerState();
}

class _TurfMapPickerState extends State<TurfMapPicker> {
  LatLng? selectedLocation;
  late LatLng currentLocation;

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message and return null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, guide the user to app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions. Please enable them from settings.')),
      );
      return null;
    }

    // Permissions are granted, now get the current position
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Turf Location')),
      body: FutureBuilder<LatLng?>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            // Handle cases where location could not be fetched
            return Center(child: Text('Could not get your current location.'));
          }

          currentLocation = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 15,
              onTap: (tapPosition, latLng) {
                setState(() {
                  selectedLocation = latLng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.turfly',
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 80,
                      height: 80,
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
      floatingActionButton: selectedLocation != null
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, selectedLocation);
        },
        label: Text('Select'),
        icon: Icon(Icons.check),
      )
          : null,
    );
  }
}