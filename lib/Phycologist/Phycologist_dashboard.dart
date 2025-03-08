
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../Auth_Provider/login_Provider.dart';
import '../Login.dart';
import 'Phycologist_Profile.dart';
import 'Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';

class phycologistHomeScreen extends StatefulWidget {
  const phycologistHomeScreen({super.key});

  @override
  State<phycologistHomeScreen> createState() => _phycologistHomeScreenState();
}

class _phycologistHomeScreenState extends State<phycologistHomeScreen> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      PhycologistDashboard(),
      PhycologistDashboard(),
      PhycologistDashboard(),
      PsychologistProfileScreen(),
    ];
  }
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.message_outlined),
        title: "Messages",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.medical_services),
        title: "Doctors",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If user is not logged in, show login screen
        if (!authProvider.isLoggedIn) {
          return LoginPage(); // Redirect to Login Screen
        }

        // Show Persistent Bottom Nav Bar if user is logged in
        return PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          backgroundColor: Colors.white,
          navBarStyle: NavBarStyle.style1,
          popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
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