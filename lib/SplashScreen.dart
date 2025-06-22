import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Connectivity _connectivity = Connectivity();


  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();

    notificationServices.firebaseInit(context);

    _checkConnectivityAndNavigate();
  }

  Future<void> _checkConnectivityAndNavigate() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      _showNoInternetDialog();
    } else {
      // Internet available, proceed after delay
      Timer(const Duration(seconds: 3), () {
        Provider.of<AuthProvider>(context, listen: false).checkUserAndNavigate(context);
      });
    }
  }
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'No Internet Connection',
            style: TextStyle(
              color: Color(0xFF006064),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please check your internet connection and try again.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CLOSE',
                style: TextStyle(
                  color: Color(0xFF006064),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Close the app
                Future.delayed(Duration.zero, () {
                  SystemNavigator.pop();
                });
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Color(0xFFE0F7FA),
        );
      },
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