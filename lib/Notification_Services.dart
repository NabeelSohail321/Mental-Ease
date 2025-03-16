

import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> requestNotificationPermission() async {

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("User granted permission");

    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("User granted provisional permission");

    }else {
      AppSettings.openAppSettings();
      print("User denied permission");

    }

  }



  Future<void> initLocalNotifications(BuildContext context, RemoteMessage message) async {

    var androidInitialization = AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitialilization = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(

      android: androidInitialization,
      iOS: iosInitialilization,

    );

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: (payload){

      }
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }



  Future<void> showNotification (RemoteMessage message) async{

    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        "High importance Notification",
      importance: Importance.max
    );
    
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
        androidNotificationChannel.name.toString(),
        channelDescription: 'My channel Description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );


    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero,
        (){
          _flutterLocalNotificationsPlugin.show(
              0,
              message.notification?.title.toString(),
              message.notification?.body.toString(),
              notificationDetails
          );
        }
    );

  }

  Future<String?> getDeviceToken() async{
   String? token = await messaging.getToken();
   return token;
  }

  void isTokenRefresh () async{
    messaging.onTokenRefresh.listen((event){
      event.toString();
      print("refresh");
    });


  }





}