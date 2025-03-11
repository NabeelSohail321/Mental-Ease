import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

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
  Map<String, List<TimeOfDay>>? _onlineTimeSlots; // New field for online time slots

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

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _databaseRef.child("users").child(user.uid).get();
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
        _onlineTimeSlots = data['onlineTimeSlots'] != null
            ? _parseOnlineTimeSlots(data['onlineTimeSlots'])
            : null;

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Map<String, List<TimeOfDay>> _parseOnlineTimeSlots(dynamic data) {
    final Map<String, List<TimeOfDay>> slots = {};
    if (data is Map) {
      data.forEach((key, value) {
        if (value is List) {
          slots[key] = value.map((time) => _parseTime(time)).toList();
        }
      });
    }
    return slots;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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
        'name': name ?? _name,
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
            : _onlineTimeSlots,
      };

      await _databaseRef.child("users").child(user.uid).update(updatedData);

      // Update local variables
      _name = updatedData['name'] as String?;
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

  void removePastSlots() {
    final now = DateTime.now();
    _onlineTimeSlots?.removeWhere((date, slots) {
      final slotDate = DateTime.parse(date);
      if (slotDate.isBefore(now)) {
        return true; // Remove past slots
      }
      return false;
    });
    notifyListeners();
  }
}