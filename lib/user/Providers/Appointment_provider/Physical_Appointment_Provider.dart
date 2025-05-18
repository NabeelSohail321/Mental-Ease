// providers/appointment_provider.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class AppointmentProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<bool> bookPhysicalAppointment({
    required String userId,
    required String doctorId,
    required String doctorName,
    required String selectedDay,
    required String appointmentType,
  }) async {
    try {
      // Check for existing pending appointments on the same day
      final existingAppointments = await _database
          .child('physical_appointments')
          .orderByChild('userId')
          .equalTo(userId)
          .once();

      if (existingAppointments.snapshot.exists) {
        for (final appointment in existingAppointments.snapshot.children) {
          final data = appointment.value as Map<dynamic, dynamic>;
          if (data['appointmentDay'] == selectedDay &&
              data['status'] == 'pending' &&
              data['doctorId'] == doctorId) {
            return false; // Already has pending appointment with this doctor on this day
          }
        }
      }

      // Proceed with booking
      final appointmentRef = _database.child('physical_appointments').push();
      final token = generateToken();

      await appointmentRef.set({
        'userId': userId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'appointmentDay': selectedDay,
        'appointmentType': appointmentType,
        'status': 'pending',
        'token': token,
        'createdAt': ServerValue.timestamp,
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    try {
      final snapshot = await _database
          .child('physical_appointments')
          .orderByChild('userId')
          .equalTo(userId)
          .once();

      if (!snapshot.snapshot.exists) {
        return [];
      }

      return snapshot.snapshot.children.map((appointment) {
        final data = appointment.value as Map<dynamic, dynamic>;
        return {
          'id': appointment.key,
          'doctorId': data['doctorId'],
          'doctorName': data['doctorName'],
          'appointmentDay': data['appointmentDay'],
          'status': data['status'],
          'token': data['token'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      return [];
    }
  }

  String generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (1000 + (DateTime.now().second % 1000)).toString();
  }
}