import 'package:flutter/material.dart';
import 'package:mental_ease/Phycologist/phycologist_video_call.dart';
import 'package:mental_ease/user/Providers/online_appointment_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../user/model/appointment_Model.dart';
import 'Providers/phycologist_online_appointment_provider.dart';


class phycologistOnlineAppointmentHistory extends StatelessWidget {
  const phycologistOnlineAppointmentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => phycologistOnlineAppointmentProvider(),
      child: Scaffold(
        body: SafeArea(
          child: _AppointmentHistoryBody(),
        ),
      ),
    );
  }
}

class _AppointmentHistoryBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      children: [
        _buildAppBar(context, screenHeight, screenWidth, isPortrait),
        Expanded(
          child: _buildAppointmentList(context, screenHeight, screenWidth, isPortrait),
        ),
      ],
    );
  }


  // Add this helper method to check if appointment time is within the next 3 hours
  bool _isTimeWithin3HoursAfter(String appointmentTime) {
    try {
      final now = DateTime.now();
      final timeFormat = DateFormat('HH:mm');
      final parsedTime = timeFormat.parse(appointmentTime);

      // Create today's DateTime for the appointment time
      final appointmentDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      final threeHoursAfterAppointment = appointmentDateTime.add(Duration(hours: 3));

      return now.isAfter(appointmentDateTime) &&
          now.isBefore(threeHoursAfterAppointment);
    } catch (e) {
      return false;
    }
  }

  Widget _buildAppBar(BuildContext context, double screenHeight, double screenWidth, bool isPortrait) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(screenHeight * 0.02),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: isPortrait ? screenHeight * 0.03 : screenWidth * 0.03),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Online Appointments",
                          style: TextStyle(
                            fontSize: isPortrait ? screenHeight * 0.025 : screenWidth * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: _buildStatusFilterChips(context, screenWidth, isPortrait),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChips(BuildContext context, double screenWidth, bool isPortrait) {
    final provider = Provider.of<phycologistOnlineAppointmentProvider>(context);

    return SizedBox(
      height: isPortrait ? screenWidth * 0.12 : screenWidth * 0.08,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        children: provider.statusFilters.map((filter) {
          String displayText;
          switch (filter) {
            case 'today':
              displayText = "Today";
              break;
            case 'upcoming':
              displayText = "Upcoming";
              break;
            case 'completed':
              displayText = "Completed";
              break;
            default:
              displayText = filter;
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            child: FilterChip(
              label: Text(
                displayText,
                style: TextStyle(
                  fontSize: isPortrait ? screenWidth * 0.035 : screenWidth * 0.025,
                  fontWeight: FontWeight.bold,
                  color: provider.currentFilter == filter ? Colors.white : Color(0xFF006064),
                ),
              ),
              selected: provider.currentFilter == filter,
              selectedColor: Color(0xFF006064),
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: Color(0xFF006064)),
              ),
              onSelected: (selected) {
                if (selected) {
                  provider.setFilter(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilterDropdown(BuildContext context, double screenWidth, bool isPortrait) {
    final provider = Provider.of<phycologistOnlineAppointmentProvider>(context);

    return Container(
      width: isPortrait ? screenWidth * 0.8 : screenWidth * 0.6,
      padding: EdgeInsets.symmetric(
        horizontal: isPortrait ? screenWidth * 0.04 : screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.currentFilter,
          icon: Icon(Icons.arrow_drop_down, size: isPortrait ? screenWidth * 0.06 : screenWidth * 0.04),
          iconSize: isPortrait ? screenWidth * 0.06 : screenWidth * 0.04,
          elevation: 16,
          style: TextStyle(
            color: const Color(0xFF006064),
            fontSize: isPortrait ? screenWidth * 0.04 : screenWidth * 0.03,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              provider.setFilter(newValue);
            }
          },
          items: provider.statusFilters
              .map<DropdownMenuItem<String>>((String value) {
            String displayText;
            switch (value) {
              case 'today':
                displayText = "Today's Appointments";
                break;
              case 'upcoming':
                displayText = "Upcoming Appointments";
                break;
              case 'completed':
                displayText = "Completed Appointments";
                break;
              default:
                displayText = value;
            }
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                displayText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isPortrait ? screenWidth * 0.035 : screenWidth * 0.025,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context, double screenHeight, double screenWidth, bool isPortrait) {
    final provider = Provider.of<phycologistOnlineAppointmentProvider>(context);

    return StreamBuilder<List<AppointmentData1>>(
      stream: provider.getOnlineAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006064)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading appointments",
              style: TextStyle(
                color: Colors.red,
                fontSize: isPortrait ? screenHeight * 0.02 : screenWidth * 0.02,
              ),
            ),
          );
        }

        if (provider.filteredAppointments.isEmpty) {
          return Center(
            child: Text(
              "No ${provider.currentFilter.replaceAll('_', ' ')} appointments",
              style: TextStyle(
                color: Colors.grey,
                fontSize: isPortrait ? screenHeight * 0.02 : screenWidth * 0.02,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          itemCount: provider.filteredAppointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(
                context, provider.filteredAppointments[index], screenHeight, screenWidth, isPortrait);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentData1 appointment,
      double screenHeight, double screenWidth, bool isPortrait) {
    final provider = Provider.of<phycologistOnlineAppointmentProvider>(context, listen: false);
    Color statusColor;

    switch (appointment.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'canceled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    final isToday = _isAppointmentToday(appointment.date);
    final isWithinTimeWindow = _isTimeWithin3HoursAfter(appointment.time);

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
      ),
      elevation: 3,
      child: InkWell(
        onDoubleTap: (isToday &&
            appointment.status == 'pending' &&
            isWithinTimeWindow)
            ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PhycologistVideoCall(
              'Mental Ease',
              "broadcaster",
              appointment.doctorId,
              appointment.id,
            );
          }));
        }
            : (){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appointment is Marked as completed or Appointment time is not arrived yet")));
        },
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        onTap: () => _showAppointmentDetails(context, appointment, screenHeight, screenWidth, isPortrait),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Patient ${appointment.patientName}",
                      style: TextStyle(
                        fontSize: isPortrait ? screenHeight * 0.022 : screenWidth * 0.022,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006064),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isPortrait ? screenHeight * 0.016 : screenWidth * 0.016,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildDetailRow(
                  Icons.calendar_today,
                  _formatAppointmentDate(appointment.date),
                  screenHeight,
                  screenWidth,
                  isPortrait),
              _buildDetailRow(
                  Icons.access_time,
                  "Time: ${appointment.time}",
                  screenHeight,
                  screenWidth,
                  isPortrait),
              _buildDetailRow(
                  Icons.attach_money,
                  "Fee: Rs. ${appointment.fee}",
                  screenHeight,
                  screenWidth,
                  isPortrait),
              _buildDetailRow(
                  Icons.video_call,
                  "Type: ${appointment.type}",
                  screenHeight,
                  screenWidth,
                  isPortrait),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAppointmentDate(String date) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('EEEE, MMMM d, y').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _buildDetailRow(IconData icon, String text,
      double screenHeight, double screenWidth, bool isPortrait) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      child: Row(
        children: [
          Icon(
            icon,
            size: isPortrait ? screenHeight * 0.025 : screenWidth * 0.025,
            color: Colors.grey,
          ),
          SizedBox(width: screenWidth * 0.03),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isPortrait ? screenHeight * 0.018 : screenWidth * 0.018,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, AppointmentData1 appointment,
      double screenHeight, double screenWidth, bool isPortrait) {
    final provider = Provider.of<phycologistOnlineAppointmentProvider>(context, listen: false);

    // Check if the appointment is today and pending
    final isToday = _isAppointmentToday(appointment.date);
    final showCompleteButton = isToday && appointment.status.toLowerCase() == "pending";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.03),
          ),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appointment Details",
                    style: TextStyle(
                      fontSize: isPortrait ? screenHeight * 0.025 : screenWidth * 0.025,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006064),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDetailText("Patient:", appointment.patientName as String, screenHeight, screenWidth, isPortrait),
                  _buildDetailText("Date:", _formatAppointmentDate(appointment.date), screenHeight, screenWidth, isPortrait),
                  _buildDetailText("Time:", appointment.time, screenHeight, screenWidth, isPortrait),
                  _buildDetailText("Status:", appointment.status, screenHeight, screenWidth, isPortrait),
                  _buildDetailText("Type:", appointment.type, screenHeight, screenWidth, isPortrait),
                  _buildDetailText("Fee:", "Rs. ${appointment.fee}", screenHeight, screenWidth, isPortrait),
                  _buildDetailText("Booked at:",
                      provider.formatTimestamp(appointment.createdAt),
                      screenHeight, screenWidth, isPortrait),
                  SizedBox(height: screenHeight * 0.03),
                  if (showCompleteButton) // Only show for today's pending appointments
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenHeight * 0.02),
                            side: BorderSide(color: Colors.green),
                          ),
                          backgroundColor: Colors.green[50],
                        ),
                        onPressed: () async {
                          // Show confirmation dialog wrapped in StatefulBuilder
                          await showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) => AlertDialog(
                                title: Text("Confirm Completion"),
                                content: Text("Are you sure you want to mark this appointment as complete?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider.updateAppointmentStatus(appointment.id, "completed", context,'');
                                      Navigator.pop(context); // Close confirmation dialog
                                      // Functionality to mark as complete would go here
                                    },
                                    child: Text(
                                      "OK",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Mark as Complete",
                          style: TextStyle(
                            fontSize: isPortrait ? screenHeight * 0.018 : screenWidth * 0.018,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (showCompleteButton)
                    SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenHeight * 0.02),
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: isPortrait ? screenHeight * 0.018 : screenWidth * 0.018,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Helper function to check if appointment is today
  bool _isAppointmentToday(String appointmentDate) {
    try {
      final today = DateTime.now();
      final appointmentDateTime = DateFormat('yyyy-MM-dd').parse(appointmentDate);
      return today.year == appointmentDateTime.year &&
          today.month == appointmentDateTime.month &&
          today.day == appointmentDateTime.day;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDetailText(String label, String value,
      double screenHeight, double screenWidth, bool isPortrait) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontSize: isPortrait ? screenHeight * 0.018 : screenWidth * 0.018,
          ),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: " $value"),
          ],
        ),
      ),
    );
  }
}