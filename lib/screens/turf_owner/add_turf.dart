import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turfly/screens/turf_owner/turf_map_picker.dart';

class AddTurf extends StatefulWidget {
  @override
  _AddTurfState createState() => _AddTurfState();
}

class _AddTurfState extends State<AddTurf> {
  final _formKey = GlobalKey<FormState>();
  final _turfNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _squareFeetController = TextEditingController();

  List<String> selectedSports = [];
  List<String> selectedAmenities = [];
  List<String> uploadedFiles = [];

  final List<String> sports = ['Cricket', 'Cricket Net', 'Football', 'Tennis'];
  final List<String> amenities = ['Toilet', 'Parking', 'Relax Area', 'Food Court'];

  void saveTurfDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('turfs').add({
          'name': _turfNameController.text.trim(),
          'location': _locationController.text.trim(),
          'squareFeet': _squareFeetController.text.trim(),
          'sports': selectedSports,
          'amenities': selectedAmenities,
          'uploads': uploadedFiles,
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
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        uploadedFiles = result.files.map((f) => f.name).toList();
      });
    }
  }

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
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

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
              .map((item) => PopupMenuItem(value: item, child: Text(item)))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00ED0C), Color(0xFF008B05)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
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
                      Image.asset('assets/images/turf_logof.png', height: 60, width: 60),
                      SizedBox(width: 6),
                      Image.asset('assets/images/TURFLY.png', height: 30),
                    ],
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            // Form
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
                        controller: _turfNameController,
                      ),
                      GestureDetector(
                        onTap: pickFiles,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload, color: Color(0xFF00ED0C)),
                              SizedBox(width: 10),
                              Text("Upload Turf Images/Videos"),
                            ],
                          ),
                        ),
                      ),
                      if (uploadedFiles.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: uploadedFiles.map((name) => Chip(label: Text(name))).toList(),
                        ),
                      GestureDetector(
                        onTap: () async {
                          final LatLng? pickedLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TurfMapPicker()),
                          );
                          if (pickedLocation != null) {
                            setState(() {
                              _locationController.text =
                              '${pickedLocation.latitude}, ${pickedLocation.longitude}';
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
                            leading: Icon(Icons.location_on, color: Color(0xFF00ED0C)),
                            title: Text(
                              _locationController.text.isEmpty
                                  ? 'Add your Turf Location'
                                  : _locationController.text,
                              style: TextStyle(
                                color: _locationController.text.isEmpty ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      buildInputField(
                        icon: Icons.grid_on,
                        hint: 'Enter Turf total Square Feet',
                        controller: _squareFeetController,
                        type: TextInputType.number,
                      ),
                      buildMultiSelectChips(
                        label: 'Add Available Sport',
                        options: sports,
                        selectedItems: selectedSports,
                        onChanged: (list) => setState(() => selectedSports = list),
                      ),
                      buildMultiSelectChips(
                        label: 'Add Available Amenities',
                        options: amenities,
                        selectedItems: selectedAmenities,
                        onChanged: (list) => setState(() => selectedAmenities = list),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: saveTurfDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00ED0C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: Text('Save', style: TextStyle(color: Colors.black, fontSize: 16)),
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
}
