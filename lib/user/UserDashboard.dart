import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'Login.dart';
import 'Profile.dart';
import 'Providers/Auth_Provider/login_Provider.dart';
import 'Providers/Dashboard_Provider/Dashboard_Provider.dart';
import 'Providers/Profile_Provider/Profile_Provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      Userdashboard(),
      Userdashboard(),
      Userdashboard(),
      UserProfile(),
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



class Userdashboard extends StatefulWidget {
  const Userdashboard({super.key});

  @override
  State<Userdashboard> createState() => _UserdashboardState();
}

class _UserdashboardState extends State<Userdashboard> {
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
                                    text: 'Hi, Welcome! ',
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
                        title: Text("Self-Assessment",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.025),),
                        subtitle: Text("40 Questions",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.025),),
                        trailing: Image.asset('assets/images/Questionaire.png',width: MediaQuery.of(context).size.width*0.2,),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                          onPressed: (){},
                          child: Text('Start Now',style: TextStyle(fontWeight: FontWeight.bold),),
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
                        title: Text("Types of Doctors",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.025),),
                        subtitle: Text("You can Consult",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.025),),
                        trailing: Icon(Icons.medical_services,size: MediaQuery.of(context).size.width*0.17,color: Colors.white,),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: (){},
                        child: Text('Consult Now',style: TextStyle(fontWeight: FontWeight.bold),),
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



