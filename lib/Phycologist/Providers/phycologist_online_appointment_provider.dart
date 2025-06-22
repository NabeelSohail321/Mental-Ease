import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../serverkey.dart';
import '../../user/model/appointment_Model.dart';

class phycologistOnlineAppointmentProvider extends ChangeNotifier {
  List<AppointmentData1> _appointments = [];
  String _filter = 'today';
  static const List<String> _statusFilters = ['today', 'upcoming', 'completed'];
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
        .orderByChild('doctorId')
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

      // Fetch doctor and patient names for each appointment
      for (var appointment in appointments) {
        // Fetch doctor name
        if (appointment.doctorId.isNotEmpty) {
          try {
            final doctorSnapshot = await _usersRef.child(appointment.doctorId).get();
            if (doctorSnapshot.exists) {
              final doctorData = doctorSnapshot.value as Map<dynamic, dynamic>;
              appointment.doctorName = doctorData['name'] ?? 'Unknown Doctor';
            }
          } catch (e) {
            debugPrint('Error fetching doctor name: $e');
          }
        }

        // Fetch patient name
        if (appointment.userId.isNotEmpty) {
          try {
            final patientSnapshot = await _usersRef.child(appointment.userId).get();
            if (patientSnapshot.exists) {
              final patientData = patientSnapshot.value as Map<dynamic, dynamic>;
              appointment.patientName = patientData['username'] ?? 'Unknown Patient';
            }
          } catch (e) {
            debugPrint('Error fetching patient name: $e');
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
      String page,
      )
  async {
    try {
      print(appointmentId);
      // First get the appointment data
      final appointmentIndex = _appointments.indexWhere((appt) => appt.id == appointmentId);

      // For pages other than videocall, check if appointment exists locally
      if (page != 'videocall') {
        if (appointmentIndex == -1) {
          debugPrint('Appointment not found in local state');
          return;
        }
      }

      AppointmentData1? appointment;
      String? oldStatus;

      if (appointmentIndex != -1) {
        appointment = _appointments[appointmentIndex];
        oldStatus = appointment.status;
        debugPrint('Updating status from $oldStatus to $newStatus');
      } else {
        debugPrint('Updating status to $newStatus (appointment not in local state)');
      }

      // Update the status in database
      final databaseRef = FirebaseDatabase.instance
          .ref()
          .child('online_Appointments')
          .child(appointmentId);

      // Create update data
      final updateData = {
        'status': newStatus.toLowerCase(),
        'updatedAt': ServerValue.timestamp,
      };

      // Perform the update
      await databaseRef.update(updateData);
      debugPrint('Database update successful');

      // Verify the update by reading back the value
      final snapshot = await databaseRef.child('status').get();

      if (snapshot.exists && snapshot.value.toString().toLowerCase() == newStatus.toLowerCase()) {
        debugPrint('Status verified in database');

        // Update local state only if not on videocall page
        if (page != 'videocall' && appointmentIndex != -1) {
          _appointments[appointmentIndex] = appointment!.copyWith(status: newStatus);
          notifyListeners();
        }

        // Send notifications if status changed (fetch appointment data if not in local state)
        if (oldStatus == null || oldStatus != newStatus) {
          final appointmentToNotify = appointment ?? await _fetchAppointmentFromDatabase(appointmentId);
          if (appointmentToNotify != null) {
            await _sendStatusChangeNotifications(
              appointment: appointmentToNotify,
              newStatus: newStatus,
              context: context,
            );
          }
        }
      } else {
        throw Exception('Status update verification failed');
      }
    } catch (error) {
      debugPrint('Failed to update appointment: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update appointment: ${error.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<AppointmentData1?> _fetchAppointmentFromDatabase(String appointmentId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('online_Appointments')
          .child(appointmentId)
          .get();

      if (snapshot.exists) {
        return AppointmentData1.fromOnlineMap(
          Map<String, dynamic>.from(snapshot.value as Map),
          snapshot.key!,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching appointment: $e');
      return null;
    }
  }
  Future<void> _sendStatusChangeNotifications({
    required AppointmentData1 appointment,
    required String newStatus,
    required BuildContext context,
  })
  async {
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
        'appointmentDate': appointment.date+appointment.time,
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
  })
  async {
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