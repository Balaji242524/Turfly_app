import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:turfly_new/screens/user/slot_page.dart';

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
    final description = turfData['description'];
    final squareFeet = turfData['squareFeet']?.toString();
    int _currentImageIndex = 0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00ED0C), Color(0xFF008B05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            title: Text(turfName),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bordered Image Carousel
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green[800]!, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      images.isNotEmpty
                          ? PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          _currentImageIndex = index;
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      )
                          : Image.asset(
                        'assets/images/turf.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name / Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        turfName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text('$rating'),
                        ],
                      ),
                    ],
                  ),
                  // Square feet info
                  if (squareFeet != null && squareFeet.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.square_foot, size: 16, color: Colors.green),
                        const SizedBox(width: 5),
                        Text(
                          '$squareFeet sq.ft',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
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
                  if (description != null && (description as String).trim().isNotEmpty)
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
                      final iconPath = 'assets/images/${sport.toLowerCase().replaceAll(' ', '_')}-icon.png';
                      return Column(
                        children: [
                          Image.asset(
                            iconPath,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(width: 40, height: 40);
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(sport),
                        ],
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
                      final iconPath = 'assets/images/${amenity.toLowerCase().replaceAll(' ', '_')}-icon.png';
                      return Column(
                        children: [
                          Image.asset(
                            iconPath,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(width: 40, height: 40);
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(amenity),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.green[500],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SlotPage(
                              turfData: turfData,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
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
