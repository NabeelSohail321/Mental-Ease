import 'package:flutter/material.dart';
import 'package:mental_ease/Phycologist/phycologist_online_appointment_history.dart';
import 'package:mental_ease/Phycologist/phycologist_physical_appointment_history.dart';

import '../user/Physical_Appointment_History.dart';
import '../user/online_appointment_history.dart';


class PhycologistAppointmentHistory_Options extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * (isPortrait ? 0.2 : 0.3)),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(screenHeight * 0.03),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: screenHeight * 0.02,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Appointment History Page",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isPortrait ? screenHeight * 0.028 : screenWidth * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight * (isPortrait ? 0.7 : 0.6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionCard(
                  context,
                  icon: Icons.medical_services,
                  title: "Physical Appointments",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return phycologistPhysicalAppointmentHistory();
                    },));

                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildOptionCard(
                  context,
                  icon: Icons.video_call,
                  title: "Online Appointments",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return phycologistOnlineAppointmentHistory();
                    },));
                  },
                ),
                // Add more space at the bottom if needed
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isPortrait ? screenHeight * 0.12 : screenHeight * 0.2,
        ),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        padding: EdgeInsets.symmetric(
          vertical: isPortrait ? screenHeight * 0.02 : screenHeight * 0.04,
          horizontal: screenWidth * 0.05,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Color(0xFF006064),
              size: isPortrait ? screenHeight * 0.04 : screenWidth * 0.04,
            ),
            SizedBox(width: screenWidth * 0.04),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isPortrait ? screenHeight * 0.022 : screenWidth * 0.022,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}