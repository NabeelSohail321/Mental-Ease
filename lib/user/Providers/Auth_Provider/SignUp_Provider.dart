import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/Login.dart';

class SignupProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref('users');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signUpUser({
    required String username,
    required String email,
    required String password,
    required String role,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Save user data to Firebase Realtime Database
      await _database.child(uid).set({
        "username": username,
        "email": email,
        "uid": uid,
        "role": role
      });

      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully Signed Up')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );

    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      String errorMessage = "An error occurred";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use. Please try another one.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak. Use a stronger password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format. Please enter a valid email.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong. Please try again.")),
      );
    }
  }
}
