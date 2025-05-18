import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<List<Map<String, dynamic>>> fetchUserAssessments() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    throw Exception("User not logged in.");
  }

  final databaseRef = FirebaseDatabase.instance.ref().child('History');
  final snapshot = await databaseRef.get();

  List<Map<String, dynamic>> userAssessments = [];

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data.forEach((key, value) {
      final assessment = Map<String, dynamic>.from(value);
      if (assessment['Uid'] == uid) {
        userAssessments.add({
          'id': key,
          'status': assessment['status'],
          // Optional: Add a timestamp if available
          // 'timestamp': assessment['timestamp'],
        });
      }
    });
  }

  return userAssessments;
}
class AssessmentHistoryScreen extends StatefulWidget {
  @override
  _AssessmentHistoryScreenState createState() => _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  late Future<String> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = fetchUsername();
  }

  Future<String> fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final userRef = FirebaseDatabase.instance.ref().child('users').child(uid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data['username'] ?? 'Guest';
    } else {
      return 'Guest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        final appBarTitle = snapshot.connectionState == ConnectionState.done && snapshot.hasData
            ? "Hi ${snapshot.data}, Your Assessment History"
            : "Loading...";

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(MediaQuery.of(context).size.height * 0.03),
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  appBarTitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height * 0.025,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CustomFont',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchUserAssessments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());

              if (snapshot.hasError)
                return Center(child: Text("Error: ${snapshot.error}"));

              final assessments = snapshot.data!;
              if (assessments.isEmpty)
                return Center(child: Text("No assessments found."));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in, color: Colors.teal, size: 30),
                            SizedBox(width: 10),
                            Text(
                              "Total Assessments: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CustomFont',
                              ),
                            ),
                            Text(
                              "${assessments.length}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: assessments.length,
                      itemBuilder: (context, index) {
                        final item = assessments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal[100],
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          title: Text(
                            "Status: ${item['status']}",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),

                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}