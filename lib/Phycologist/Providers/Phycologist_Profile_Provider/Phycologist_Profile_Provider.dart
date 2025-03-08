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
  String? _degreeName;
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
  String? get degreeName => _degreeName;
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
        _profileImageUrl = data['profileImageUrl'];
        _degreeImageUrl = data['degreeImageUrl'];
        _description = data['description'];
        _phoneNumber = data['phoneNumber'];
        _address = data['address'];
        _degreeName = data['degreeName'];
        _name = data['username'];
        _specialization = data['specialization'];
        _experience = data['experience'];
        _clinicTiming = data['clinicTiming'];
        _weekDays = data['weekDays'];
        _appointmentFee = data['appointmentFee'];
        _stripeId = data['stripeId'];
        _email = data['email'];
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
    String? degreeName,
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
        'degreeName': degreeName ?? _degreeName,
        'specialization': specialization ?? _specialization,
        'experience': experience ?? _experience,
        'clinicTiming': clinicTiming ?? _clinicTiming,
        'weekDays': weekDays ?? _weekDays,
        'appointmentFee': appointmentFee ?? _appointmentFee,
        'stripeId': stripeId ?? _stripeId,
      };

      await _databaseRef.child("users").child(user.uid).update(updatedData);

      // Update local variables
      _name = updatedData['name'];
      _description = updatedData['description'];
      _phoneNumber = updatedData['phoneNumber'];
      _address = updatedData['address'];
      _degreeName = updatedData['degreeName'];
      _specialization = updatedData['specialization'];
      _experience = updatedData['experience'];
      _clinicTiming = updatedData['clinicTiming'];
      _weekDays = updatedData['weekDays'];
      _appointmentFee = updatedData['appointmentFee'];
      _stripeId = updatedData['stripeId'];

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
        _degreeName != null &&
        _degreeName!.isNotEmpty &&
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
