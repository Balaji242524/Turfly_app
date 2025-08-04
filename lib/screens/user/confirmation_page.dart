import 'package:flutter/material.dart';
import 'package:turfly/screens/user/user_turf_details_page.dart';

class ConfirmationPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSlots;
  final Map<String, dynamic> turfData;
  const ConfirmationPage({
    super.key,
    required this.selectedSlots,
    required this.turfData,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late List<Map<String, dynamic>> slotsToConfirm;

  @override
  void initState() {
    super.initState();
    slotsToConfirm = List<Map<String, dynamic>>.from(widget.selectedSlots);
  }

  @override
  Widget build(BuildContext context) {
    final turf = widget.turfData;
    // Calculate combined total
    int total = slotsToConfirm.fold<int>(0, (p, s) => p + int.tryParse(s['payment']?.toString() ?? '0')!);
    int advance = (total * 0.24).round(); // sample: 24% as in your screenshot
    int gatewayFee = ((total + 0.18 * total) - total).round(); // sample, 18% GST
    int payable = total + 75; // Use fixed 75 for fee per screenshot, or use gatewayFee

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmation',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        backgroundColor: const Color(0xFF00ED0C), // Match your green
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slot list
              ...slotsToConfirm.asMap().entries.map((e) {
                final slot = e.value;
                final idx = e.key;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${slot['date']} ${slot['fromTime']} To ${slot['toTime']} ",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      ...List<String>.from(widget.turfData['sports'] ?? []).map((sport) {
                        final iconPath = 'assets/images/${sport.toLowerCase().replaceAll(' ', '_')}-icon.png';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Image.asset(
                            iconPath,
                            width: 22,
                            height: 22,
                            errorBuilder: (_, __, ___) => const SizedBox(width: 22, height: 22),
                          ),
                        );
                      }),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 22),
                        onPressed: () {
                          setState(() {
                            slotsToConfirm.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              if (slotsToConfirm.isEmpty)
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: const Text(
                    'No slots selected.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              // View details
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserTurfDetailsPage(
                          turfData: turf,
                          userData: {},
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      "View Details of Turf",
                      style: TextStyle(
                        color: Colors.green[700],
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Payment section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Full Payment",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "₹ $total",
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Advance Payment",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "₹ $advance",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Total and payment summary
              Row(
                children: [
                  const Text(
                    "Total Payment:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text("₹ $total", style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Text(
                    "Remaining Payment:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Text("₹ 0", style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Text(
                    "Payment gateway Fee + 18% GST tax",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Text("₹ 75", style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "Pay Now",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "₹ $payable",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: slotsToConfirm.isNotEmpty ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
