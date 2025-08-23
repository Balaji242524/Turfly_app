import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfly_new/screens/user_login.dart';
import 'package:turfly_new/screens/user/slot_page.dart';
import 'package:turfly_new/screens/user/user_turf_details_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentImageIndex = 0;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserLoginPage()),
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00ED0C), Color(0xFF008B05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            title: _showSearch
                ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search turfs...',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: _toggleSearch,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/turf_logof.png', height: 60, width: 60),
                const SizedBox(width: 6),
                Image.asset('assets/images/TURFLY.png', height: 30),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (!_showSearch)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 28),
                  onPressed: _toggleSearch,
                ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00ED0C), Color(0xFF008B05)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Welcome, User!',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(FirebaseAuth.instance.currentUser?.email ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sliding Image Banner
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView(
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  children: [
                    Image.asset('assets/images/turf.jpg', fit: BoxFit.cover),
                    Image.asset('assets/images/turf1.jpeg', fit: BoxFit.cover),
                    Image.asset('assets/images/turf2.jpg', fit: BoxFit.cover),
                    Image.asset('assets/images/turf3.jpg', fit: BoxFit.cover),
                    Image.asset('assets/images/turf4.jpg', fit: BoxFit.cover),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Turfs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Turf Cards
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('turfs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Attach turfId to every data map
                var turfs = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['turfId'] = doc.id; // <<--- KEY LINE
                  return data;
                }).toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  turfs = turfs.where((data) {
                    final name = data['turfName']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery);
                  }).toList();
                }

                if (turfs.isEmpty) {
                  return const Center(child: Text('No turfs available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: turfs.length,
                  itemBuilder: (context, index) {
                    final data = turfs[index];

                    final turfName = data['turfName'] ?? 'Unnamed Turf';
                    final imageUrls = List<String>.from(data['images'] ?? []);
                    final firstImage = imageUrls.isNotEmpty ? imageUrls[0] : null;
                    final rating = data['rating'] ?? 4.5;
                    final sports = List<String>.from(data['sports'] ?? []);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SlotPage(turfData: data),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    image: firstImage != null
                                        ? DecorationImage(
                                      image: NetworkImage(firstImage),
                                      fit: BoxFit.cover,
                                    )
                                        : const DecorationImage(
                                      image: AssetImage('assets/images/turf.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.info_outline,
                                        color: Colors.black, size: 28),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserTurfDetailsPage(
                                            turfData: data,
                                            userData: {},
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        turfName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          Text(' $rating'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: sports.map((sport) {
                                      final iconPath =
                                          'assets/images/${sport.toLowerCase().replaceAll(' ', '_')}-icon.png';
                                      return Image.asset(
                                        iconPath,
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const SizedBox(width: 24, height: 24);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
