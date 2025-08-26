import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:turfly_new/screens/user/user_turf_details_page.dart';

import 'package:turfly_new/screens/user/confirmation_page.dart';



class SlotPage extends StatefulWidget {

  final Map<String, dynamic> turfData;

  const SlotPage({super.key, required this.turfData});

  @override

  State<SlotPage> createState() => _SlotPageState();

}



class _SlotPageState extends State<SlotPage> {

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> availableSlots = [];

  bool _loading = true;

  Set<int> _selectedSlots = {};



  @override

  void initState() {

    super.initState();

    _loadSlotsForDate(_selectedDate);

  }



  Future<void> _loadSlotsForDate(DateTime date) async {

    setState(() {

      _loading = true;

      availableSlots = [];

      _selectedSlots.clear();

    });

    try {

      final String turfId = widget.turfData['turfId'] ?? '';

      if (turfId.isEmpty) {

        setState(() => _loading = false);

        return;

      }

      String dateString = DateFormat('yyyy-MM-dd').format(date);

      final QuerySnapshot<Map<String, dynamic>> slotSnapshot = await FirebaseFirestore.instance

          .collection('turfs').doc(turfId)

          .collection('slots')

          .where('date', isEqualTo: dateString)

          .get();

      final slots = slotSnapshot.docs.map((doc) {

        final data = doc.data();

        data['id'] = doc.id;

        return data;

      }).toList();

      setState(() {

        availableSlots = slots;

        _loading = false;

      });

    } catch (e) {

      setState(() {

        availableSlots = [];

        _loading = false;

      });

    }

  }



  @override

  Widget build(BuildContext context) {

    final sports = List<String>.from(widget.turfData['sports'] ?? []);

    return Scaffold(

      appBar: PreferredSize(

        preferredSize: const Size.fromHeight(kToolbarHeight + 20),

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

            title: Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Image.asset('assets/images/turf_logof.png', height: 60, width: 60),

                const SizedBox(width: 6),

                Image.asset('assets/images/TURFLY.png', height: 30),

              ],

            ),

            backgroundColor: Colors.transparent,

            elevation: 0,

            centerTitle: true,

            actions: [

              IconButton(

                icon: const Icon(Icons.calendar_today, color: Colors.black),

                onPressed: () async {

                  final picked = await showDatePicker(

                    context: context,

                    initialDate: _selectedDate,

                    firstDate: DateTime.now().subtract(const Duration(days: 1)),

                    lastDate: DateTime.now().add(const Duration(days: 30)),

                  );

                  if (picked != null && picked != _selectedDate) {

                    setState(() => _selectedDate = picked);

                    _loadSlotsForDate(picked);

                  }

                },

              ),

              IconButton(

                icon: const Icon(Icons.info_outline, color: Colors.black),

                onPressed: () => Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => UserTurfDetailsPage(

                      turfData: widget.turfData,

                      userData: {},

                    ),

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

      body: Column(

        children: [

          // Date Selector

          Container(

            height: 100,

            padding: const EdgeInsets.symmetric(vertical: 8),

            decoration: BoxDecoration(

              color: Colors.green[50],

              border: Border(

                bottom: BorderSide(color: Colors.green[100]!, width: 1),

              ),

            ),

            child: ListView.builder(

              scrollDirection: Axis.horizontal,

              itemCount: 7,

              itemBuilder: (context, index) {

                final date = DateTime.now().add(Duration(days: index));

                final isSelected = _selectedDate.year == date.year &&

                    _selectedDate.month == date.month &&

                    _selectedDate.day == date.day;

                return GestureDetector(

                  onTap: () {

                    setState(() => _selectedDate = date);

                    _loadSlotsForDate(date);

                  },

                  child: Container(

                    width: 70,

                    margin: const EdgeInsets.symmetric(horizontal: 8),

                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF68FF70) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF005204) : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),

                    child: FittedBox(

                      fit: BoxFit.scaleDown,

                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          Text(

                            DateFormat('EEE').format(date).substring(0, 3),

                            style: TextStyle(

                              color: isSelected ? Colors.white : Colors.black,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                          const SizedBox(height: 4),

                          Text(

                            '${date.day}',

                            style: TextStyle(

                              fontSize: 24,

                              color: isSelected ? Colors.white : Colors.black,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                          Text(

                            DateFormat('MMM').format(date).substring(0, 3),

                            style: TextStyle(

                              color: isSelected ? Colors.white : Colors.black,

                              fontSize: 14,

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                );

              },

            ),

          ),

          // Book Now Button - top right, only if a slot is selected

          Padding(

            padding: const EdgeInsets.only(right: 24, top: 8, bottom: 8),

            child: Align(

              alignment: Alignment.centerRight,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: _selectedSlots.isNotEmpty ? Colors.green[500] : Colors.grey.shade400,

                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

                  shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(8)),

                ),

                onPressed: _selectedSlots.isNotEmpty

                    ? () {

                  final slotsToBook = _selectedSlots.map((idx) => availableSlots[idx]).toList();

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) => ConfirmationPage(

                        selectedSlots: slotsToBook,

                        turfData: widget.turfData,

                      ),

                    ),

                  );

                }

                    : null,

                child: const Text(

                  "Book Now",

                  style: TextStyle(

                    fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,

                  ),

                ),

              ),

            ),

          ),

          // Available Sports with Icons

          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

            child: Row(

              children: [

                const Text(

                  'Available Sports: ',

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                    fontSize: 16,

                  ),

                ),

                Wrap(

                  spacing: 8,

                  children: sports.map((sport) {

                    final iconPath = 'assets/images/${sport.toLowerCase().replaceAll(' ', '_')}-icon.png';

                    return Image.asset(

                      iconPath,

                      width: 30,

                      height: 30,

                      errorBuilder: (context, error, stackTrace) {

                        return const SizedBox(width: 30, height: 30);

                      },

                    );

                  }).toList(),

                ),

              ],

            ),

          ),

          // Available Slots

          Expanded(

            child: _loading

                ? const Center(child: CircularProgressIndicator())

                : availableSlots.isEmpty

                ? const Center(

              child: Text(

                'No slots available for selected date',

                style: TextStyle(fontSize: 16, color: Colors.black54),

              ),

            )

                : Padding(

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

              child: GridView.builder(

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 2,

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: 1.7,

                ),

                itemCount: availableSlots.length,

                itemBuilder: (context, index) {

                  final slot = availableSlots[index];

                  final time = "${slot['fromTime']} To ${slot['toTime']}";

                  final price = slot['payment'] ?? '';

                  final isSelected = _selectedSlots.contains(index);



                  return GestureDetector(

                    onTap: () {

                      setState(() {

                        if (isSelected) {

                          _selectedSlots.remove(index);

                        } else {

                          _selectedSlots.add(index);

                        }

                      });

                    },

                    child: AnimatedContainer(

                      duration: const Duration(milliseconds: 200),

                      decoration: BoxDecoration(

                        color: isSelected ? Colors.green[50] : Colors.white,

                        border: Border.all(

                          color: isSelected ? Colors.green : Colors.grey.shade300,

                          width: isSelected ? 2 : 1,

                        ),

                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [

                          BoxShadow(

                            color: Colors.grey.withOpacity(0.15),

                            blurRadius: 5,

                            offset: const Offset(0, 2),

                          ),

                        ],

                      ),

                      child: Padding(

                        padding: const EdgeInsets.all(8),

                        child: FittedBox(

                          fit: BoxFit.scaleDown,

                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.center,

                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [

                              Text(

                                time,

                                textAlign: TextAlign.center,

                                style: const TextStyle(

                                  fontSize: 15,

                                  fontWeight: FontWeight.bold,

                                ),

                              ),

                              if (price.toString().isNotEmpty) ...[

                                const SizedBox(height: 8),

                                Text(

                                  '₹ $price',

                                  style: const TextStyle(

                                    fontSize: 15,

                                    color: Colors.green,

                                    fontWeight: FontWeight.bold,

                                  ),

                                ),

                              ],

                            ],

                          ),

                        ),

                      ),

                    ),

                  );

                },

              ),

            ),

          ),

        ],

      ),

    );

  }

}