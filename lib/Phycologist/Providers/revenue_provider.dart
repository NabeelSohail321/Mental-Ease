import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RevenueProvider with ChangeNotifier {
  List<AppointmentRevenue> _revenues = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'completed';
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  List<AppointmentRevenue> get revenues => _revenues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  final String? _currentDoctorId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> fetchRevenueData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print("Fetching data from ${_startDate.toIso8601String()} to ${_endDate.toIso8601String()}");

      final ref = FirebaseDatabase.instance.ref().child('online_Appointments');
      final snapshot = await ref.orderByChild('doctorId').equalTo(_currentDoctorId).get();

      if (snapshot.exists && _currentDoctorId != null) {
        final Map<dynamic, dynamic> appointments = snapshot.value as Map<dynamic, dynamic>;
        _revenues = [];

        appointments.forEach((key, value) {
          final appointment = value as Map<dynamic, dynamic>;
          final status = appointment['status']?.toString().toLowerCase() ?? '';
          final dateStr = appointment['date']?.toString() ?? '';
          final timeStr = appointment['time']?.toString() ?? '';
          final feeStr = appointment['fee']?.toString() ?? '0';
          final doctorId = appointment['doctorId']?.toString() ?? '';

          try {
            final appointmentDate = DateTime.parse(dateStr); // Correct format: YYYY-MM-DD

            if (
            doctorId == _currentDoctorId &&
                appointmentDate.isAfter(_startDate.subtract(Duration(days: 1))) &&
                appointmentDate.isBefore(_endDate.add(Duration(days: 1))) &&
                status == _selectedStatus
            ) {
              final fee = double.tryParse(feeStr.replaceAll('Rs.', '').trim()) ?? 0;
              final psychologistRevenue = fee * 0.9;

              final revenue = AppointmentRevenue(
                id: key.toString(),
                date: appointmentDate,
                time: timeStr,
                fee: fee,
                psychologistRevenue: psychologistRevenue,
                status: status,
              );

              _revenues.add(revenue);
              print("Added revenue: ${revenue.formattedDate} | ₹${revenue.fee} | Psychologist: ₹${revenue.psychologistRevenue}");
            }
          } catch (e) {
            print('Error parsing appointment $key: $e');
          }
        });

        _revenues.sort((a, b) => a.date.compareTo(b.date));
        print("Total matched revenues: ${_revenues.length}");
      } else {
        print("No appointments found for doctorId: $_currentDoctorId");
      }
    } catch (e) {
      _error = 'Failed to fetch revenue data: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
    fetchRevenueData();
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    _startDate = start;
    _endDate = end;
    notifyListeners();
    await fetchRevenueData();
  }
}

class AppointmentRevenue {
  final String id;
  final DateTime date;
  final String time;
  final double fee;
  final double psychologistRevenue;
  final String status;

  AppointmentRevenue({
    required this.id,
    required this.date,
    required this.time,
    required this.fee,
    required this.psychologistRevenue,
    required this.status,
  });

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
