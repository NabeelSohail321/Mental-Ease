import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class StripePaymentService {
  static String? stripePublishableKey = dotenv.env['STRIPE_PUBLISH_KEY'];
  static  String? stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY']; // Only for testing - remove in production!

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> initialize() async {
    Stripe.publishableKey = stripePublishableKey!;
    Stripe.merchantIdentifier = 'MentalEase';
    await Stripe.instance.applySettings();
  }

  Future<void> processAppointmentPayment({
    required String doctorStripeId,
    required double amount,
    required String doctorId,
    required String userId,
    required String selectedDate,
    required TimeOfDay selectedTime,
    required String appointmentFee,
  }) async {
    try {
      // 1. Create payment intent directly (for testing only - this exposes your secret key)
      final paymentIntent = await _createDirectPaymentIntent(
        amount: (amount * 100).toInt(), // Convert to cents
        doctorStripeId: doctorStripeId,
      );

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'MentalEase',
        ),
      );

      // 3. Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Save appointment to database
      await _saveAppointmentToDatabase(
        doctorId: doctorId,
        userId: userId,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        paymentId: paymentIntent['id'],
        appointmentFee: appointmentFee,
      );

      // 5. Remove booked time slot
      await _removeBookedTimeSlot(
        doctorId: doctorId,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
      );
    } catch (e) {
      print(e);
      throw Exception('Payment failed: $e');

    }
  }

  // WARNING: This exposes your Stripe secret key - only for testing!
  Future<Map<String, dynamic>> _createDirectPaymentIntent({
    required int amount,
    required String doctorStripeId,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': 'usd',
        'transfer_data[destination]': doctorStripeId,
        'application_fee_amount': (amount * 0.1).toStringAsFixed(0), // 10% platform fee
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to create payment intent: ${response.body}');
    }
  }

  Future<void> _saveAppointmentToDatabase({
    required String doctorId,
    required String userId,
    required String selectedDate,
    required TimeOfDay selectedTime,
    required String paymentId,
    required String appointmentFee,
  }) async {
    final appointmentRef = _dbRef.child('online_Appointments').push();

    await appointmentRef.set({
      'doctorId': doctorId,
      'userId': userId,
      'date': selectedDate,
      'time': _formatTimeForDatabase(selectedTime),
      'paymentId': paymentId,
      'status': 'pending',
      'fee': appointmentFee,
      'createdAt': ServerValue.timestamp,
      'type': 'online',
    });
  }

  Future<void> _removeBookedTimeSlot({
    required String doctorId,
    required String selectedDate,
    required TimeOfDay selectedTime,
  }) async {
    final doctorRef = _dbRef.child('users').child(doctorId).child('onlineTimeSlots');
    final snapshot = await doctorRef.child(selectedDate).get();

    if (snapshot.exists) {
      List<dynamic> timeSlots = List.from(snapshot.value as List);
      timeSlots.remove(_formatTimeForDatabase(selectedTime));

      await doctorRef.child(selectedDate).set(timeSlots);
    }
  }

  String _formatTimeForDatabase(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }
}