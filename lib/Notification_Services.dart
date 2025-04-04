import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:mental_ease/videoCall.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

class NotificationServices {
  // Existing notification properties
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  BuildContext? get _globalContext {
    return navigatorKey.currentState?.overlay?.context;
  }

  // Video call properties
  final Uuid _uuid = Uuid();
  bool _callKitInitialized = false;

  /* ------------------------- */
  /* EXISTING NOTIFICATION METHODS (UNCHANGED) */
  /* ------------------------- */

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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
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
        onDidReceiveNotificationResponse: (payload) {}
    );
  }


  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'video_call') {
        _handleIncomingCall(context,message);
      } else {
        if (Platform.isAndroid) {
          initLocalNotifications(context, message);
          showNotification(message);
        }
      }
    });

    // Handle when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'video_call') {
        _handleIncomingCall(context,message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random().nextInt(100000).toString(),
        "High Importance Notifications",
        importance: Importance.max
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: 'Channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker'
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<String?> getDeviceToken() async => await messaging.getToken();

  void isTokenRefresh() => messaging.onTokenRefresh.listen((token) {
    print("Token refreshed: $token");
  });

  /* ------------------------- */
  /* VIDEO CALL METHODS */
  /* ------------------------- */

  Future<void> _initializeCallKit(BuildContext context) async {
    if (_callKitInitialized) return;

    FlutterCallkitIncoming.onEvent.listen((event) {
      _handleCallEvent(context, event);
    });
    _callKitInitialized = true;
  }


  Future<void> _handleIncomingCall(BuildContext context,RemoteMessage message) async {
    await _initializeCallKit(context);

    await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
      id: message.data['callerId'],
      nameCaller: message.data['callerName'] ?? 'Unknown',
      handle: message.data['callerId'] ?? 'unknown',
      type: 1, // Video call
      duration: 45000, // 45 second timeout
      textAccept: 'Join Video Session',
      extra: {
        'callerId': message.data['callerId'],
        'callerName': message.data['callerName'],
        'receiverId': message.data['receiverId']
      },
      android: AndroidParams(
        isCustomNotification: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',

      ),
      ios: IOSParams(
        supportsVideo: true,
        iconName: 'CallKitLogo',
      ),
    ));
  }

  Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
  }

  void _handleCallEvent(BuildContext context,CallEvent? event) {
    if (event == null) return;

    switch (event.event) {
      case Event.actionCallAccept:
        _onCallAccepted(context,event.body);
        break;
      case Event.actionCallDecline:
        _onCallDeclined(event.body);
        break;
      case Event.actionCallEnded:
        _onCallEnded(event.body);
        break;
      default:
        break;
    }
  }

  void _onCallAccepted(BuildContext context,CallKitParams params) {

    final effectiveContext = context ?? _globalContext;
    if (effectiveContext == null) {
      print('Error: No valid context available for navigation');
      return;
    }


    Navigator.of(effectiveContext).push(
      MaterialPageRoute(
        builder: (_) => callPage("Mental Ease", "broadcaster")
      ),
    );



    print('Call accepted from ${params.nameCaller}');
    // Navigate to call screen:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => VideoCallScreen(callParams: params)));
  }

  void _onCallDeclined(CallKitParams params) {
    print('Call declined from ${params.nameCaller}');
    // Send decline notification to caller
  }

  void _onCallEnded(CallKitParams params) {
    print('Call ended with ${params.nameCaller}');
    // Clean up resources
  }
}