import 'package:flutter/material.dart';
import 'add_turf.dart';

class TurfHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
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
                Icon(Icons.menu, color: Colors.black, size: 32),
                Row(
                  children: [
                    Image.asset('assets/images/turf_logof.png', height: 60, width: 60),
                    SizedBox(width: 6),
                    Image.asset(
                      'assets/images/TURFLY.png',
                      height: 30,
                    ),
                  ],
                ),
                Icon(Icons.notifications_none_outlined, color: Colors.black, size: 32),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                '↶ Add your turf',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),

          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00ED0C), Color(0xFF008B05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ADD Turf Button → Navigates to AddTurfPage
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTurf()),
                    );
                  },
                  child: Icon(Icons.add_circle_outline, size: 32, color: Colors.black),
                ),

                // PITCH IMAGE (Replaces sports icon)
                Image.asset(
                  'assets/images/mdi_football-pitch.png',
                  height: 32,
                  width: 32,
                ),

                // LOCATION ICON
                Icon(Icons.location_on_outlined, size: 32, color: Colors.black),

                // PROFILE ICON
                Icon(Icons.person_outline, size: 32, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
