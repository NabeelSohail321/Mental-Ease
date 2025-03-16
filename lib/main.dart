import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/Providers/Chat_Providers/Chat_Provider.dart';
import 'package:mental_ease/user/Providers/Dashboard_Provider/Dashboard_Provider.dart';
import 'package:mental_ease/user/Providers/Doctors_Provider/DoctorProfileProvider.dart';
import 'package:mental_ease/user/Providers/Profile_Provider/Profile_Provider.dart';
import 'package:provider/provider.dart';

import 'Auth_Provider/SignUp_Provider.dart';
import 'Auth_Provider/login_Provider.dart';
import 'Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
import 'SplashScreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistProfileProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistProfileViewProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider())


      ],
      child: const MyApp(),
    ),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> _firebaseMessagingBackgroundHandler ( RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: "CustomFont", // Apply font globally
        ),
        debugShowCheckedModeBanner: false,
        home: SplachScreen(),
      ),
    );
  }
}

