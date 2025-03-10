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
  List<String>? _degrees; // Updated to support multiple degrees
  String? _name;
  String? _specialization;
  String? _experience;
  String? _clinicTiming;
  String? _weekDays;
  String? _appointmentFee;
  String? _stripeId;
  String? _email;

  String? get profileImageUrl => _profileImageUrl;
  String? get degreeImageUrl => _degreeImageUrl;
  String? get description => _description;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;
  List<String>? get degrees => _degrees; // Updated getter
  String? get name => _name;
  String? get specialization => _specialization;
  String? get experience => _experience;
  String? get clinicTiming => _clinicTiming;
  String? get weekDays => _weekDays;
  String? get appointmentFee => _appointmentFee;
  String? get stripeId => _stripeId;
  String? get email => _email;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _databaseRef.child("users").child(user.uid).get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        // Explicitly cast each field to the correct type
        _profileImageUrl = data['profileImageUrl'] as String?;
        _degreeImageUrl = data['degreeImageUrl'] as String?;
        _description = data['description'] as String?;
        _phoneNumber = data['phoneNumber'] as String?;
        _address = data['address'] as String?;
        _degrees = data['degrees'] != null
            ? List<String>.from(data['degrees'] as List<dynamic>)
            : []; // Cast to List<String>
        _name = data['username'] as String?;
        _specialization = data['specialization'] as String?;
        _experience = data['experience'] as String?;
        _clinicTiming = data['clinicTiming'] as String?;
        _weekDays = data['weekDays'] as String?;
        _appointmentFee = data['appointmentFee'] as String?;
        _stripeId = data['stripeId'] as String?;
        _email = data['email'] as String?;

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Future<void> updateProfileData({
    String? name,
    String? description,
    String? phoneNumber,
    String? address,
    List<String>? degrees, // Updated to accept a list of degrees
    String? specialization,
    String? experience,
    String? clinicTiming,
    String? weekDays,
    String? appointmentFee,
    String? stripeId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final updatedData = {
        'name': name ?? _name,
        'description': description ?? _description,
        'phoneNumber': phoneNumber ?? _phoneNumber,
        'address': address ?? _address,
        'degrees': degrees ?? _degrees, // Updated for degrees
        'specialization': specialization ?? _specialization,
        'experience': experience ?? _experience,
        'clinicTiming': clinicTiming ?? _clinicTiming,
        'weekDays': weekDays ?? _weekDays,
        'appointmentFee': appointmentFee ?? _appointmentFee,
        'stripeId': stripeId ?? _stripeId,
      };

      await _databaseRef.child("users").child(user.uid).update(updatedData);

      // Update local variables
      _name = updatedData['name'] as String?;
      _description = updatedData['description'] as String?;
      _phoneNumber = updatedData['phoneNumber'] as String?;
      _address = updatedData['address'] as String?;
      _degrees = updatedData['degrees'] as List<String>?; // Cast to List<String>
      _specialization = updatedData['specialization'] as String?;
      _experience = updatedData['experience'] as String?;
      _clinicTiming = updatedData['clinicTiming'] as String?;
      _weekDays = updatedData['weekDays'] as String?;
      _appointmentFee = updatedData['appointmentFee'] as String?;
      _stripeId = updatedData['stripeId'] as String?;

      if (_areAllFieldsFilled()) {
        await _databaseRef.child("users").child(user.uid).update({'isListed': true});
      }

      notifyListeners();
    } catch (e) {
      print("Error updating profile data: $e");
    }
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
        _degrees!.isNotEmpty && // Check if at least one degree is selected
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
}