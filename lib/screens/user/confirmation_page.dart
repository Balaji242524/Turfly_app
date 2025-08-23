import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:turfly_new/screens/user/user_turf_details_page.dart';

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
  late Razorpay _razorpay;
  String _selectedPaymentType = "full";

  @override
  void initState() {
    super.initState();
    slotsToConfirm = List<Map<String, dynamic>>.from(widget.selectedSlots);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startRazorpay(int amount, String turfName) {
    var options = {
      'key': '<rzp_test_PUmiajBH0Qjb1c>', // use your own Razorpay key
      'amount': amount * 100,
      'name': turfName.isNotEmpty ? turfName : "Turf Booking",
      'description': _selectedPaymentType == "full" ? 'Full Payment' : 'Advance Payment',
      'prefill': {'contact': '9944031161', 'email': 'turfly24@gmail.com'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching Razorpay, try again.')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Success! Payment ID: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // return to previous page after payment
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed. Reason: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("External wallet selected.")));
  }

  @override
  Widget build(BuildContext context) {
    final turf = widget.turfData;
    int total = slotsToConfirm.fold<int>(0, (p, s) => p + int.tryParse(s['payment']?.toString() ?? '0')!);
    int advance = (total * 0.24).round();
    int payAmount = _selectedPaymentType == "full" ? total : advance;
    int gatewayFee = 75;
    int payable = payAmount + gatewayFee;

    Color highlight = const Color(0xFF68FF70);

    TextStyle rowLabel = const TextStyle(fontWeight: FontWeight.w500, fontSize: 15);
    TextStyle rowValue = const TextStyle(fontWeight: FontWeight.w700, fontSize: 15);

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
        backgroundColor: const Color(0xFF00ED0C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...slotsToConfirm.asMap().entries.map((e) {
                final slot = e.value;
                final idx = e.key;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${_formatSlotDate(slot['date'])} ",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          "${slot['fromTime']} To ${slot['toTime']}",
                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      ...List<String>.from(widget.turfData['sports'] ?? []).map((sport) {
                        final iconPath = 'assets/images/${sport.toLowerCase().replaceAll(' ', '_')}-icon.png';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.7),
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
                        splashRadius: 20,
                        onPressed: () {
                          setState(() { slotsToConfirm.removeAt(idx); });
                        },
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPaymentType = "full"),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedPaymentType == "full" ? highlight : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPaymentType == "full" ? highlight : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Full Payment",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹ $total",
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPaymentType = "advance"),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedPaymentType == "advance" ? highlight : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPaymentType == "advance" ? highlight : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Advance Payment",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹ $advance",
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text("Total Payment:", style: rowLabel),
                  const Spacer(),
                  Text("₹ $payAmount", style: rowValue),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text("Remaining Payment:", style: rowLabel),
                  const Spacer(),
                  Text(
                    _selectedPaymentType == "full" ? "₹ 0" : "₹ ${total - advance}",
                    style: rowValue,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text("Payment gateway Fee + 18% GST tax", style: rowLabel),
                  const Spacer(),
                  Text("₹ $gatewayFee", style: rowValue),
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
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: slotsToConfirm.isNotEmpty
                      ? () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "Upon Confirmation from the owner, the designated payment for your slot will be processed and reflected in the Notification Screen.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                              decoration: BoxDecoration(
                                  color: highlight,
                                  borderRadius: BorderRadius.circular(7)),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                              decoration: BoxDecoration(
                                color: highlight,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                "Ok",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        actionsAlignment: MainAxisAlignment.spaceAround,
                      ),
                    );
                    if (result == true) {
                      // For NATIVE (Android/iOS):
                      _startRazorpay(payable, turf['turfName'] ?? '');
                      // For WEBVIEW, open webview instead (OPTIONAL):
                      // Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      //   PaymentWebView(paymentUrl: "https://yourdomain.com/payment.html")));
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: highlight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSlotDate(String? date) {
    try {
      final d = DateTime.parse(date!);
      return "${d.day} ${_monthName(d.month)}";
    } catch (_) {
      return date ?? '';
    }
  }
    String _monthName(int m) {
    const names = [
      "Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"
    ];
    return m >= 1 && m <= 12 ? names[m - 1] : '';
  }
}
