
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../Auth_Provider/login_Provider.dart';
import '../Login.dart';
import 'Phycologist_Profile.dart';
import 'Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';


class PsychologistHomeScreen extends StatefulWidget {
  const PsychologistHomeScreen({super.key});

  @override
  State<PsychologistHomeScreen> createState() => _PsychologistHomeScreenState();
}

class _PsychologistHomeScreenState extends State<PsychologistHomeScreen> {
  int _selectedIndex = 0; // Track the selected index for GoogleNav

  // List of screens to display based on the selected index
  final List<Widget> _screens = [
    PhycologistDashboard(),
    PhycologistDashboard(), // Replace with your Messages screen
    PhycologistDashboard(), // Replace with your Doctors screen
    PsychologistProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If user is not logged in, show login screen
        if (!authProvider.isLoggedIn) {
          return LoginPage(); // Redirect to Login Screen
        }

        // Show GoogleNav if user is logged in
        return Scaffold(
          body: _screens[_selectedIndex], // Display the selected screen
          bottomNavigationBar: Container(
            color: Colors.white, // Background color of the navigation bar
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: GNav(
                gap: 8, // Space between icon and text
                activeColor: Color(0xFF006064), // Color of the selected item
                color: Colors.grey, // Color of the unselected items
                tabBackgroundColor: Color(0xFF80DEEA), // Background color of the selected item
                padding: EdgeInsets.all(12), // Padding for each tab
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.message_outlined,
                    text: 'Messages',
                  ),
                  GButton(
                    icon: Icons.medical_services,
                    text: 'Doctors',
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index; // Update the selected index
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}


class PhycologistDashboard extends StatefulWidget {
  const PhycologistDashboard({super.key});

  @override
  State<PhycologistDashboard> createState() => _PhycologistDashboardState();
}

class _PhycologistDashboardState extends State<PhycologistDashboard> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Provider.of<PsychologistProvider>(context, listen: false).checkPsychologistStatus();
      _checkProfileStatus();
    });
  }

  void _checkProfileStatus() {
    final psychologistProvider = Provider.of<PsychologistProvider>(context, listen: false);

    if (!psychologistProvider.isListed) {
      Future.delayed(Duration.zero, () {
        _showProfileIncompleteDialog();
      });
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Complete Your Profile"),
        content: Text("Please complete your profile first to be listed on the app."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Complete Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Welcome to Home!")),
    );
  }
}