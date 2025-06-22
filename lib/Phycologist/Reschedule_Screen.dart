import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'Providers/resechdule_provider.dart';


class DoctorRescheduleRequestsScreen extends StatefulWidget {
  @override
  _DoctorRescheduleRequestsScreenState createState() => _DoctorRescheduleRequestsScreenState();
}

class _DoctorRescheduleRequestsScreenState extends State<DoctorRescheduleRequestsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAppointmentId;
  String? patientId;
  String? patientName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RescheduleProvider>(context, listen: false).fetchRescheduleRequests();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now.add(Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.add(Duration(days: 1)),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = null;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    final initialTime = _selectedTime ?? TimeOfDay(hour: 9, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _confirmReschedule(BuildContext context, String appointmentId) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final formattedTime = '${_selectedTime!.hour}:${_selectedTime!.minute}';

    try {
      await Provider.of<RescheduleProvider>(context, listen: false).updateAppointmentTime(
        appointmentId: appointmentId,
        newDate: formattedDate,
        newTime: formattedTime,
        patientId: patientId!,
        patientName: patientName!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment rescheduled successfully')),
      );

      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _selectedAppointmentId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reschedule: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(screenHeight * 0.03),
          ),
          child: Container(
            padding: EdgeInsets.only(bottom: screenHeight * 0.05),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              "Reschedule Requests",
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight * 0.025,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: Consumer<RescheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.rescheduleRequests.isEmpty) {
            return Center(
              child: Text(
                "No reschedule requests",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              if (_selectedAppointmentId != null) _buildDateTimeSelector(context),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.rescheduleRequests.length,
                  itemBuilder: (context, index) {
                    final request = provider.rescheduleRequests[index];
                    final originalDate = request['date'];
                    final originalTime = request['time'];
                    final requestedAt = provider.formatTimestamp(request['requestedAt']);
                    final currentPatientName = request['patientName'] ?? 'Patient';

                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _selectedAppointmentId = request['id'];
                            patientId = request['userId'];
                            patientName = currentPatientName;
                            _selectedDate = null;
                            _selectedTime = null;
                          });
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal[100],
                            child: Icon(Icons.person, color: Colors.teal),
                          ),
                          title: Text(
                            currentPatientName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original: $originalDate at $originalTime',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              Text(
                                'Requested on: $requestedAt',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                          trailing: _selectedAppointmentId == request['id']
                              ? Icon(Icons.edit, color: Colors.orange)
                              : Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth * 0.04,
                            color: Colors.teal,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateTimeSelector(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select new appointment time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                          : 'Select Date',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectedDate != null ? () => _selectTime(context) : null,
                    child: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select Time',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _confirmReschedule(context, _selectedAppointmentId!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Confirm Reschedule'),
            ),
          ],
        ),
      ),
    );
  }
}