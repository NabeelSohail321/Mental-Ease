import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mental_ease/Admin/phycologistVerificationScreen.dart';
import 'package:mental_ease/Admin/userManagementScreen.dart';
import 'package:provider/provider.dart';

import '../Auth_Provider/login_Provider.dart';
import '../Login.dart';
import '../user/Appointment_History.dart';
import '../user/Inbox.dart';
import '../user/Providers/Dashboard_Provider/Dashboard_Provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'AdminProfile.dart';
import 'Admin_Reports_Screen.dart';
import 'App_Revenue.dart';
import 'Phycologist_Revenue.dart';


class AdminHomeScreen extends StatefulWidget {
  final String? role;

  const AdminHomeScreen(this.role, {super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  // Initialize screens in initState to access widget.role
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Admindashboard(widget.role), // Use widget.role to access the parent's property
      AdminReportsScreen(),
      PsychologistVerificationScreen(),
      Adminprofile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return  LoginPage();
        }

        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: GNav(
                gap: 8,
                activeColor: const Color(0xFF006064),
                color: Colors.grey,
                tabBackgroundColor: const Color(0xFF80DEEA),
                padding: const EdgeInsets.all(12),
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.report,
                    text: 'Reports',
                  ),
                  GButton(
                    icon: Icons.domain_verification_rounded,
                    text: 'Verification',
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
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


class Admindashboard extends StatefulWidget {
  String? role;


  Admindashboard(this.role);

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  @override
  void initState() {
    super.initState();

    // Fetch username after widget is built
    Future.microtask(() {
      Provider.of<DashboardProvider>(context, listen: false).getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
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
                            child: Image.asset(
                              'assets/images/hi.png', // Ensure correct asset path
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.width * 0.15,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 50),
                            ),
                          ),

                          SizedBox(width: MediaQuery.of(context).size.width * 0.03), // Space between image and text

                          // Welcome Text
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Hi, Welcome! Admin ',
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Color(0xFF006064),
                                      fontSize: MediaQuery.of(context).size.height * 0.028,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: dashboardProvider.userName ?? "Guest", // Default to Guest if null
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
                        title: Text("Psychologists Revenue for",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.022),),
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
                            return AdminPsychologistRevenueScreen();
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
                            return AdminAppFeeRevenueScreen();
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
            if(widget.role == 'SuperAdmin')
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
                          title: Text("Admins",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.022),),
                          subtitle: Text("Management",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.022),),
                          trailing: Icon(Icons.manage_accounts,size: MediaQuery.of(context).size.width*0.17,color: Colors.white,),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width*0.15,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return UserManagementScreen();
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
      ),
    );
  }
}