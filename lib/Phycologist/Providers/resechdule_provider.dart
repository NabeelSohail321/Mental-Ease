import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../serverkey.dart';

class RescheduleProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> _rescheduleRequests = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get rescheduleRequests => _rescheduleRequests;
  bool get isLoading => _isLoading;


  Future<void> fetchRescheduleRequests() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final snapshot = await _dbRef.child('online_Appointments')
          .orderByChild('doctorId')
          .equalTo(currentUserId)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _rescheduleRequests = data.entries
            .where((entry) =>
        entry.value['requested'] == true &&
            entry.value['status'] == 'pending')
            .map((entry) {
          final appointment = Map<String, dynamic>.from(entry.value);
          appointment['id'] = entry.key;
          return appointment;
        }).toList();

        for (var request in _rescheduleRequests) {
          final patientId = request['userId'];
          final patientSnapshot = await _usersRef.child(patientId).get();
          if (patientSnapshot.exists) {
            final patientData = Map<String, dynamic>.from(patientSnapshot.value as Map);
            request['patientName'] = patientData['username'] ?? 'Patient';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching reschedule requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentTime({
    required String appointmentId,
    required String newDate,
    required String newTime,
    required String patientId,
    required String patientName,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Check if the new date/time is in the future
      final now = DateTime.now();
      final appointmentDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$newDate $newTime');
      if (appointmentDateTime.isBefore(now)) {
        throw Exception('Selected date/time must be in the future');
      }

      // Get doctor's existing appointments
      final appointmentsSnapshot = await _dbRef.child('online_Appointments')
          .orderByChild('doctorId')
          .equalTo(currentUserId)
          .get();

      if (appointmentsSnapshot.exists) {
        final appointments = Map<String, dynamic>.from(appointmentsSnapshot.value as Map);

        // Check all appointments to ensure new time is at least 3 hours apart
        for (var entry in appointments.entries) {
          final existingAppointment = entry.value;
          if (existingAppointment['date'] != null && existingAppointment['time'] != null) {
            try {
              final existingDateTime = DateFormat('yyyy-MM-dd HH:mm')
                  .parse('${existingAppointment['date']} ${existingAppointment['time']}');

              // Skip the appointment we're currently rescheduling
              if (entry.key == appointmentId) continue;

              // Calculate time difference
              final timeDifference = appointmentDateTime.difference(existingDateTime).abs();

              if (timeDifference.inHours < 3) {
                throw Exception('New appointment time must be at least 3 hours apart from existing appointments');
              }
            } catch (e) {
              debugPrint('Error parsing existing appointment time: $e');
            }
          }
        }
      }

      // Get doctor's available slots
      final doctorSnapshot = await _usersRef.child(currentUserId).get();
      if (!doctorSnapshot.exists) throw Exception('Doctor not found');

      final doctorData = Map<String, dynamic>.from(doctorSnapshot.value as Map);
      final onlineSlots = doctorData['onlineTimeSlots'] as Map<dynamic, dynamic>? ?? {};

      // Check if the new date is after the latest available date in onlineTimeSlots
      final availableDates = onlineSlots.keys.where((key) => key is String).map((key) => key.toString()).toList();
      // print(availableDates);
      // if (availableDates.isEmpty) {
      //   throw Exception('No available slots found');
      // }

      // Parse all available dates and find the latest one
      final latestAvailableDate = availableDates.map((dateStr) {
        try {
          return DateFormat('yyyy-MM-dd').parse(dateStr);
        } catch (e) {
          return DateTime(0); // Return minimal date if parsing fails
        }
      }).reduce((a, b) => a.isAfter(b) ? a : b);
      print(latestAvailableDate);

      // Parse the new appointment date
      final newAppointmentDate = DateFormat('yyyy-MM-dd').parse(newDate);

      // Check if the new date is after the latest available date
      if (newAppointmentDate.isBefore(latestAvailableDate)||newAppointmentDate.isAtSameMomentAs(latestAvailableDate)) {
        throw Exception('Selected date must be after ${DateFormat('yyyy-MM-dd').format(latestAvailableDate)}');
      }

      // Format the date key to match exactly how it's stored in Firebase
      final formattedDate = DateFormat('yyyy-MM-dd').format(appointmentDateTime);

      // Find the correct date key (case sensitive)
      final dateKey = onlineSlots.keys.firstWhere(
            (key) => key.toString() == formattedDate,
        orElse: () => '',
      );

      // if (dateKey == '') {
      //   throw Exception('No available slots for selected date');
      // }

      final slotsForDate = (onlineSlots[dateKey] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

      // Format the time to match exactly how it's stored (e.g., "09:00" vs "9:0")
      final formattedTime = _formatTimeForComparison(newTime);

      // if (!slotsForDate.any((slot) => _formatTimeForComparison(slot) == formattedTime)) {
      //   throw Exception('Selected time slot is not available for booking');
      // }

      // Update the appointment
      await _dbRef.child('online_Appointments').child(appointmentId).update({
        'date': newDate,
        'time': newTime,
        'requested': false,
      });

      // Send notification
      await _sendRescheduleNotification(
        appointmentId: appointmentId,
        doctorId: currentUserId,
        doctorName: doctorData['username'] ?? 'Doctor',
        patientId: patientId,
        patientName: patientName,
        newDate: newDate,
        newTime: newTime,
      );

      await fetchRescheduleRequests();
    } catch (e) {
      debugPrint('Error updating appointment time: $e');
      rethrow;
    }
  }

  String _formatTimeForComparison(String time) {
    // Convert time to consistent format (e.g., "9:0" -> "09:00")
    final parts = time.split(':');
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _sendRescheduleNotification({
    required String appointmentId,
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String newDate,
    required String newTime,
  }) async {
    try {
      final patientSnapshot = await _usersRef.child(patientId).get();
      if (!patientSnapshot.exists) return;

      final patientData = Map<String, dynamic>.from(patientSnapshot.value as Map);
      final patientToken = patientData['deviceToken'] ?? '';
      if (patientToken.isEmpty) return;

      final get = get_server_key();
      final String token = await get.server_token();

      final notificationData = {
        'appointmentId': appointmentId,
        'date': newDate,
        'time': newTime,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'status': 'rescheduled',
        'type': 'appointment_rescheduled',
        'doctorId': doctorId,
        'doctorName': doctorName,
      };

      await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/installmentapp-1cf69/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'token': patientToken,
            'notification': {
              'title': 'Appointment Rescheduled',
              'body': 'Your appointment with Dr. $doctorName has been rescheduled to $newDate at $newTime',
            },
            'data': notificationData,
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'appointments_channel',
                'sound': 'default',
                'icon': '@mipmap/ic_notification',
                'color': '#006064',
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'badge': 1,
                  'category': 'APPOINTMENT',
                  'mutable-content': 1
                }
              }
            }
          }
        }),
      );
    } catch (e) {
      debugPrint('Error sending reschedule notification: $e');
    }
  }

  String formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}