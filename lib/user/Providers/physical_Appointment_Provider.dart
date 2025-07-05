import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../serverkey.dart';
import '../model/appointment_Model.dart';

class AppointmentProvider1 extends ChangeNotifier {
  List<AppointmentData> _appointments = [];
  String _filter = 'pending';
  static const List<String> _statusFilters = ['pending', 'completed', 'canceled'];
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  List<AppointmentData> get filteredAppointments => _appointments
      .where((appt) => appt.status == _filter)
      .toList();

  List<String> get statusFilters => _statusFilters;
  String get currentFilter => _filter;

  void setFilter(String filter) {
    if (_statusFilters.contains(filter)) {
      _filter = filter;
      notifyListeners();
    }
  }

  Stream<List<AppointmentData>> getPhysicalAppointmentsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return FirebaseDatabase.instance
        .ref()
        .child('physical_appointments')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .asyncMap((event) async {
      if (event.snapshot.value == null) return [];

      final Map<dynamic, dynamic> appointmentsMap =
      event.snapshot.value as Map<dynamic, dynamic>;

      // Convert to list of appointments
      List<AppointmentData> appointments = appointmentsMap.entries.map((entry) {
        return AppointmentData.fromMap(
            entry.value as Map<dynamic, dynamic>, entry.key as String);
      }).toList();

      // Fetch doctor names for each appointment
      for (var appointment in appointments) {
        if (appointment.doctorId.isNotEmpty) {
          try {
            final doctorSnapshot = await _usersRef.child(appointment.doctorId).get();
            if (doctorSnapshot.exists) {
              final doctorData = doctorSnapshot.value as Map<dynamic, dynamic>;
              appointment.doctorName = doctorData['username'] ?? 'Unknown Doctor';
            }
          } catch (e) {
            debugPrint('Error fetching doctor name: $e');
          }
        }
      }

      _appointments = appointments;
      return _appointments;
    });
  }

  Future<void> updateAppointmentStatus(
      String appointmentId,
      String newStatus,
      BuildContext context,
      )
  async {
    try {
      // First get the appointment data
      final appointmentIndex = _appointments.indexWhere((appt) => appt.id == appointmentId);
      if (appointmentIndex == -1) return;

      final appointment = _appointments[appointmentIndex];
      final oldStatus = appointment.status;

      // Update the status in database
      await FirebaseDatabase.instance
          .ref()
          .child('physical_appointments')
          .child(appointmentId)
          .update({'status': newStatus.toLowerCase()});

      // Update local state
      _appointments[appointmentIndex] = appointment.copyWith(status: newStatus);
      notifyListeners();

      // Send notifications if status changed
      if (oldStatus != newStatus) {
        await _sendStatusChangeNotifications(
          appointment: appointment,
          newStatus: newStatus,
          context: context,
        );
      }
    } catch (error) {
      throw Exception('Failed to update appointment: $error');
    }
  }

  Future<void> _sendStatusChangeNotifications({
    required AppointmentData appointment,
    required String newStatus,
    required BuildContext context,
  }) async {
    try {
      // Get both users' data in parallel
      final psychologistSnapshot = await _usersRef.child(appointment.doctorId).get();
      final patientSnapshot = await _usersRef.child(appointment.userId).get();

      if (!psychologistSnapshot.exists || !patientSnapshot.exists) return;

      final psychologistData = psychologistSnapshot.value as Map<dynamic, dynamic>;
      final patientData = patientSnapshot.value as Map<dynamic, dynamic>;

      final psychologistName = psychologistData['username'] ?? 'Doctor';
      final patientName = patientData['username'] ?? 'Patient';
      final psychologistToken = psychologistData['deviceToken'] ?? '';
      final patientToken = patientData['deviceToken'] ?? '';

      // Get FCM server token
      final get = get_server_key();
      final String token = await get.server_token();

      // Prepare common notification data
      final commonNotificationData = {
        'appointmentId': appointment.id,
        'appointmentDate': appointment.appointmentDay,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'status': newStatus,
      };

      // Notification titles and bodies based on status
      String statusMessage;
      switch (newStatus) {
        case 'completed':
          statusMessage = 'completed';
          break;
        case 'canceled':
          statusMessage = 'canceled';
          break;
        default:
          statusMessage = 'updated';
      }

      // Send to psychologist
      if (psychologistToken.isNotEmpty) {
        await _sendSingleNotification(
          token: token,
          receiverToken: psychologistToken,
          title: 'Appointment $statusMessage',
          body: 'Physical Appointment with $patientName has been $statusMessage',
          data: {
            ...commonNotificationData,
            'type': 'appointment_status_changed_doctor',
            'patientId': appointment.userId,
            'patientName': patientName,
          },
        );
      }

      // Send to patient
      if (patientToken.isNotEmpty) {
        await _sendSingleNotification(
          token: token,
          receiverToken: patientToken,
          title: 'Appointment $statusMessage',
          body: 'Your Physical appointment with Dr $psychologistName has been $statusMessage',
          data: {
            ...commonNotificationData,
            'type': 'appointment_status_changed_patient',
            'doctorId': appointment.doctorId,
            'doctorName': psychologistName,
          },
        );
      }
    } catch (e) {
      debugPrint('Error sending notifications: $e');
    }
  }

  Future<void> _sendSingleNotification({
    required String token,
    required String receiverToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/installmentapp-1cf69/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'token': receiverToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data,
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

      if (response.statusCode != 200) {
        debugPrint('Failed to send notification: ${response.body}');
      } else {
        debugPrint('Notification sent successfully');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  String formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}