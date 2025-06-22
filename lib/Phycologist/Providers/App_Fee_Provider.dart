import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AppFeeProvider with ChangeNotifier {
  List<AppointmentRevenue> _revenues = [];
  bool _isLoading = false;
  String? _error;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  List<AppointmentRevenue> get revenues => _revenues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  Future<void> fetchRevenueData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (uid == null) {
        _error = "User is not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final ref = FirebaseDatabase.instance.ref().child('online_Appointments');
      final snapshot = await ref.orderByChild('doctorId').equalTo(uid).get();

      print("Snapshot exists: ${snapshot.exists}");
      print("Snapshot value: ${snapshot.value}");

      if (snapshot.exists) {
        final Map<dynamic, dynamic> appointments = snapshot.value as Map<dynamic, dynamic>;
        _revenues = [];

        appointments.forEach((key, value) {
          try {
            final appointment = value as Map<dynamic, dynamic>;
            final status = appointment['status']?.toString()?.toLowerCase() ?? '';
            final dateStr = appointment['date']?.toString() ?? '';
            final timeStr = appointment['time']?.toString() ?? '';
            final feeStr = appointment['fee']?.toString() ?? '0';
            final doctorId = appointment['doctorId']?.toString() ?? '';

            // Debug prints
            print("Processing appointment ID: $key");
            print("Raw date: $dateStr | Raw fee: $feeStr | Status: $status");

            // Correct parsing: date is in format YYYY-MM-DD
            final dateParts = dateStr.split('-');
            final year = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final day = int.parse(dateParts[2]);
            final appointmentDate = DateTime(year, month, day);

            if (appointmentDate.isAfter(_startDate.subtract(Duration(days: 1))) &&
                appointmentDate.isBefore(_endDate.add(Duration(days: 1)))) {

              final fee = double.tryParse(feeStr.trim()) ?? 0;
              final platformFee = fee * 0.1; // 10% platform fee

              _revenues.add(AppointmentRevenue(
                id: key.toString(),
                date: appointmentDate,
                time: timeStr,
                fee: fee,
                psychologistRevenue: platformFee, // This is the platform's cut
                status: status,
                doctorId: doctorId,
              ));
            }
          } catch (e) {
            print('Error parsing appointment $key: $e');
          }
        });

        _revenues.sort((a, b) => a.date.compareTo(b.date));
        print("Total revenues fetched: ${_revenues.length}");
      }
    } catch (e) {
      _error = 'Failed to fetch revenue data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  final double psychologistRevenue; // Represents platform fee
  final String status;
  final String doctorId;

  AppointmentRevenue({
    required this.id,
    required this.date,
    required this.time,
    required this.fee,
    required this.psychologistRevenue,
    required this.status,
    required this.doctorId,
  });

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
