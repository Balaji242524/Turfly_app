import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'turf_map_picker.dart';

class AddTurf extends StatefulWidget {
  @override
  _AddTurfState createState() => _AddTurfState();
}

class _AddTurfState extends State<AddTurf> {
  final _formKey = GlobalKey<FormState>();
  final _turfNameController = TextEditingController();
  final _squareFeetController = TextEditingController();

  List<String> selectedSports = [];
  List<String> selectedAmenities = [];
  List<String> uploadedFiles = [];

  final List<String> sports = ['Cricket', 'Cricket Net', 'Football', 'Tennis'];
  final List<String> amenities = ['Toilet', 'Parking', 'Relax Area', 'Food Court'];

  LatLng? pickedLocation;

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (result != null) {
      List<String> urls = [];
      for (var file in result.files) {
        Uint8List? fileBytes = file.bytes;
        String fileName = file.name;

        if (fileBytes != null) {
          String? uploadedUrl = await uploadToCloudinary(fileBytes, fileName);
          if (uploadedUrl != null) {
            urls.add(uploadedUrl);
          }
        }
      }

      setState(() {
        uploadedFiles = urls;
      });
    }
  }

  Future<String?> uploadToCloudinary(Uint8List fileBytes, String fileName) async {
    const String uploadPreset = "turfly";
    const String cloudName = "dfgkbj3io";

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      print("Cloudinary Upload Error: ${response.statusCode}");
      return null;
    }
  }

  void saveTurfDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_formKey.currentState!.validate() && pickedLocation != null) {
      try {
        await FirebaseFirestore.instance.collection('turfs').doc(user.uid).set({
          'ownerId': user.uid,
          'turfName': _turfNameController.text.trim(),
          'latitude': pickedLocation!.latitude,
          'longitude': pickedLocation!.longitude,
          'squareFeet': _squareFeetController.text.trim(),
          'sports': selectedSports,
          'amenities': selectedAmenities,
          'images': uploadedFiles,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Turf details added successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving turf: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Top Header
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF00ED0C), Color(0xFF008B05)]),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Image.asset('assets/images/turf_logof.png',
                          height: 60, width: 60),
                      SizedBox(width: 6),
                      Image.asset('assets/images/TURFLY.png', height: 30),
                    ],
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            // ✅ Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildInputField(
                          icon: Icons.edit,
                          hint: 'Enter your Turf Name',
                          controller: _turfNameController),
                      // File Upload
                      GestureDetector(
                        onTap: pickFiles,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload, color: Color(0xFF00ED0C)),
                              SizedBox(width: 10),
                              Text("Upload Turf Images"),
                            ],
                          ),
                        ),
                      ),
                      if (uploadedFiles.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: uploadedFiles
                              .map((url) => Chip(label: Text("Image Uploaded")))
                              .toList(),
                        ),

                      // ✅ Flutter Map Picker
                      GestureDetector(
                        onTap: () async {
                          final LatLng? location = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TurfMapPicker(),
                            ),
                          );
                          if (location != null) {
                            setState(() {
                              pickedLocation = location;
                            });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListTile(
                            leading:
                            Icon(Icons.location_on, color: Color(0xFF00ED0C)),
                            title: Text(
                              pickedLocation == null
                                  ? 'Add your Turf Location'
                                  : '${pickedLocation!.latitude}, ${pickedLocation!.longitude}',
                              style: TextStyle(
                                  color: pickedLocation == null
                                      ? Colors.grey
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),

                      // Square Feet
                      buildInputField(
                        icon: Icons.grid_on,
                        hint: 'Enter Turf total Square Feet',
                        controller: _squareFeetController,
                        type: TextInputType.number,
                      ),

                      // Sports
                      buildMultiSelectChips(
                        label: 'Add Available Sport',
                        options: sports,
                        selectedItems: selectedSports,
                        onChanged: (list) =>
                            setState(() => selectedSports = list),
                      ),

                      // Amenities
                      buildMultiSelectChips(
                        label: 'Add Available Amenities',
                        options: amenities,
                        selectedItems: selectedAmenities,
                        onChanged: (list) =>
                            setState(() => selectedAmenities = list),
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: saveTurfDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00ED0C),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: Text('Save',
                            style:
                            TextStyle(color: Colors.black, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Input Field
  Widget buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF00ED0C)),
        title: TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        ),
      ),
    );
  }

  // ✅ Multi-select chips
  Widget buildMultiSelectChips({
    required String label,
    required List<String> options,
    required List<String> selectedItems,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (!selectedItems.contains(value)) {
              selectedItems.add(value);
              onChanged(List.from(selectedItems));
            }
          },
          itemBuilder: (context) => options
              .where((item) => !selectedItems.contains(item))
              .map((item) =>
              PopupMenuItem(value: item, child: Text(item)))
              .toList(),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(label),
                Spacer(),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: selectedItems.map((item) {
            return Chip(
              label: Text(item),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                selectedItems.remove(item);
                onChanged(List.from(selectedItems));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ✅ Turf Map Picker (Flutter Map)


