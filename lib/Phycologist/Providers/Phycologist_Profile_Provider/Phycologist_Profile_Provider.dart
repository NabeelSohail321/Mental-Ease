import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PsychologistProvider with ChangeNotifier {
  bool _isListed = true; // Default value
  bool get isListed => _isListed;

  Future<void> checkPsychologistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // No user logged in

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(user.uid);

    try {
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        _isListed = data["isListed"] ?? false;
        print(_isListed);
      } else {
        _isListed = false;
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching psychologist status: $e");
    }
  }
}







class PsychologistProfileProvider with ChangeNotifier {
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
  Map<String, List<TimeOfDay>>? _onlineTimeSlots;
  double? _ratings;
  bool? _isVerified;

  // Getters
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
  Map<String, List<TimeOfDay>>? get onlineTimeSlots => _onlineTimeSlots;
  double? get ratings => _ratings;
  bool? get isVerified => _isVerified;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        _isVerified = data['isVerified'] as bool? ?? false;
        _onlineTimeSlots = data['onlineTimeSlots'] != null
            ? _parseAndFilterOnlineTimeSlots(data['onlineTimeSlots'])
            : null;
        _ratings = double.tryParse(data['ratings']?.toString() ?? "0.0") ?? 0.0;

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Map<String, List<TimeOfDay>> _parseAndFilterOnlineTimeSlots(dynamic timeSlotsData) {
    final Map<String, List<TimeOfDay>> result = {};
    if (timeSlotsData is! Map) return result;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final currentTime = TimeOfDay.fromDateTime(now);

    timeSlotsData.forEach((dateStr, times) {
      try {
        final date = DateTime.parse(dateStr);

        // Only include dates that are today or in the future
        if (date.isAfter(todayDate.subtract(const Duration(days: 1)))) {
          if (times is List) {
            final timeList = times.map((timeStr) {
              final parts = timeStr.toString().split(':');
              return TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }).toList();

            // If it's today, filter out past time slots
            if (date == todayDate) {
              result[dateStr] = timeList.where((time) {
                return time.hour > currentTime.hour ||
                    (time.hour == currentTime.hour && time.minute > currentTime.minute);
              }).toList();
            } else {
              result[dateStr] = timeList;
            }
          }
        }
      } catch (e) {
        print('Error parsing date $dateStr: $e');
      }
    });

    return result..removeWhere((key, value) => value.isEmpty);
  }

  Future<void> updateProfileData({
    String? name,
    String? description,
    String? phoneNumber,
    String? address,
    List<String>? degrees,
    String? specialization,
    String? experience,
    String? clinicTiming,
    String? weekDays,
    String? appointmentFee,
    String? stripeId,
    Map<String, List<TimeOfDay>>? onlineTimeSlots,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final updatedData = {
        'username': name ?? _name,
        'description': description ?? _description,
        'phoneNumber': phoneNumber ?? _phoneNumber,
        'address': address ?? _address,
        'degrees': degrees ?? _degrees,
        'specialization': specialization ?? _specialization,
        'experience': experience ?? _experience,
        'clinicTiming': clinicTiming ?? _clinicTiming,
        'weekDays': weekDays ?? _weekDays,
        'appointmentFee': appointmentFee ?? _appointmentFee,
        'stripeId': stripeId ?? _stripeId,
        'onlineTimeSlots': onlineTimeSlots != null
            ? _serializeOnlineTimeSlots(onlineTimeSlots)
            : _onlineTimeSlots != null
            ? _serializeOnlineTimeSlots(_onlineTimeSlots!)
            : null,
      };

      await _databaseRef.child("users").child(user.uid).update(updatedData);

      // Update local state
      _name = updatedData['username'] as String?;
      _description = updatedData['description'] as String?;
      _phoneNumber = updatedData['phoneNumber'] as String?;
      _address = updatedData['address'] as String?;
      _degrees = updatedData['degrees'] as List<String>?;
      _specialization = updatedData['specialization'] as String?;
      _experience = updatedData['experience'] as String?;
      _clinicTiming = updatedData['clinicTiming'] as String?;
      _weekDays = updatedData['weekDays'] as String?;
      _appointmentFee = updatedData['appointmentFee'] as String?;
      _stripeId = updatedData['stripeId'] as String?;
      _onlineTimeSlots = onlineTimeSlots ?? _onlineTimeSlots;

      if (_areAllFieldsFilled()) {
        await _databaseRef.child("users").child(user.uid).update({'isListed': true});
      }

      notifyListeners();
    } catch (e) {
      print("Error updating profile data: $e");
    }
  }

  Map<String, List<String>> _serializeOnlineTimeSlots(Map<String, List<TimeOfDay>> slots) {
    final Map<String, List<String>> serialized = {};
    slots.forEach((key, value) {
      serialized[key] = value.map((time) => '${time.hour}:${time.minute}').toList();
    });
    return serialized;
  }

  Future<void> uploadImage(String fieldName, XFile imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = _storage.ref().child('psychologist_profile/${user.uid}/$fieldName.jpg');
      await ref.putFile(File(imageFile.path));
      final url = await ref.getDownloadURL();

      await _databaseRef.child("users").child(user.uid).update({fieldName: url});

      if (fieldName == 'profileImageUrl') {
        _profileImageUrl = url;
      } else if (fieldName == 'degreeImageUrl') {
        _degreeImageUrl = url;
      }

      if (_areAllFieldsFilled()) {
        await _databaseRef.child("users").child(user.uid).update({'isListed': true});
      }

      notifyListeners();
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  bool _areAllFieldsFilled() {
    return _profileImageUrl != null &&
        _profileImageUrl!.isNotEmpty &&
        _degreeImageUrl != null &&
        _degreeImageUrl!.isNotEmpty &&
        _description != null &&
        _description!.isNotEmpty &&
        _phoneNumber != null &&
        _phoneNumber!.isNotEmpty &&
        _address != null &&
        _address!.isNotEmpty &&
        _degrees != null &&
        _degrees!.isNotEmpty &&
        _name != null &&
        _name!.isNotEmpty &&
        _specialization != null &&
        _specialization!.isNotEmpty &&
        _experience != null &&
        _experience!.isNotEmpty &&
        _clinicTiming != null &&
        _clinicTiming!.isNotEmpty &&
        _weekDays != null &&
        _weekDays!.isNotEmpty &&
        _appointmentFee != null &&
        _appointmentFee!.isNotEmpty &&
        _stripeId != null &&
        _stripeId!.isNotEmpty;
  }

  // Time Slot Management Methods
  List<DateTime> getAvailableDates() {
    if (_onlineTimeSlots == null) return [];
    return _onlineTimeSlots!.keys.map((dateStr) => DateTime.parse(dateStr)).toList()..sort();
  }

  List<TimeOfDay> getAvailableTimesForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _onlineTimeSlots?[dateStr] ?? [];
  }

  bool isTimeSlotAvailable(DateTime date, TimeOfDay time) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final slots = _onlineTimeSlots?[dateStr];
    if (slots == null) return false;
    return slots.any((slot) => slot.hour == time.hour && slot.minute == time.minute);
  }

  Future<void> addTimeSlot(DateTime date, TimeOfDay time) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = '${time.hour}:${time.minute}';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final slotRef = _databaseRef.child("users").child(user.uid).child("onlineTimeSlots").child(dateStr);
      final snapshot = await slotRef.get();

      List<dynamic> existingSlots = [];
      if (snapshot.exists) {
        existingSlots = List.from(snapshot.value as List);
      }

      if (!existingSlots.contains(timeStr)) {
        existingSlots.add(timeStr);
        existingSlots.sort((a, b) {
          final aParts = a.toString().split(':');
          final bParts = b.toString().split(':');
          final aHour = int.parse(aParts[0]);
          final aMin = int.parse(aParts[1]);
          final bHour = int.parse(bParts[0]);
          final bMin = int.parse(bParts[1]);
          if (aHour == bHour) return aMin.compareTo(bMin);
          return aHour.compareTo(bHour);
        });

        await slotRef.set(existingSlots);

        // Update local state
        _onlineTimeSlots ??= {};
        _onlineTimeSlots![dateStr] = existingSlots.map((t) => _parseTime(t.toString())).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error adding time slot: $e");
    }
  }

  Future<void> removeTimeSlot(DateTime date, TimeOfDay time) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = '${time.hour}:${time.minute}';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final slotRef = _databaseRef.child("users").child(user.uid).child("onlineTimeSlots").child(dateStr);
      final snapshot = await slotRef.get();

      if (snapshot.exists) {
        List<dynamic> slots = List.from(snapshot.value as List);
        slots.remove(timeStr);

        if (slots.isEmpty) {
          await slotRef.remove();
        } else {
          await slotRef.set(slots);
        }

        // Update local state
        _onlineTimeSlots ??= {};
        if (slots.isEmpty) {
          _onlineTimeSlots!.remove(dateStr);
        } else {
          _onlineTimeSlots![dateStr] = slots.map((t) => _parseTime(t.toString())).toList();
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error removing time slot: $e");
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}