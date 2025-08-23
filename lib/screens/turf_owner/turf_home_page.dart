import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turfly_new/screens/turf_login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_turf.dart';
import 'add_slot.dart';

class TurfHomePage extends StatefulWidget {
  const TurfHomePage({super.key});

  @override
  State<TurfHomePage> createState() => _TurfHomePageState();
}

class _TurfHomePageState extends State<TurfHomePage> {
  bool _showMenu = false;
  late Future<DocumentSnapshot> _turfFuture;
  bool _hasTurf = false;

  @override
  void initState() {
    super.initState();
    _checkTurfExists();
  }

  Future<void> _checkTurfExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('turfs').doc(user.uid).get();
    setState(() {
      _hasTurf = doc.exists;
      _turfFuture = _fetchTurfDetails();
    });
  }

  Future<DocumentSnapshot> _fetchTurfDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('turfs').doc(user?.uid).get();
  }

  Future<void> _refreshTurfData() async {
    await _checkTurfExists();
  }

  Future<void> _launchMap(String? lat, String? lng) async {
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TurfLoginPage()));
  }

  void _showProfileDialog(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Your Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${userData['name'] ?? 'N/A'}"),
            Text("Mobile: ${userData['mobile'] ?? 'N/A'}"),
            Text("Age: ${userData['age'] ?? 'N/A'}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  Future<void> _launchDialer() async {
    final url = Uri.parse("tel:9944031161");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showNotificationPopup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Notifications"),
        content: const Text("No notification available."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SafeArea(
            child: _hasTurf
                ? FutureBuilder<DocumentSnapshot>(
              future: _turfFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildAddTurfUI();
                }

                final turf = snapshot.data!.data() as Map<String, dynamic>;
                final List images = turf['images'] ?? [];
                final List sports = turf['sports'] ?? [];
                final List amenities = turf['amenities'] ?? [];
                final String? lat = turf['latitude']?.toString();
                final String? lng = turf['longitude']?.toString();

                return Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 12),
                        images.isNotEmpty
                            ? TurfImageCarousel(images: images)
                            : Container(
                          height: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black54),
                          ),
                          alignment: Alignment.center,
                          child: const Text('No turf images available'),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(turf['turfName'] ?? 'Turf name',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text('Rating of Turf'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.location_on_outlined),
                                        SizedBox(width: 10),
                                        Expanded(child: Text('Location of Turf')),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _launchMap(lat, lng),
                                      child: const Text('Go to map 🌍',
                                          style: TextStyle(color: Colors.blue)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('Available Sports',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                children: sports.map<Widget>((sport) {
                                  final path =
                                      'assets/images/${sport.toLowerCase().replaceAll(' ', '_')}-icon.png';
                                  return _buildIconOrFallback(path);
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                              const Text('Amenities',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                children: amenities.map<Widget>((item) {
                                  final path =
                                      'assets/images/${item.toLowerCase().replaceAll(' ', '_')}-icon.png';
                                  return _buildIconOrFallback(path);
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _bottomNavigationBar(user, lat, lng),
                      ],
                    ),
                    Positioned(
                      bottom: 80,
                      right: 20,
                      child: FloatingActionButton(
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTurf()));
                          _refreshTurfData();
                        },
                        backgroundColor: const Color(0xFF00ED0C),
                        child: const Icon(Icons.edit, color: Colors.black),
                      ),
                    )
                  ],
                );
              },
            )
                : _buildAddTurfUI(),
          ),
          if (_showMenu) _buildSideMenu(user),
        ],
      ),
    );
  }

  Widget _buildAddTurfUI() {
    return Column(
      children: [
        _buildHeader(),
        const Spacer(),
        const Center(child: Text('Add your Turf details', style: TextStyle(fontSize: 18))),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTurf()));
            _refreshTurfData();
          },
          child: const Text('Add Turf Details'),
        ),
        const Spacer(),
      ],
    );
  }


  Widget _bottomNavigationBar(User? user, String? lat, String? lng) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF00ED0C), Color(0xFF008B05)]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTurf()));
              _refreshTurfData();
            },
            child: const Icon(Icons.add_circle_outline, size: 32),
          ),
          GestureDetector(
            onTap: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddSlotPage(turfId: user.uid)),
                );
              }
            },
            child: Image.asset('assets/images/pitch.png', height: 32, width: 32),
          ),
          GestureDetector(
            onTap: () => _launchMap(lat, lng),
            child: const Icon(Icons.location_on_outlined, size: 32),
          ),
          GestureDetector(
            onTap: () async {
              final userData = (await FirebaseFirestore.instance.collection("turfs").doc(user?.uid).get()).data();
              if (userData != null) _showProfileDialog(userData);
            },
            child: const Icon(Icons.person_outline, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF00ED0C), Color(0xFF008B05)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showMenu = true),
            child: const Icon(Icons.menu, size: 32),
          ),
          Row(
            children: [
              Image.asset('assets/images/turf_logof.png', height: 60, width: 60),
              const SizedBox(width: 6),
              Image.asset('assets/images/TURFLY.png', height: 30),
            ],
          ),
          GestureDetector(
            onTap: _showNotificationPopup,
            child: const Icon(Icons.notifications_none_outlined, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu(User? user) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.75,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00ED0C), Color(0xFF008B05)]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_circle, size: 30),
                      SizedBox(width: 10),
                      Text("Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showMenu = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _menuItem(Icons.home, "Home", () => setState(() => _showMenu = false)),
            _menuItem(Icons.person_outline, "Profile", () async {
              final userData = (await FirebaseFirestore.instance.collection("turfs").doc(user?.uid).get()).data();
              if (userData != null) _showProfileDialog(userData);
            }),
            _menuItem(Icons.headset_mic_outlined, "Contact Us", _launchDialer),
            const Spacer(),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildIconOrFallback(String assetPath) {
    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      },
    );
  }
}

class TurfImageCarousel extends StatefulWidget {
  final List images;
  const TurfImageCarousel({super.key, required this.images});

  @override
  State<TurfImageCarousel> createState() => _TurfImageCarouselState();
}

class _TurfImageCarouselState extends State<TurfImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          setState(() => _currentIndex = (_currentIndex + 1) % widget.images.length);
        } else if (details.primaryVelocity! > 0) {
          setState(() => _currentIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length);
        }
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade300,
          image: DecorationImage(
            image: NetworkImage(widget.images[_currentIndex]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}