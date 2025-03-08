import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/Providers/Dashboard_Provider/Dashboard_Provider.dart';
import 'package:mental_ease/user/Providers/Profile_Provider/Profile_Provider.dart';
import 'package:provider/provider.dart';

import 'Auth_Provider/SignUp_Provider.dart';
import 'Auth_Provider/login_Provider.dart';
import 'Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
import 'SplashScreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistProfileProvider())

      ],
      child: const MyApp(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

