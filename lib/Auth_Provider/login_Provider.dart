import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/UserDashboard.dart';
import 'package:provider/provider.dart';

import '../../../Phycologist/Phycologist_dashboard.dart';
import '../../../Login.dart';
import '../Admin/AdminDashboard.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(){
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _isLoggedIn = _auth.currentUser != null;
    notifyListeners();
  }

  Future<void> loginUser(BuildContext context, String email, String password, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoggedIn = true; // Update state
      notifyListeners();
      String uid = userCredential.user!.uid;
      if(!userCredential.user!.emailVerified){
       await userCredential.user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are not verified a verification link is send to your email verify and try again")));
        return;
      }

      // Fetch role from Realtime Database
      _dbRef.child(uid).child("role").once().then((DatabaseEvent event) {
        _isLoading = false;
        notifyListeners();

        if (event.snapshot.exists) {
          String role = event.snapshot.value.toString();

          _dbRef.child(uid).update({'deviceToken': token});
          _navigateToRolePage(context, role);
        } else {
          _showError(context, "User role not found.");
        }
      }).catchError((error) {
        _isLoading = false;
        _showError(context, "Error fetching user role.");
      });
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      _showError(context, _errorMessage!);
    }
  }


  Future<void> forgetPassword (String email, BuildContext context)async {
    await _auth.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset link has been send to your email address")));

  }

  void _navigateToRolePage(BuildContext context, String role) {
    if (role == "user") {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
        return HomeScreen();
      },),  (Route<dynamic> route) => false,);
    } else if (role == "Psychologist") {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
        return PsychologistHomeScreen();
      },),  (Route<dynamic> route) => false,);
    } else if (role == "Admin" || role == "SuperAdmin") {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
        return AdminHomeScreen(role);
      },),  (Route<dynamic> route) => false,);
    } else {
      _showError(context, "Invalid role detected.");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Login failed. Please try again.';
    }
  }
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut().then((value){


      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (_) => false, // Remove all previous routes
      );
    });
    _isLoggedIn = false;
    notifyListeners();


  }

  Future<void> checkUserAndNavigate(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) {
      // User is not logged in, navigate to Login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
      return;
    }

    // Fetch role from Firebase Database
    try {
      DatabaseEvent event = await _dbRef.child(user.uid).child("role").once();

      if (event.snapshot.exists) {
        String role = event.snapshot.value.toString();
        _navigateToRolePage(context, role);
      } else {
        _showError(context, "User role not found.");
      }
    } catch (error) {
      _showError(context, "Error fetching user role.");
    }
  }

}
