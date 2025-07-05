import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../serverkey.dart';
import '../model/appointment_Model.dart';

class OnlineAppointmentProvider extends ChangeNotifier {
  List<AppointmentData1> _appointments = [];
  String _filter = 'today';
  static const List<String> _statusFilters = ['today', 'upcoming', 'completed', 'pending'];
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');

  List<AppointmentData1> get filteredAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_filter) {
      case 'today':
        return _appointments.where((appt) {
          final apptDate = DateFormat('yyyy-MM-dd').parse(appt.date);
          return apptDate.isAtSameMomentAs(today);
        }).toList();
      case 'upcoming':
        return _appointments.where((appt) {
          final apptDate = DateFormat('yyyy-MM-dd').parse(appt.date);
          return apptDate.isAfter(today) && appt.status != 'completed';
        }).toList();
      case 'completed':
        return _appointments.where((appt) => appt.status == 'completed').toList();
      case 'pending':
        return _appointments.where((appt) {
          final apptDate = DateFormat('yyyy-MM-dd').parse(appt.date);
          return appt.status == 'pending' && apptDate.isBefore(today);
        }).toList();
      default:
        return _appointments;
    }
  }

  List<String> get statusFilters => _statusFilters;
  String get currentFilter => _filter;

  void setFilter(String filter) {
    if (_statusFilters.contains(filter)) {
      _filter = filter;
      notifyListeners();
    }
  }

  Stream<List<AppointmentData1>> getOnlineAppointmentsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return FirebaseDatabase.instance
        .ref()
        .child('online_Appointments')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .asyncMap((event) async {
      if (event.snapshot.value == null) return [];

      final Map<dynamic, dynamic> appointmentsMap =
      event.snapshot.value as Map<dynamic, dynamic>;

      // Convert to list of appointments
      List<AppointmentData1> appointments = appointmentsMap.entries.map((entry) {
        return AppointmentData1.fromOnlineMap(
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

  Future<void> requestReschedule(String appointmentId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      // First get the patient name from users node
      final userSnapshot = await _usersRef.child(userId).get();
      if (!userSnapshot.exists) throw Exception("User data not found");

      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      final patientName = userData['username'] ?? 'Patient';

      // Update the appointment in database
      await FirebaseDatabase.instance
          .ref()
          .child('online_Appointments')
          .child(appointmentId)
          .update({
        'requested': true,
        'requestedAt': ServerValue.timestamp,
        'patientName': patientName, // Store patient name in appointment
      });

      // Get the appointment details
      final appointment = _appointments.firstWhere(
            (appt) => appt.id == appointmentId,
        orElse: () => AppointmentData1.empty(),
      );

      if (appointment != AppointmentData1.empty()) {
        // Send notification to doctor
        await _sendRescheduleNotification(
          doctorId: appointment.doctorId,
          patientName: patientName, // Use the fetched patient name
          appointmentId: appointmentId,
          date: appointment.date,
          time: appointment.time,
        );
      }
    } catch (e) {
      debugPrint('Error requesting reschedule: $e');
      rethrow;
    }
  }

  Future<void> _sendRescheduleNotification({
    required String doctorId,
    required String patientName,
    required String appointmentId,
    required String date,
    required String time,
  }) async {
    try {
      // Get doctor data
      final doctorSnapshot = await _usersRef.child(doctorId).get();
      if (!doctorSnapshot.exists) return;

      final doctorData = doctorSnapshot.value as Map<dynamic, dynamic>;
      final doctorToken = doctorData['deviceToken'] ?? '';

      if (doctorToken.isEmpty) return;

      // Get FCM server token
      final get = get_server_key();
      final String token = await get.server_token();

      // Prepare notification data
      final title = 'Reschedule Request';
      final body = '$patientName has requested to reschedule their appointment that was on $date at $time';

      await _sendSingleNotification(
        token: token,
        receiverToken: doctorToken,
        title: title,
        body: body,
        data: {
          'type': 'reschedule_request',
          'appointmentId': appointmentId,
          'patientName': patientName,
          'date': date,
          'time': time,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
    } catch (e) {
      debugPrint('Error sending reschedule notification: $e');
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
                'channel_id': 'account_status_channel',
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
                  'category': 'ACCOUNT_STATUS',
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