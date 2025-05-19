import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mental_ease/user/Appointment_ConfirmationScreen.dart';
import '../PaymentService.dart';
import '../serverkey.dart';
import 'Providers/Doctors_Provider/DoctorProfileProvider.dart';
import 'package:http/http.dart' as http;


class OnlineAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String currentUserId;

  const OnlineAppointmentScreen({
    Key? key,
    required this.doctorId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<OnlineAppointmentScreen> createState() => _OnlineAppointmentScreenState();
}

class _OnlineAppointmentScreenState extends State<OnlineAppointmentScreen> {
  String? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  String? dateSelectionError;
  String? timeSelectionError;


  // Global variables to store appointment information
  String? appointmentDay;
  String? appointmentTimeSlot;
  String? appointmentFee;

  final StripePaymentService _paymentService = StripePaymentService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _paymentService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PsychologistProfileViewProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Appointment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            _buildDoctorInfoCard(provider, isSmallScreen),
            SizedBox(height: isSmallScreen ? 24 : 32),

            _buildAppointmentFeeSection(provider),
            SizedBox(height: isSmallScreen ? 16 : 24),

            // Available Dates Section
            _buildDatesSection(provider),
            if (dateSelectionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dateSelectionError!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            SizedBox(height: isSmallScreen ? 24 : 32),

            // Available Times Section (only shows when date is selected)
            if (selectedDate != null) _buildTimesSection(provider),
            if (timeSelectionError != null && selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  timeSelectionError!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            SizedBox(height: isSmallScreen ? 24 : 32),

            // Book Button - now always visible but conditionally enabled
            _buildBookButton(provider, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentFeeSection(PsychologistProfileViewProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Appointment Fee:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              provider.appointmentFee != null && provider.appointmentFee!.isNotEmpty
                  ? '${provider.appointmentFee}\$'
                  : 'Not specified',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCard(PsychologistProfileViewProvider provider, bool isSmallScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: isSmallScreen ? 30 : 40,
              backgroundImage: provider.profileImageUrl != null
                  ? NetworkImage(provider.profileImageUrl!)
                  : null,
              child: provider.profileImageUrl == null
                  ? Icon(Icons.person, size: isSmallScreen ? 30 : 40)
                  : null,
            ),
            SizedBox(width: isSmallScreen ? 16 : 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name ?? 'Dr. Unknown',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    provider.specialization ?? 'Psychologist',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        provider.ratings?.toStringAsFixed(1) ?? '0.0',
                        style: TextStyle(fontSize: 14),
                      ),
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

  Widget _buildDatesSection(PsychologistProfileViewProvider provider) {
    final onlineSlots = provider.onlineTimeSlots ?? {};
    final availableDates = onlineSlots.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        if (availableDates.isEmpty)
          Text(
            'No available dates for online appointments',
            style: TextStyle(color: Colors.grey),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableDates.map((date) {
                final isSelected = date == selectedDate;
                final dateTime = DateTime.parse(date);
                final dayName = DateFormat('EEEE').format(dateTime);
                final dateFormatted = DateFormat('MMM d').format(dateTime);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      selectedTime = null;
                      dateSelectionError = null;
                      timeSelectionError = null;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  Widget _buildTimesSection(PsychologistProfileViewProvider provider) {
    final onlineSlots = provider.onlineTimeSlots ?? {};
    final availableTimes = onlineSlots[selectedDate] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Time Slots',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        if (availableTimes.isEmpty)
          Text(
            'No available times for selected date',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTimes.map((time) {
              final isSelected = time == selectedTime;
              final timeStr = _formatTime(time);

              return ChoiceChip(
                label: Text(timeStr),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedTime = selected ? time : null;
                    timeSelectionError = null;
                  });
                },
                selectedColor: Colors.blue[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBookButton(PsychologistProfileViewProvider provider, bool isSmallScreen) {
    final isButtonEnabled = selectedDate != null && selectedTime != null;

    return Center(
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 50 : 56,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : isButtonEnabled
              ? () => _showConfirmationDialog(provider)
              : () {
            // Show appropriate error messages when button is pressed without selection
            setState(() {
              dateSelectionError = selectedDate == null
                  ? 'Please select a date to continue'
                  : null;
              timeSelectionError = selectedDate != null && selectedTime == null
                  ? 'Please select a time slot to continue'
                  : null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isButtonEnabled ? Colors.blue : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            'Confirm Online Appointment',
            style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(PsychologistProfileViewProvider provider) async {
    appointmentDay = _formatDate(DateTime.parse(selectedDate!));
    appointmentTimeSlot = _formatTime(selectedTime!);
    appointmentFee = provider.appointmentFee ?? 'Not specified';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm and Pay"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Appointment Fee: ${provider.appointmentFee}\$",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Text(
              //   "• 90% will go to the doctor\n"
              //       "• 10% platform fee",
              //   style: TextStyle(fontSize: 14),
              // ),
              SizedBox(height: 20),
              Text(
                "Payment is non-refundable. Please ensure you can attend at the selected time.",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Confirm & Pay Now"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _bookOnlineAppointment(provider);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookOnlineAppointment(PsychologistProfileViewProvider provider) async {
    if (selectedDate == null || selectedTime == null) return;

    setState(() => isLoading = true);

    try {
      final appointmentFee = double.parse(provider.appointmentFee ?? '0');
      final appointmentDateTime = DateTime.parse(selectedDate!); // Parse for formatting

      await _paymentService.processAppointmentPayment(
        doctorStripeId: provider.stripeId ?? '',
        amount: appointmentFee,
        doctorId: widget.doctorId,
        userId: widget.currentUserId,
        selectedDate: selectedDate!, // Pass the string version
        selectedTime: selectedTime!,
        appointmentFee: provider.appointmentFee ?? '0',
      );

      // Send notifications to both parties
      await _sendAppointmentNotificationToBoth(
          psychologistId: widget.doctorId,
          patientId: FirebaseAuth.instance.currentUser!.uid,
          appointmentDate: selectedDate!, // Pass the string version
          appointmentTime: selectedTime!,
          appointmentType: 'Online Appointment',
          context: context
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationScreen(
            doctorName: provider.name ?? 'Dr. Unknown',
            selectedDay: _formatDate(appointmentDateTime), // Use parsed DateTime for formatting
            appointmentTime: _parseTimeToDateTime(selectedTime!),
            appointmentToken: 'ONL-${DateTime.now().millisecondsSinceEpoch}',
            isPhysical: false,
          ),
        ),
      );
    } catch (e) {
      print('Appointment booking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
// Helper method to convert TimeOfDay to DateTime
  DateTime _parseTimeToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

// Helper method to format date
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }


}

Future<void> _sendAppointmentNotificationToBoth({
  required String psychologistId,
  required String patientId,
  required String appointmentDate,  // Changed to String
  required TimeOfDay appointmentTime,
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
  final dateTime = DateTime.parse(appointmentDate);
  final formattedDate = DateFormat('MMMM d, y').format(dateTime);
  final formattedTime = appointmentTime.format(context);

  // Get FCM server token
  final get = get_server_key();
  final String token = await get.server_token();

  // Prepare common notification components
  final commonNotificationData = {
    'appointmentDate': appointmentDate,  // Keep as original string
    'appointmentTime': '${appointmentTime.hour}:${appointmentTime.minute}',
    'appointmentType': appointmentType,
    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  };

  // Send to psychologist
  if (psychologistToken != null && psychologistToken.isNotEmpty) {
    await _sendSingleNotification(
      token: token,
      receiverToken: psychologistToken,
      title: 'New Online Appointment Scheduled',
      body: 'With $patientName on $formattedDate at $formattedTime',
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
      title: 'Online Appointment Confirmed',
      body: 'With $psychologistName on $formattedDate at $formattedTime',
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