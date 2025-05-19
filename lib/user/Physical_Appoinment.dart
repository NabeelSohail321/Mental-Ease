import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

import '../serverkey.dart';
import 'Appointment_ConfirmationScreen.dart';
import 'PhysicalAppointment_Details.dart';
import 'Providers/Appointment_provider/Physical_Appointment_Provider.dart';

import 'package:http/http.dart' as http;


class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String currentUserId;

  const DoctorDetailsScreen({
    Key? key,
    required this.doctorId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  List<String> availableDays = [];
  String? selectedDay;
  String? clinicTiming;
  String? appointmentFee;
  String? doctorName;
  String? doctorSpecialization;
  bool isLoading = true;
  String? ratings;

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    setState(() => isLoading = true);
    final dbRef = FirebaseDatabase.instance.ref();

    try {
      final snapshot = await dbRef.child('users/${widget.doctorId}').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final String rawWeekDays = data['weekDays'] ?? '';

        setState(() {
          availableDays = rawWeekDays
              .split(',')
              .map((day) => day.trim())
              .where((day) => day.isNotEmpty)
              .toList();
          clinicTiming = data['clinicTiming'] ?? 'Not specified';
          appointmentFee = data['appointmentFee'] ?? 'Not specified';
          doctorName = data['name'] ?? 'Unknown Doctor';
          doctorSpecialization = data['specialization'] ?? 'General Practitioner';
          isLoading = false;
          ratings = data['ratings'] ?? '0.0';
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor details not found')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctor details: $e')),
      );
    }
  }

  // In your DoctorDetailsScreen
  Future<void> _bookPhysicalAppointment() async {
    if (selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available day first')),
      );
      return;
    }

    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Check for existing appointments first
      final appointments = await appointmentProvider.getUserAppointments(widget.currentUserId);
      final hasPendingAppointment = appointments.any((appt) =>
      appt['appointmentDay'] == selectedDay &&
          appt['status'] == 'pending' &&
          appt['doctorId'] == widget.doctorId);

      if (hasPendingAppointment) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already have a pending appointment with this doctor on the selected day')),
        );
        return;
      }

      final success = await appointmentProvider.bookPhysicalAppointment(
        userId: widget.currentUserId,
        doctorId: widget.doctorId,
        doctorName: doctorName ?? 'Unknown Doctor',
        selectedDay: selectedDay!,
        appointmentType: 'physical',
      );

      if (success) {
        await _sendAppointmentNotificationToBoth(
            psychologistId: widget.doctorId,
            patientId: FirebaseAuth.instance.currentUser!.uid,
            appointmentDate: selectedDay!,
            appointmentType: "Physical",
            context: context
        );

        Navigator.pop(context); // Dismiss loading dialog before navigation

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentConfirmationScreen(
              doctorName: doctorName ?? 'Unknown Doctor',
              selectedDay: selectedDay!,
              appointmentToken: appointmentProvider.generateToken(),
              isPhysical: true,
            ),
          ),
        );
      } else {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book appointment')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile Section
            _buildDoctorProfile(screenWidth),
            SizedBox(height: screenHeight * 0.03),

            // Clinic Information Section
            _buildClinicInfoSection(),
            SizedBox(height: screenHeight * 0.03),

            // Available Days Section
            _buildAvailableDaysSection(),
            SizedBox(height: screenHeight * 0.04),

            // Appointment Buttons
            _buildAppointmentButtons(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfile(double screenWidth) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.1,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: screenWidth * 0.1, color: Colors.blue),
            ),
            SizedBox(width: screenWidth * 0.05),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName ?? 'Unknown Doctor',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    doctorSpecialization ?? 'General Practitioner',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(ratings!,
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.access_time, 'Timing', clinicTiming ?? 'Not specified'),
                SizedBox(height: 12),
                _buildInfoRow(Icons.attach_money, 'Fee', appointmentFee ?? 'Not specified'),
                SizedBox(height: 12),
                _buildInfoRow(Icons.location_on, 'Address', '123 Health St, Medical City'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 10),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildAvailableDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Days',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        if (availableDays.isEmpty)
          const Text('No available days specified')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableDays.map((day) {
              return ChoiceChip(
                label: Text(day),
                selected: selectedDay == day,
                onSelected: (selected) {
                  setState(() => selectedDay = selected ? day : null);
                },
                selectedColor: Colors.blue[200],
                labelStyle: TextStyle(
                  color: selectedDay == day ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildAppointmentButtons(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: _bookPhysicalAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Book Physical Appointment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: OutlinedButton(
              onPressed: () {
                if (selectedDay != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhysicalappointmentDetails(
                        doctorName: doctorName ?? 'Unknown Doctor',
                        selectedDay: selectedDay!,
                        appointmentToken: Provider.of<AppointmentProvider>(context, listen: false).generateToken(),
                        isPhysical: true,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a day first')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.blue),
              ),
              child: const Text(
                'View Appointment Details',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _sendAppointmentNotificationToBoth({
  required String psychologistId,
  required String patientId,
  required String appointmentDate,  // Changed to String
  // required TimeOfDay appointmentTime,
  required String appointmentType,
  required BuildContext context
}) async {
  final _usersRef = FirebaseDatabase.instance.ref('users');

  // Get both users' data in parallel
  final psychologistSnapshot = await _usersRef.child(psychologistId).get();
  final patientSnapshot = await _usersRef.child(patientId).get();

  if (!psychologistSnapshot.exists || !patientSnapshot.exists) return;

  final psychologistData = psychologistSnapshot.value as Map<dynamic, dynamic>;
  final patientData = patientSnapshot.value as Map<dynamic, dynamic>;

  final psychologistName = psychologistData['username'];
  final patientName = patientData['username'];
  final psychologistToken = psychologistData['deviceToken'];
  final patientToken = patientData['deviceToken'];

  // Parse the date string to DateTime for formatting
  // final dateTime = DateTime.parse(appointmentDate);
  // final formattedDate = DateFormat('MMMM d, y').format(dateTime);
  // final formattedTime = appointmentTime.format(context);

  // Get FCM server token
  final get = get_server_key();
  final String token = await get.server_token();

  // Prepare common notification components
  final commonNotificationData = {
    'appointmentDate': appointmentDate,  // Keep as original string
    // 'appointmentTime': '${appointmentTime.hour}:${appointmentTime.minute}',
    'appointmentType': appointmentType,
    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  };

  // Send to psychologist
  if (psychologistToken != null && psychologistToken.isNotEmpty) {
    await _sendSingleNotification(
      token: token,
      receiverToken: psychologistToken,
      title: 'New Physical Appointment Scheduled',
      body: 'With $patientName on $appointmentDate' ,
      data: {
        ...commonNotificationData,
        'type': 'appointment_scheduled_psychologist',
        'patientId': patientId,
        'patientName': patientName,
      },
    );
  }

  // Send to patient
  if (patientToken != null && patientToken.isNotEmpty) {
    await _sendSingleNotification(
      token: token,
      receiverToken: patientToken,
      title: 'Physical Appointment Confirmed',
      body: 'With $psychologistName on $appointmentDate ',
      data: {
        ...commonNotificationData,
        'type': 'appointment_scheduled_patient',
        'psychologistId': psychologistId,
        'psychologistName': psychologistName,
      },
    );
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
      print('Failed to send notification: ${response.body}');
    }
    else{
      print('Notification sent');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}