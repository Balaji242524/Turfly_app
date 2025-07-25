import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSlotPage extends StatefulWidget {
  final String turfId;
  const AddSlotPage({super.key, required this.turfId});

  @override
  State<AddSlotPage> createState() => _AddSlotPageState();
}

class _AddSlotPageState extends State<AddSlotPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  TextEditingController paymentController = TextEditingController();
  bool isAddingSlot = false;
  String? editingSlotId;

  List<DateTime> getNext7Days() {
    return List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _pickFromTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => fromTime = picked);
  }

  void _pickToTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => toTime = picked);
  }

  Future<void> saveSlot() async {
    if (fromTime == null || toTime == null || paymentController.text.isEmpty) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final slotData = {
      'fromTime': fromTime!.format(context),
      'toTime': toTime!.format(context),
      'payment': paymentController.text,
      'date': formattedDate,
      'timestamp': Timestamp.now(),
    };

    final slotRef = FirebaseFirestore.instance
        .collection('turfs')
        .doc(widget.turfId)
        .collection('slots');

    if (editingSlotId != null) {
      await slotRef.doc(editingSlotId).update(slotData);
    } else {
      await slotRef.add(slotData);
    }

    setState(() {
      isAddingSlot = false;
      fromTime = null;
      toTime = null;
      paymentController.clear();
      editingSlotId = null;
    });
  }

  void editSlot(DocumentSnapshot slot) {
    setState(() {
      fromTime = _parseTime(slot['fromTime']);
      toTime = _parseTime(slot['toTime']);
      paymentController.text = slot['payment'];
      editingSlotId = slot.id;
      isAddingSlot = true;
    });
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final format = DateFormat.jm();
      final dateTime = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  Future<void> deleteSlot(String slotId) async {
    await FirebaseFirestore.instance
        .collection('turfs')
        .doc(widget.turfId)
        .collection('slots')
        .doc(slotId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final next7Days = getNext7Days();
    final selectedDateFormatted = DateFormat('yyyy-MM-dd').format(selectedDate);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00ED0C), Color(0xFF008B05)]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                BackButton(color: Colors.black),
                Image.asset('assets/images/turf_logof.png', height: 70, width: 70),
                SizedBox(width: 10),
                Image.asset('assets/images/TURFLY.png', height: 30),
                Spacer(),
                IconButton(onPressed: _pickDate, icon: Icon(Icons.calendar_today, color: Colors.black)),
              ],
            ),
          ),

          SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: next7Days.length,
              itemBuilder: (context, index) {
                final date = next7Days[index];
                final isSelected = DateFormat('yyyy-MM-dd').format(date) == selectedDateFormatted;
                return GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: dateCard(date, isSelected: isSelected),
                );
              },
            ),
          ),

          SizedBox(height: 20),

          if (!isAddingSlot)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  onTap: () => setState(() => isAddingSlot = true),
                  child: Icon(Icons.add_circle_outline, size: 40),
                ),
              ),
            ),

          if (isAddingSlot)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(children: [Icon(Icons.access_time), SizedBox(width: 10), Text('Add Timings')]),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickFromTime,
                      icon: Icon(Icons.edit, color: Colors.green),
                      label: Text(fromTime != null ? fromTime!.format(context) : 'Enter From Timing'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickToTime,
                      icon: Icon(Icons.edit, color: Colors.green),
                      label: Text(toTime != null ? toTime!.format(context) : 'Enter To Timing'),
                    ),
                    SizedBox(height: 20),
                    Row(children: [Icon(Icons.attach_money), SizedBox(width: 10), Text('Add Payment')]),
                    SizedBox(height: 10),
                    TextField(
                      controller: paymentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter Payment for this slot',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: saveSlot,
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00ED0C)),
                        child: Text(editingSlotId != null ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('turfs')
                  .doc(widget.turfId)
                  .collection('slots')
                  .where('date', isEqualTo: selectedDateFormatted)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (snapshot.hasError)
                  return Center(child: Text('Error fetching slots'));

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(child: Text('No slots added yet'));

                final slots = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => editSlot(slot),
                        onLongPress: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Delete Slot"),
                              content: Text("Are you sure you want to delete this slot?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete")),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await deleteSlot(slot.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${slot['fromTime']} To ${slot['toTime']}', style: TextStyle(fontSize: 14)),
                              SizedBox(height: 4),
                              Text('₹ ${slot['payment']}/-', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
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

  Widget dateCard(DateTime date, {bool isSelected = false}) {
    return Container(
      width: 70,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF94FF99) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        '${DateFormat('d\nMMM\nEEE').format(date)}',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
