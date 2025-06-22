import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Doctors_Listing.dart'; // For date formatting

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
          'date': assessment['date'] ?? DateTime.now().toString(), // Handle null dates
        });
      }
    });

    // Sort assessments by date (newest first)
    userAssessments.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });
  }

  return userAssessments;
}

void _showHistoryResult(BuildContext context, Map<String, dynamic> historyItem) {
  final String status = historyItem['status'] ?? 'Unknown';
  final Color color;
  final IconData icon;

  // Determine color and icon based on status
  switch (status) {
    case 'Normal':
      color = Colors.green;
      icon = Icons.check_circle;
      break;
    case 'Moderate':
      color = Colors.orange;
      icon = Icons.warning;
      break;
    case 'Severe':
      color = Colors.red;
      icon = Icons.error;
      break;
    default:
      color = Colors.grey;
      icon = Icons.help_outline;
  }

  // Parse the date
  final date = DateTime.parse(historyItem['date']);
  final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Assessment Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              SizedBox(height: 16),
              Text(
                'Assessment Date:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your result:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 16),
              if (status == 'Moderate' || status == 'Severe')
                Text(
                  'Consider consulting a healthcare professional',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),


        ],
      );
    },
  );
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<String>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        final appBarTitle = snapshot.connectionState == ConnectionState.done && snapshot.hasData
            ? "Hi ${snapshot.data}, Your Assessment History"
            : "Loading...";

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(screenHeight * 0.2),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(screenHeight * 0.03),
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: screenHeight * 0.05),
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
                    fontSize: screenHeight * 0.025,
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
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in,
                                color: Colors.teal,
                                size: screenWidth * 0.07),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              "Total Assessments: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CustomFont',
                              ),
                            ),
                            Text(
                              "${assessments.length}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
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
                        final date = DateTime.parse(item['date']);
                        final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

                        return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showHistoryResult(context, item),
                          child: ListTile(
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: screenWidth * 0.04,
                              color: Colors.teal,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                          ),
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