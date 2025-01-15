import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mychat/payment_controller.dart/payment_controller.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final payentCOntroller = Get.put(PaymentController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(onPressed: () => payentCOntroller.makePayment(amount: '100', currency: 'USD' ), child: Text("Payment")),
          ),
        ],
      ),
    );
  }
}
