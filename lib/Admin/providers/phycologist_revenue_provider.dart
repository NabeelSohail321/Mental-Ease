import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class PsychologistRevenue {
  final String doctorId;
  final String? doctorName;
  final double completedRevenue;
  final double pendingRevenue;
  final int completedAppointments;
  final int pendingAppointments;

  PsychologistRevenue({
    required this.doctorId,
    this.doctorName,
    required this.completedRevenue,
    required this.pendingRevenue,
    required this.completedAppointments,
    required this.pendingAppointments,
  });

  double get totalRevenue => completedRevenue + pendingRevenue;
  int get totalAppointments => completedAppointments + pendingAppointments;
}



class AdminPsychologistRevenueProvider with ChangeNotifier {
  List<PsychologistRevenue> _revenues = [];
  bool _isLoading = false;
  String? _error;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _showCompleted = true;
  bool _showPending = true;
  DatabaseReference _appointmentsRef = FirebaseDatabase.instance.ref().child('online_Appointments');
  DatabaseReference _psychologistsRef = FirebaseDatabase.instance.ref().child('psychologists');

  List<PsychologistRevenue> get revenues => _revenues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get showCompleted => _showCompleted;
  bool get showPending => _showPending;

  void toggleShowCompleted(bool value) {
    _showCompleted = value;
    notifyListeners();
  }

  void toggleShowPending(bool value) {
    _showPending = value;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    fetchRevenueData();
    notifyListeners();
  }

  Future<void> fetchRevenueData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final startTimestamp = _startDate.millisecondsSinceEpoch;
      final endTimestamp = _endDate.add(Duration(days: 1)).millisecondsSinceEpoch;

      // Fetch appointments data
      final appointmentsSnapshot = await _appointmentsRef
          .orderByChild('createdAt')
          .startAt(startTimestamp)
          .endAt(endTimestamp)
          .once();

      // Fetch users data for names
      final usersRef = FirebaseDatabase.instance.ref().child('users');
      final usersSnapshot = await usersRef.once();

      final dynamic appointmentsValue = appointmentsSnapshot.snapshot.value;
      final dynamic usersValue = usersSnapshot.snapshot.value;

      if (appointmentsValue == null) {
        _revenues = [];
        return;
      }

      final Map<String, dynamic> appointments = Map<String, dynamic>.from(appointmentsValue as Map);
      final Map<String, String> doctorNames = {};

      // Extract doctor names from users
      if (usersValue != null) {
        final Map<String, dynamic> users = Map<String, dynamic>.from(usersValue as Map);
        users.forEach((userId, userData) {
          final userMap = Map<String, dynamic>.from(userData as Map);
          if (userMap['role'] == 'Psychologist') {
            final name = userMap['username'] as String?;
            if (name != null) {
              doctorNames[userId] = name;
            }
          }
        });
      }

      final Map<String, double> completedRevenueMap = {};
      final Map<String, double> pendingRevenueMap = {};
      final Map<String, int> completedCountMap = {};
      final Map<String, int> pendingCountMap = {};

      appointments.forEach((key, value) {
        final data = Map<String, dynamic>.from(value as Map);
        final doctorId = data['doctorId'] as String? ?? '';
        final fee = double.tryParse(data['fee']?.toString() ?? '0') ?? 0;
        final status = data['status'] as String? ?? 'pending';
        final psychologistRevenue = fee * 0.9; // 90% to psychologist

        if (status == 'completed') {
          completedRevenueMap[doctorId] = (completedRevenueMap[doctorId] ?? 0) + psychologistRevenue;
          completedCountMap[doctorId] = (completedCountMap[doctorId] ?? 0) + 1;
        } else {
          pendingRevenueMap[doctorId] = (pendingRevenueMap[doctorId] ?? 0) + psychologistRevenue;
          pendingCountMap[doctorId] = (pendingCountMap[doctorId] ?? 0) + 1;
        }
      });

      // Combine all doctor IDs
      final allDoctorIds = {
        ...completedRevenueMap.keys,
        ...pendingRevenueMap.keys,
      };

      _revenues = allDoctorIds.map((doctorId) {
        return PsychologistRevenue(
          doctorId: doctorId,
          doctorName: doctorNames[doctorId],
          completedRevenue: completedRevenueMap[doctorId] ?? 0,
          pendingRevenue: pendingRevenueMap[doctorId] ?? 0,
          completedAppointments: completedCountMap[doctorId] ?? 0,
          pendingAppointments: pendingCountMap[doctorId] ?? 0,
        );
      }).toList();

      _revenues.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    } catch (e) {
      _error = 'Failed to fetch revenue data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Realtime updates listener
  void startRealtimeUpdates() {
    _appointmentsRef.onValue.listen((event) {
      fetchRevenueData();
    });
  }

  void dispose() {
    // Cancel any subscriptions here if needed
    super.dispose();
  }
}