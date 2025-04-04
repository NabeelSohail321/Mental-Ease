import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/Login.dart';
import 'package:provider/provider.dart';

import 'Auth_Provider/login_Provider.dart';
import 'Notification_Services.dart';
import 'Sign_Up.dart';

class SplachScreen extends StatefulWidget{
  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {

  NotificationServices notificationServices =  NotificationServices();


  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();

    notificationServices.firebaseInit(context);

    Timer(Duration(seconds: 3), (){
      Provider.of<AuthProvider>(context, listen: false).checkUserAndNavigate(context);
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/bi_peace-fill.png'),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mental',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: 40,
                        ),
                      ),
                      TextSpan(
                        text: 'Ease',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text('Your Companion of Mental Wellness',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient:
          LinearGradient(colors:
          [
            Color(0xFFE0F7FA),
            Color(0xFF80DEEA)
          ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}