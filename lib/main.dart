import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mental_ease/user/Providers/Model_Provider.dart';
import 'package:mental_ease/user/Providers/Appointment_provider/Physical_Appointment_Provider.dart';
import 'package:mental_ease/user/Providers/Chat_Providers/Chat_Provider.dart';
import 'package:mental_ease/user/Providers/Dashboard_Provider/Dashboard_Provider.dart';
import 'package:mental_ease/user/Providers/Doctors_Provider/DoctorProfileProvider.dart';
import 'package:mental_ease/user/Providers/Profile_Provider/Profile_Provider.dart';
import 'package:provider/provider.dart';

import 'Admin/providers/Admin_App_revenue_Provider.dart';
import 'Admin/providers/UserManagementProvider.dart';
import 'Admin/providers/phycologistVerificationProvider.dart';
import 'Admin/providers/phycologist_report_provider.dart';
import 'Admin/providers/phycologist_revenue_provider.dart';
import 'Auth_Provider/SignUp_Provider.dart';
import 'Auth_Provider/login_Provider.dart';
import 'Notification_Services.dart';
import 'Phycologist/Providers/App_Fee_Provider.dart';
import 'Phycologist/Providers/Phycologist_Physical_Appointment_Provider.dart';
import 'Phycologist/Providers/PhycologistChatProvider.dart';
import 'Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
import 'Phycologist/Providers/phycologist_online_appointment_provider.dart';
import 'Phycologist/Providers/resechdule_provider.dart';
import 'Phycologist/Providers/revenue_provider.dart';
import 'SplashScreen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey=dotenv.env["STRIPE_PUBLISH_KEY"]!;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ModelProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => Phycologistchatprovider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider12()),
        ChangeNotifierProvider(create: (_) => phycologistOnlineAppointmentProvider()),
        ChangeNotifierProvider(create: (_) => RevenueProvider()),
        ChangeNotifierProvider(create: (_) => AppFeeProvider()),
        ChangeNotifierProvider(create: (_) => AdminAppFeeProvider()),
        ChangeNotifierProvider(create: (_) => AdminPsychologistRevenueProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistReportsProvider()),
        ChangeNotifierProvider(create: (_) => PsychologistVerificationProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => RescheduleProvider())

      ],
      child: const MyApp(),
    ),
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
        navigatorKey: navigatorKey,
        theme: ThemeData(
          // fontFamily: "CustomFont", // Apply font globally
        ),
        debugShowCheckedModeBanner: false,
        home: SplachScreen(),
      ),
    );
  }
}

