import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mental_ease/Login.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../Dashboard_Provider/Dashboard_Provider.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;

  String? _userName;
  String? _email;
  bool _isLoading = false;


  String? get userName => _userName;
  String? get email => _email;
  bool get isLoading => _isLoading;







  // Fetch user data from Firebase Realtime Database
  Future<void> getUserInfo() async {
    try {
      if (currentUser != null) {
        _email = currentUser!.email;

        final userSnapshot = await _dbRef.child("users/${currentUser!.uid}").get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.value as Map<dynamic, dynamic>;
          _userName = userData["username"];
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  // Update username in Firebase Realtime Database
  Future<void> updateUserName(String newName, BuildContext context) async {
    try {
      if (currentUser != null) {
        _isLoading = true;
        notifyListeners();
        await _dbRef.child("users/${currentUser!.uid}").update({
          "username": newName,
        });


        _userName = newName;
        _isLoading = false;

        notifyListeners();
       await Provider.of<DashboardProvider>(context).getUserInfo();
      }
    } catch (e) {
      print("Error updating username: $e");
    }
  }

  // Change password
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (currentUser == null) return "User not found.";

      // Re-authenticate user before updating password
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return error.toString();
    }
  }

  // Logout user

}
