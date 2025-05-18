import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Appointment_ConfirmationScreen.dart';
import 'PhysicalAppointment_Details.dart';
import 'Providers/Appointment_provider/Physical_Appointment_Provider.dart';


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

    // Check for existing appointments first
    final appointments = await appointmentProvider.getUserAppointments(widget.currentUserId);
    final hasPendingAppointment = appointments.any((appt) =>
    appt['appointmentDay'] == selectedDay &&
        appt['status'] == 'pending' &&
        appt['doctorId'] == widget.doctorId);

    if (hasPendingAppointment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have a pending appointment with this doctor on the selected day')),
      );
      return;
    }

    try {
      final success = await appointmentProvider.bookPhysicalAppointment(
        userId: widget.currentUserId,
        doctorId: widget.doctorId,
        doctorName: doctorName ?? 'Unknown Doctor',
        selectedDay: selectedDay!,
        appointmentType: 'physical',
      );

      if (success) {
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
      }
    } catch (e) {
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