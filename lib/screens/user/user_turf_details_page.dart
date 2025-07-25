import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserTurfDetailsPage extends StatelessWidget {
  final Map<String, dynamic> turfData;
  final Map<String, dynamic> userData;

  const UserTurfDetailsPage({
    super.key,
    required this.turfData,
    required this.userData,
  });

  Future<void> _launchMap(String? lat, String? lng) async {
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final turfName = turfData['turfName'] ?? 'Unnamed Turf';
    final images = List<String>.from(turfData['images'] ?? []);
    final sports = List<String>.from(turfData['sports'] ?? []);
    final amenities = List<String>.from(turfData['amenities'] ?? []);
    final rating = turfData['rating'] ?? 4.5;
    final lat = turfData['latitude']?.toString();
    final lng = turfData['longitude']?.toString();
    final squareFeet = turfData['squareFeet'] ?? '';
    final description = turfData['description'] ?? 'No description available';

    return Scaffold(
      appBar: AppBar(
        title: Text(turfName),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel
            SizedBox(
              height: 250,
              child: images.isNotEmpty
                  ? PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                  );
                },
              )
                  : Image.asset(
                'assets/images/turf_placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        turfName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text(' $rating'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  GestureDetector(
                    onTap: () => _launchMap(lat, lng),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'View on Map',
                          style: TextStyle(
                            color: Colors.blue[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  // Sports
                  const Text(
                    'Available Sports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: sports.map((sport) {
                      return Chip(
                        label: Text(sport),
                        backgroundColor: Colors.green[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Amenities
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: amenities.map((amenity) {
                      return Chip(
                        label: Text(amenity),
                        backgroundColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Handle booking
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}