import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Assesment_History.dart';
import 'Assesment_Questions.dart';

class Assessment_Options extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(MediaQuery.of(context).size.height * 0.03),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Text(
                  "Assessment Page",
                  style: TextStyle(
                    fontFamily: "CustomFont", // Optional: customize if needed
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard(
              context,
              icon: Icons.psychology_alt_outlined,
              title: "Start Assessment",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Questions()),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            _buildOptionCard(
              context,
              icon: Icons.history,
              title: "View History",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssessmentHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF006064), size: screenHeight * 0.04),
            SizedBox(width: screenWidth * 0.04),
            Text(
              title,
              style: TextStyle(
                fontSize: screenHeight * 0.028,
                fontWeight: FontWeight.bold,
                fontFamily: "CustomFont",
              ),
            ),
          ],
        ),
      ),
    );
  }
}