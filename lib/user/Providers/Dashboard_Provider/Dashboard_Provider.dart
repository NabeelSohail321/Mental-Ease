import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class DashboardProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');

  String? _userName;
  String ? _email;

  String? get userName => _userName;
  String? get email => _email;


  Future<void> getUserInfo() async {
    try {
      String? uid = _auth.currentUser?.uid; // Get current user UID
      if (uid == null) return;

      // Fetch user data from Realtime Database
      DatabaseEvent event = await _dbRef.child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

        _userName = userData['username'];
        _email = userData['email'];

        notifyListeners(); // Notify UI about changes
      } else {
        print("User data not found in database.");
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }
}
