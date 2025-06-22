
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mental_ease/Phycologist/phycologist_appointment_history.dart';
import 'package:mental_ease/Phycologist/revenue_analysis_screen.dart';
import 'package:provider/provider.dart';

import '../Auth_Provider/login_Provider.dart';
import '../Login.dart';
import '../user/Assesment_Options.dart';
import '../user/ChatScreen.dart';
import '../user/Doctors_Listing.dart';
import '../user/Inbox.dart';
import 'App_fee_revenue_screen.dart';
import 'PhycologistInboxScreen.dart';
import 'Phycologist_Profile.dart';
import 'Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
import 'Providers/resechdule_provider.dart';
import 'Reschedule_Screen.dart';


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
    Phycologistinboxscreen(firebase_auth.FirebaseAuth.instance.currentUser!.uid), // Replace with your Messages screen
    PhycologistAppointmentHistory_Options(),
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
      await Provider.of<PsychologistProfileProvider>(context, listen: false).fetchProfileData(firebase_auth.FirebaseAuth.instance.currentUser!.uid);
      _checkProfileStatus();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RescheduleProvider>(context, listen: false).fetchRescheduleRequests();
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
            child: Text("ok"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RescheduleProvider>(context);
    final length = provider.rescheduleRequests.length;
    final dashboardProvider = Provider.of<PsychologistProfileProvider>(context);
    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(MediaQuery.of(context).size.height * 0.03),
          ),
          child: Stack(
            children: [
              // Background with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Bitmoji & Welcome Text
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Row: Bitmoji Image & Greeting
                      Row(
                        children: [
                          // Bitmoji Image
                          ClipOval(
                            child: dashboardProvider.isLoading
                                ? Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF006064),
                                  ),
                                ),
                              ),
                            )
                                : (dashboardProvider.profileImageUrl == null || dashboardProvider.profileImageUrl!.isEmpty)
                                ? Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            )
                                : Image.network(
                              dashboardProvider.profileImageUrl!,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white, size: 30),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF006064),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(width: MediaQuery.of(context).size.width * 0.03), // Space between image and text

                          // Welcome Text
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Hi, Welcome! ',
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Color(0xFF006064),
                                      fontSize: MediaQuery.of(context).size.height * 0.028,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Dr ${dashboardProvider.name}' ?? "Guest", // Default to Guest if null
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context).size.height * 0.028,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.7,
                          child: Divider(
                            thickness: 2,
                            height: MediaQuery.of(context).size.width*0.035,
                          ),
                        ),
                      ),

                      // Third Row: Motivational Quote
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Heal ',
                                style: TextStyle(
                                  fontFamily: "CustomFont",
                                  color: Color(0xFF006064),
                                  fontSize: MediaQuery.of(context).size.height * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'Grow & ',
                                style: TextStyle(
                                  fontFamily: "CustomFont",
                                  color: Color(0xFF006064),
                                  fontSize: MediaQuery.of(context).size.height * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'Thrive',
                                style: TextStyle(
                                  fontFamily: "CustomFont",
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.height * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.03,),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF006064),
                  borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                ),
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.03),
                      child: ListTile(
                        title: Text("Check Revenue for",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.022),),
                        subtitle: Text("Online Appointments",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.021),),
                        trailing: Image.asset('assets/images/Questionaire.png',width: MediaQuery.of(context).size.width*0.2,),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return RevenueAnalysisScreen();
                          },));
                        },
                        child: Text('Check now',style: TextStyle(fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(

                            backgroundColor: Color(0xFF004D4D),
                            foregroundColor: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
              )
              ,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03,),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF006064),
                  borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                ),
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.03),
                      child: ListTile(
                        title: Text("Check Revenue for",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.022),),
                        subtitle: Text("Admin",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.022),),
                        trailing: Icon(Icons.medical_services,size: MediaQuery.of(context).size.width*0.17,color: Colors.white,),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AppFeeRevenueScreen();
                          },));
                        },
                        child: Text('Check Now',style: TextStyle(fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(

                            backgroundColor: Color(0xFF004D4D),
                            foregroundColor: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
              )
              ,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03,),
            Center(
              child: Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Color(0xFF006064),
                        borderRadius: BorderRadius.circular(30),
                      ),

                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.03),
                              child: ListTile(
                                title: Text(
                                  "Rescheduled Requests for ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.height * 0.022,
                                  ),
                                ),
                                subtitle: Text(
                                  "Online Appointments",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.height * 0.022,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.access_time_rounded,
                                  size: MediaQuery.of(context).size.width * 0.17,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.15,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return DoctorRescheduleRequestsScreen();
                                  }));
                                },
                                child: Text('Check Now', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF004D4D),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Responsive notification badge at container boundary
                      if (length > 0)
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.02, // 2% from right
                    top: MediaQuery.of(context).size.height * 0.001, // 1% from top
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                        vertical: MediaQuery.of(context).size.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF006064),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.03, // Responsive font
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery
                    .of(context)
                    .size
                    .width * 0.03,
                vertical: MediaQuery
                    .of(context)
                    .size
                    .height * 0.02,
              ),
              child: Container(
                padding: EdgeInsets.all(MediaQuery
                    .of(context)
                    .size
                    .height * 0.005),
                decoration: BoxDecoration(
                  // Light yellow warning color
                  borderRadius: BorderRadius.circular(10),
                  // Border color
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF856404),
                        size: MediaQuery
                            .of(context)
                            .size
                            .height * 0.03),
                    SizedBox(width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.02),
                    Expanded(
                      child: Text(
                        "This app helps identify symptoms of depression and connects you with verified professionals.",
                        style: TextStyle(
                          color: Color(0xFF856404),
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .height * 0.013,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )

    );
  }
}