// lib/Admin/providers/psychologist_reports_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class PsychologistReportsProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get reports directly from Firebase
      final reportsSnapshot = await _dbRef.child('reports').get();
      final reportsData = _parseReportsSnapshot(reportsSnapshot);

      // Attach both psychologist and patient names
      final reportsWithNames = await _attachNames(reportsData);

      _reports = reportsWithNames;
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch reports: ${e.toString()}';
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Report> _parseReportsSnapshot(DataSnapshot snapshot) {
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> reportsMap = snapshot.value as Map<dynamic, dynamic>;
    return reportsMap.entries.map((entry) {
      return Report.fromMap(
        entry.key.toString(),
        Map<String, dynamic>.from(entry.value),
      );
    }).toList();
  }

  Future<List<Report>> _attachNames(List<Report> reports) async {
    final reportsWithNames = <Report>[];

    for (final report in reports) {
      try {
        // Get psychologist name
        final psychologistSnapshot = await _dbRef.child('users/${report.doctorId}').get();
        String psychologistName = 'Unknown Psychologist';
        if (psychologistSnapshot.exists) {
          final userData = Map<String, dynamic>.from(psychologistSnapshot.value as Map);
          psychologistName = userData['username'] ?? psychologistName;
        }

        // Get patient name
        final patientSnapshot = await _dbRef.child('users/${report.userId}').get();
        String patientName = 'Unknown Patient';
        if (patientSnapshot.exists) {
          final userData = Map<String, dynamic>.from(patientSnapshot.value as Map);
          patientName = userData['username'] ?? patientName;
        }

        reportsWithNames.add(report.copyWith(
          psychologistName: psychologistName,
          patientName: patientName,
        ));
      } catch (e) {
        reportsWithNames.add(report.copyWith(
          psychologistName: 'Unknown Psychologist',
          patientName: 'Unknown Patient',
        ));
      }
    }

    return reportsWithNames;
  }
}
// lib/models/report_model.dart
// lib/models/report_model.dart
class Report {
  final String id;
  final String doctorId;
  final String psychologistName;
  final String userId;
  final String patientName;
  final String reason;
  final String customReport;
  final DateTime timestamp;

  Report({
    required this.id,
    required this.doctorId,
    this.psychologistName = '',
    required this.userId,
    this.patientName = '',
    required this.reason,
    required this.customReport,
    required this.timestamp,
  });

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      doctorId: map['doctorId'] ?? '',
      userId: map['userId'] ?? '',
      reason: map['reason'] ?? '',
      customReport: map['customReport'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Report copyWith({String? psychologistName, String? patientName}) {
    return Report(
      id: id,
      doctorId: doctorId,
      psychologistName: psychologistName ?? this.psychologistName,
      userId: userId,
      patientName: patientName ?? this.patientName,
      reason: reason,
      customReport: customReport,
      timestamp: timestamp,
    );
  }
}