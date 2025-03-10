// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_pw_validator/flutter_pw_validator.dart';
// void main(){
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget{
//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//       ),
//       home: SplachScreen(),
//     );
//   }
// }
//
//
// class SplachScreen extends StatefulWidget{
//   @override
//   State<SplachScreen> createState() => _SplachScreenState();
// }
//
// class _SplachScreenState extends State<SplachScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     Timer(Duration(seconds: 5), (){
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomePage())
//       );
//     }
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset('lib/icons/bi_peace-fill.png'),
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: 'Mental',
//                         style: TextStyle(
//                           color: Color(0xFF006064),
//                           fontSize: 40,
//                         ),
//                       ),
//                       TextSpan(
//                         text: 'Ease',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Text('Your Companion of Mental Wellness',
//               style: TextStyle(
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           gradient:
//           LinearGradient(colors:
//           [
//             Color(0xFFE0F7FA),
//             Color(0xFF80DEEA)
//           ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget{
//   HomePageState createState() => HomePageState();
// }
//
// class HomePageState extends State<HomePage>{
//
//   final formkey = GlobalKey<FormState>();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmpasswordController = TextEditingController();
//   final RegExp passwordRegex = RegExp(r'^(?=.[0-9])(?=.[!@#$%^&*(),.?":{}|<>]).+$');
//   bool isPasswordValid = false;
//   bool isPasswordVisible = false;
//   bool isConfirmPasswordVisible = false;
//
//   @override
//   void dispose(){
//     emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void disposepassword(){
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   void onPasswordvalid(){
//     if(!isPasswordValid){
//       setState(() {
//         isPasswordValid = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Password is strong!'),
//             backgroundColor: Colors.green,
//           ));
//     }
//   }
//
//   void onPasswordInvalid(){
//     if(isPasswordValid){
//       setState(() {
//         isPasswordValid = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Password is weak'),
//             backgroundColor: Colors.red,
//           )
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(150), // Adjust height for image and text
//         child: ClipRRect(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(30), // Rounded corners
//           ),
//           child: Stack(
//             children: [
//               // Background container with image and gradient
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('lib/icons/bi_peace-fill.png'), // Replace with your image path
//                   ),
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFFE0F7FA),
//                       Color(0xFF80DEEA)
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//               // AppBar content
//               AppBar(
//                 title: Text(''),
//                 centerTitle: true,
//                 backgroundColor: Colors.transparent, // Transparent to show background
//                 elevation: 0, // Remove shadow for a clean look
//               ),
//               // Text at the bottom of the AppBar
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom:25), // Add some spacing
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Create ',
//                           style: TextStyle(
//                             color: Color(0xFF006064),
//                             fontSize: 30,
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'an ',
//                           style: TextStyle(
//                             color: Color(0xFF006064),
//                             fontSize: 30,
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'Account',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 30,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Form(
//               key: formkey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 20,),
//                         Text('Name',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         TextFormField(
//                           controller: usernameController,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Enter your username',
//                           ),
//                           validator: (value){
//                             if(value == null || value.isEmpty){
//                               return 'Username cannot be Empty';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 20),
//                         Text('Email',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         TextFormField(
//                           controller: emailController,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Email',
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value){
//                             if(value == null || value.isEmpty){
//                               return 'Email cannot be Empty';
//                             }
//                             else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                               return "Enter a valid email address";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 30,),
//                         Text(' Password',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10,),
//                         TextFormField(
//                           controller: passwordController,
//                           obscureText: !isPasswordVisible,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Contain 1number and 1special character',
//                             suffixIcon: IconButton(
//                               onPressed: (){
//                                 setState(() {
//                                   isPasswordVisible = !isPasswordVisible;
//                                 });
//                               },
//                               icon: Icon(
//                                 isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           validator: (value){
//                             if(value == null || value.isEmpty){
//                               return 'Password is not Empty';
//                             }
//                             else if(!passwordRegex.hasMatch(passwordController.text)){
//                               return 'Password must contain one number and special character';
//                             }
//                             return null;
//                           },
//                         ),
//                         FlutterPwValidator(
//                             width: 10,
//                             height: 10,
//                             minLength: 6,
//                             specialCharCount: 1,
//                             numericCharCount: 1,
//                             onSuccess: onPasswordvalid,
//                             onFail: onPasswordInvalid,
//                             controller: passwordController
//                         ),
//                         SizedBox(height: 30),
//                         Text('Confirm Password',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         TextFormField(
//                           controller: confirmpasswordController,
//                           obscureText: !isConfirmPasswordVisible,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Confirm the password',
//                             suffixIcon: IconButton(
//                               onPressed: (){
//                                 setState(() {
//                                   isConfirmPasswordVisible = !isConfirmPasswordVisible;
//                                 });
//                               },
//                               icon: Icon(
//                                 isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           validator: (value){
//                             if(value == null || value.isEmpty){
//                               return 'Confirm password cannot be Empty';
//                             }
//                             else if(value != passwordController.text){
//                               return 'Password does not match';
//                             }
//                             return null;
//                           },
//                         ),
//                         FlutterPwValidator(
//                             width: 10,
//                             height: 10,
//                             minLength: 6,
//                             specialCharCount: 1,
//                             numericCharCount: 1,
//                             onSuccess: onPasswordvalid,
//                             onFail: onPasswordInvalid,
//                             controller: passwordController
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 10,),
//                   SizedBox(
//                     width: 370,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if(formkey.currentState!.validate()){
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('All details are valid')),
//                           );
//                           Navigator.push(context,
//                             MaterialPageRoute(builder: (context) => FirstScreen()),
//                           );
//                         }
//                         else{
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Please correct the errors')),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF006064),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(36),
//                         ),
//                       ),
//                       child: Text('Sign Up',
//                         style: TextStyle(
//                           fontSize: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FirstScreen extends StatefulWidget{
//   FirstScreenPage createState() => FirstScreenPage();
// }
//
// class FirstScreenPage extends State<FirstScreen>{
//   final formkey = GlobalKey<FormState>();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmpasswordController = TextEditingController();
//   final RegExp passwordRegex = RegExp(r'^(?=.[0-9])(?=.[!@#$%^&*(),.?":{}|<>]).+$');
//   bool isPasswordValid = false;
//   bool isPasswordVisible = false;
//   bool isConfirmPasswordVisible = false;
//
//   @override
//   void dispose(){
//     emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void disposepassword(){
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   void onPasswordvalid(){
//     if(!isPasswordValid){
//       setState(() {
//         isPasswordValid = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Password is strong!'),
//             backgroundColor: Colors.green,
//           ));
//     }
//   }
//
//   void onPasswordInvalid(){
//     if(isPasswordValid){
//       setState(() {
//         isPasswordValid = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Password is weak'),
//             backgroundColor: Colors.red,
//           )
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(150), // Adjust height for image and text
//         child: ClipRRect(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(30), // Rounded corners
//           ),
//           child: Stack(
//             children: [
//               // Background container with image and gradient
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('lib/icons/bi_peace-fill.png'), // Replace with your image path
//                   ),
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFFE0F7FA),
//                       Color(0xFF80DEEA)
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//               // AppBar content
//               AppBar(
//                 title: Text(''),
//                 centerTitle: true,
//                 backgroundColor: Colors.transparent, // Transparent to show background
//                 elevation: 0, // Remove shadow for a clean look
//               ),
//               // Text at the bottom of the AppBar
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom:25), // Add some spacing
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Welcome ',
//                           style: TextStyle(
//                             color: Color(0xFF006064),
//                             fontSize: 30,
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'Back!',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 30,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Form(
//               key: formkey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 20),
//                         Text('Email',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         TextFormField(
//                           controller: emailController,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Email',
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value){
//                             if(value == null || value.isEmpty){
//                               return 'Email cannot be Empty';
//                             }
//                             else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                               return "Enter a valid email address";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 30,),
//                         Text(' Password',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10,),
//                         TextFormField(
//                           controller: passwordController,
//                           obscureText: !isPasswordVisible,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Contain 1number and 1special character',
//                             suffixIcon: IconButton(
//                               onPressed: (){
//                                 setState(() {
//                                   isPasswordVisible = !isPasswordVisible;
//                                 });
//                               },
//                               icon: Icon(
//                                 isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           validator: (value){
//                             if(value == null || value.isEmpty){
//                               return 'Password is not Empty';
//                             }
//                             else if(!passwordRegex.hasMatch(passwordController.text)){
//                               return 'Password must contain one number and special character';
//                             }
//                             return null;
//                           },
//                         ),
//                         FlutterPwValidator(
//                             width: 10,
//                             height: 10,
//                             minLength: 6,
//                             specialCharCount: 1,
//                             numericCharCount: 1,
//                             onSuccess: onPasswordvalid,
//                             onFail: onPasswordInvalid,
//                             controller: passwordController
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 10,),
//                   SizedBox(
//                     width: 370,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if(formkey.currentState!.validate()){
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('All details are valid')),
//                           );
//                           Navigator.push(context,
//                             MaterialPageRoute(builder: (context) => FirstScreen()),
//                           );
//                         }
//                         else{
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Please correct the errors')),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF006064),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(36),
//                         ),
//                       ),
//                       child: Text('Sign Up',
//                         style: TextStyle(
//                           fontSize: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DoctorCard extends StatelessWidget {
//   final Doctor doctor;
//
//   const DoctorCard({
//     super.key,
//     required this.doctor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade300),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundImage: AssetImage(doctor.imageUrl),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     doctor.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     doctor.specialization,
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00897B),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Chat Now',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DoctorsScreen extends StatelessWidget {
//   const DoctorsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.lightBlue[100],
//         elevation: 0,
//         leading: const Icon(Icons.settings, color: Color(0xFF00897B)),
//         title: const Text(
//           'Meet the Doctors',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: Icon(Icons.notifications, color: Color(0xFF00897B)),
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: doctors.length,
//         itemBuilder: (context, index) {
//           return DoctorCard(doctor: doctors[index]);
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: 0,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.people),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: '',
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Doctor {
//   final String name;
//   final String specialization;
//
//   const Doctor({
//     required this.name,
//     required this.specialization,
//   });
// }
//
// final List<Doctor> doctors = [
//   const Doctor(
//     name: 'Dr. Sean John',
//     specialization: 'Neurologist',
//   ),
//   const Doctor(
//     name: 'Dr. Jane Smith',
//     specialization: 'Psychologist',
//   ),
//   const Doctor(
//     name: 'Dr. Alex Turner',
//     specialization: 'Psychiatrist',
//   ),
//   const Doctor(
//     name: 'Dr. Maria Khan',
//     specialization: 'Clinical Psychologist',
//   ),
//   const Doctor(
//     name: 'Dr. John Doe',
//     specialization: 'Cognitive Therapist',
//   ),
// ];
//
//
//
//
//
//
//
//
//
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:mental_ease/user/Providers/Auth_Provider/SignUp_Provider.dart';
// import 'package:mental_ease/user/Providers/Auth_Provider/login_Provider.dart';
// import 'package:mental_ease/user/Providers/Dashboard_Provider/Dashboard_Provider.dart';
// import 'package:mental_ease/user/Providers/Profile_Provider/Profile_Provider.dart';
// import 'package:provider/provider.dart';
//
// import 'Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
// import 'SplashScreen.dart';
// import 'firebase_options.dart';
//
// Future<void> main() async {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SignupProvider()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => DashboardProvider()),
//         ChangeNotifierProvider(create: (_) => UserProfileProvider()),
//         ChangeNotifierProvider(create: (_) => PsychologistProvider()),
//         ChangeNotifierProvider(create: (_) => PsychologistProfileProvider())
//
//       ],
//       child: const MyApp(),
//     ),
//   );
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: MaterialApp(
//         theme: ThemeData(
//           fontFamily: "CustomFont", // Apply font globally
//         ),
//         debugShowCheckedModeBanner: false,
//         home: SplachScreen(),
//       ),
//     );
//   }
// }
//


//
//
// Card(
// elevation: 4,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(12),
// ),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// // Image Section
// Stack(
// children: [
// Container(
// height: screenHeight * 0.2,
// decoration: BoxDecoration(
// borderRadius: const BorderRadius.only(
// topLeft: Radius.circular(12),
// topRight: Radius.circular(12),
// ),
// image: DecorationImage(
// image: AssetImage(item.image),
// fit: BoxFit.cover,
// ),
// ),
// ),
// // Optional: Add a gradient overlay for text readability
// Positioned.fill(
// child: Container(
// decoration: BoxDecoration(
// borderRadius: const BorderRadius.only(
// topLeft: Radius.circular(12),
// topRight: Radius.circular(12),
// ),
// gradient: LinearGradient(
// colors: [
// Colors.black.withOpacity(0.2),
// Colors.black.withOpacity(0.0),
// ],
// begin: Alignment.topCenter,
// end: Alignment.bottomCenter,
// ),
// ),
// ),
// ),
// ],
// ),
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// // Row for Name and Price
// Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// // Item Name
// Expanded(
// child: Text(
// item.name,
// overflow: TextOverflow.ellipsis, // Handle text overflow
// maxLines: 1, // Limit to a single line
// style: TextStyle(
// fontWeight: FontWeight.bold,
// fontSize: screenHeight * 0.018,
// ),
// ),
// ),
// SizedBox(height: screenHeight * 0.01),
// // Price
// Text(
// item.price,
// textAlign: TextAlign.right,
// style: TextStyle(
// color: Colors.green,
// fontSize: screenHeight * 0.016,
// fontWeight: FontWeight.w600,
// ),
// ),
// ],
// ),
// SizedBox(height: screenHeight * 0.001),
// // Item Description
// Text(
// item.description,
// overflow: TextOverflow.ellipsis, // Handle text overflow
// maxLines: 1, // Limit description to 2 lines
// style: TextStyle(
// color: Colors.grey,
// fontSize: screenHeight * 0.015,
// ),
// ),
//
// SizedBox(height: screenHeight * 0.005),
// // Row for Item Sold and Rating
// Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// // Sold Items
// Text(
// '${item.soldItem} Sold',
// overflow: TextOverflow.ellipsis,
// maxLines: 1,
// style: TextStyle(
// fontWeight: FontWeight.bold,
// color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
// fontSize: screenHeight * 0.015,
// ),
// ),
//
// // Rating Stars
// Row(
// children: List.generate(5, (index) {
// if (index < item.rating.floor()) {
// // Full star
// return Icon(
// Icons.star,
// color: Colors.orange,
// size: screenHeight * 0.02,
// );
// } else if (index < item.rating) {
// // Half star
// return Icon(
// Icons.star_half,
// color: Colors.orange,
// size: screenHeight * 0.02,
// );
// } else {
// // Empty star
// return Icon(
// Icons.star_border,
// color: Colors.orange,
// size: screenHeight * 0.02,
// );
// }
// }),
// ),
// ],
// ),
// ],
// ),
// ),
// ],
// ),
// ),
