import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PhysicalappointmentDetails extends StatelessWidget {
  final String doctorName;
  final String selectedDay;
  final String appointmentToken;
  final bool isPhysical;
  final DateTime? appointmentTime;

  const PhysicalappointmentDetails({
    Key? key,
    required this.doctorName,
    required this.selectedDay,
    required this.appointmentToken,
    this.isPhysical = false,
    this.appointmentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Doctor',
                      value: doctorName,
                    ),
                    Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Day',
                      value: selectedDay,
                    ),
                    Divider(height: 24, thickness: 1),
                    if (appointmentTime != null)
                      Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: DateFormat('h:mm a').format(appointmentTime!),
                          ),
                          Divider(height: 24, thickness: 1),
                        ],
                      ),
                    _buildDetailRow(
                      icon: Icons.confirmation_number,
                      label: 'Token',
                      value: appointmentToken,
                    ),
                    Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.medical_services,
                      label: 'Type',
                      value: isPhysical ? 'Physical Visit' : 'Online Consultation',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Additional Information
            if (isPhysical) ...[
              _buildInfoBox(
                icon: Icons.location_on,
                title: 'Clinic Location',
                content: '123 Medical Center, Health Street\nCity, State 12345',
                color: Colors.blue[50],
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
            _buildInfoBox(
              icon: Icons.info,
              title: 'Important Notes',
              content: isPhysical
                  ? '• Please arrive 15 minutes before your appointment\n• Bring your ID and insurance card\n• Wear a mask in the clinic'
                  : '• Join the meeting 5 minutes early\n• Ensure good internet connection\n• Have your medical reports ready',
              color: Colors.orange[50],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String content,
    required Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}