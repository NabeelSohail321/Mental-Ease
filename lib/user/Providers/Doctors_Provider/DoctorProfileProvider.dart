import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsychologistProfileViewProvider with ChangeNotifier {
  String? _profileImageUrl;
  String? _degreeImageUrl;
  String? _description;
  String? _phoneNumber;
  String? _address;
  List<String>? _degrees;
  String? _name;
  String? _specialization;
  String? _experience;
  String? _clinicTiming;
  String? _weekDays;
  String? _appointmentFee;
  String? _stripeId;
  String? _email;
  double? _ratings;
  Map<String, List<TimeOfDay>>? _onlineTimeSlots;
  bool? _isVerfied;

  String? get profileImageUrl => _profileImageUrl;
  String? get degreeImageUrl => _degreeImageUrl;
  String? get description => _description;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;
  List<String>? get degrees => _degrees;
  String? get name => _name;
  String? get specialization => _specialization;
  String? get experience => _experience;
  String? get clinicTiming => _clinicTiming;
  String? get weekDays => _weekDays;
  String? get appointmentFee => _appointmentFee;
  String? get stripeId => _stripeId;
  String? get email => _email;
  double? get ratings => _ratings;
  Map<String, List<TimeOfDay>>? get onlineTimeSlots => _onlineTimeSlots;
  bool? get isVerfied => _isVerfied;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();



  Future<List<Map<String, dynamic>>> getAllFeedbacks(String doctorId) async {
    final snapshot = await _dbRef.child('users/$doctorId/feedbacks').get();
    if (!snapshot.exists) return [];

    final feedbacks = <Map<String, dynamic>>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    data.forEach((key, value) {
      final feedback = Map<String, dynamic>.from(value as Map);

      // Handle the rating conversion safely
      dynamic ratingValue = feedback['ratings'] ?? feedback['ratings'] ?? 0.0;
      double rating;
      if (ratingValue is int) {
        rating = ratingValue.toDouble();
      } else if (ratingValue is double) {
        rating = ratingValue;
      } else {
        rating = 0.0; // Default value if invalid
      }

      feedbacks.add({
        'id': key,
        'rating': rating,
        'comment': feedback['comment'] as String? ?? '',
        'userId': feedback['userId'] as String? ?? '',
        'username': feedback['username'] as String? ?? 'Anonymous',
        'timestamp': feedback['timestamp'] as int? ?? 0,
      });
    });

    // Sort by timestamp (newest first)
    feedbacks.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    return feedbacks;
  }
  Future<void> fetchProfileData(String psychologistId) async {
    try {
      final snapshot = await _databaseRef.child("users").child(psychologistId).get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        _profileImageUrl = data['profileImageUrl'] as String?;
        _degreeImageUrl = data['degreeImageUrl'] as String?;
        _description = data['description'] as String?;
        _phoneNumber = data['phoneNumber'] as String?;
        _address = data['address'] as String?;
        _degrees = data['degrees'] != null
            ? List<String>.from(data['degrees'] as List<dynamic>)
            : [];
        _name = data['username'] as String?;
        _specialization = data['specialization'] as String?;
        _experience = data['experience'] as String?;
        _clinicTiming = data['clinicTiming'] as String?;
        _weekDays = data['weekDays'] as String?;
        _appointmentFee = data['appointmentFee'] as String?;
        _stripeId = data['stripeId'] as String?;
        _email = data['email'] as String?;

        // Parse online time slots and filter out past dates
        _onlineTimeSlots = data['onlineTimeSlots'] != null
            ? _parseOnlineTimeSlots(data['onlineTimeSlots'])
            : null;

        _ratings = double.tryParse(data['ratings']?? "0.0") ?? 0.0;
        _isVerfied = data['isVerfied'];

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }
  Map<String, List<TimeOfDay>> _parseOnlineTimeSlots(dynamic timeSlotsData) {
    final Map<String, List<TimeOfDay>> result = {};
    if (timeSlotsData is! Map) return result;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final currentTime = TimeOfDay.fromDateTime(now);

    timeSlotsData.forEach((dateStr, times) {
      try {
        final date = DateTime.parse(dateStr);

        // Check if date is today or in the future
        if (date.isAfter(todayDate.subtract(const Duration(days: 1)))) {
          if (times is List) {
            final timeSlots = times.map((timeStr) {
              final parts = timeStr.toString().split(':');
              return TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }).toList();

            // If it's today, filter out past time slots
            if (date == todayDate) {
              result[dateStr] = timeSlots.where((time) {
                return time.hour > currentTime.hour ||
                    (time.hour == currentTime.hour && time.minute > currentTime.minute);
              }).toList();
            } else {
              result[dateStr] = timeSlots;
            }
          }
        }
      } catch (e) {
        print('Error parsing date $dateStr: $e');
      }
    });

    return result..removeWhere((key, value) => value.isEmpty);
  }
  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}