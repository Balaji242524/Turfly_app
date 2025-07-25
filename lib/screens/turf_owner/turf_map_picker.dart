import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TurfMapPicker extends StatefulWidget {
  @override
  _TurfMapPickerState createState() => _TurfMapPickerState();
}

class _TurfMapPickerState extends State<TurfMapPicker> {
  LatLng? selectedLocation;
  GoogleMapController? mapController;

  Future<LatLng> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Turf Location')),
      body: FutureBuilder<LatLng>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final initialPosition = snapshot.data!;
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: (position) {
              setState(() {
                selectedLocation = position;
              });
            },
            markers: selectedLocation == null
                ? {}
                : {
              Marker(
                markerId: MarkerId('picked-location'),
                position: selectedLocation!,
              )
            },
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
