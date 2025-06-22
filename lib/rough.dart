// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_pw_validator/flutter_pw_validator.dart';
// // void main(){
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget{
// //   @override
// //   Widget build(BuildContext context){
// //     return MaterialApp(
// //       theme: ThemeData(
// //         primarySwatch: Colors.deepPurple,
// //       ),
// //       home: SplachScreen(),
// //     );
// //   }
// // }
// //
// //
// // class SplachScreen extends StatefulWidget{
// //   @override
// //   State<SplachScreen> createState() => _SplachScreenState();
// // }
// //
// // class _SplachScreenState extends State<SplachScreen> {
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     Timer(Duration(seconds: 5), (){
// //       Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => HomePage())
// //       );
// //     }
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Image.asset('lib/icons/bi_peace-fill.png'),
// //                 RichText(
// //                   text: TextSpan(
// //                     children: [
// //                       TextSpan(
// //                         text: 'Mental',
// //                         style: TextStyle(
// //                           color: Color(0xFF006064),
// //                           fontSize: 40,
// //                         ),
// //                       ),
// //                       TextSpan(
// //                         text: 'Ease',
// //                         style: TextStyle(
// //                           color: Colors.black,
// //                           fontSize: 40,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             Text('Your Companion of Mental Wellness',
// //               style: TextStyle(
// //                 fontSize: 14,
// //               ),
// //             ),
// //           ],
// //         ),
// //         width: MediaQuery.of(context).size.width,
// //         height: MediaQuery.of(context).size.height,
// //         decoration: BoxDecoration(
// //           gradient:
// //           LinearGradient(colors:
// //           [
// //             Color(0xFFE0F7FA),
// //             Color(0xFF80DEEA)
// //           ],
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class HomePage extends StatefulWidget{
// //   HomePageState createState() => HomePageState();
// // }
// //
// // class HomePageState extends State<HomePage>{
// //
// //   final formkey = GlobalKey<FormState>();
// //   final TextEditingController usernameController = TextEditingController();
// //   final TextEditingController emailController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //   final TextEditingController confirmpasswordController = TextEditingController();
// //   final RegExp passwordRegex = RegExp(r'^(?=.[0-9])(?=.[!@#$%^&*(),.?":{}|<>]).+$');
// //   bool isPasswordValid = false;
// //   bool isPasswordVisible = false;
// //   bool isConfirmPasswordVisible = false;
// //
// //   @override
// //   void dispose(){
// //     emailController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   void disposepassword(){
// //     passwordController.dispose();
// //     super.dispose();
// //   }
// //
// //   void onPasswordvalid(){
// //     if(!isPasswordValid){
// //       setState(() {
// //         isPasswordValid = true;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Password is strong!'),
// //             backgroundColor: Colors.green,
// //           ));
// //     }
// //   }
// //
// //   void onPasswordInvalid(){
// //     if(isPasswordValid){
// //       setState(() {
// //         isPasswordValid = false;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Password is weak'),
// //             backgroundColor: Colors.red,
// //           )
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context){
// //     return Scaffold(
// //       appBar: PreferredSize(
// //         preferredSize: Size.fromHeight(150), // Adjust height for image and text
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.vertical(
// //             bottom: Radius.circular(30), // Rounded corners
// //           ),
// //           child: Stack(
// //             children: [
// //               // Background container with image and gradient
// //               Container(
// //                 decoration: BoxDecoration(
// //                   image: DecorationImage(
// //                     image: AssetImage('lib/icons/bi_peace-fill.png'), // Replace with your image path
// //                   ),
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       Color(0xFFE0F7FA),
// //                       Color(0xFF80DEEA)
// //                     ],
// //                     begin: Alignment.topCenter,
// //                     end: Alignment.bottomCenter,
// //                   ),
// //                 ),
// //               ),
// //               // AppBar content
// //               AppBar(
// //                 title: Text(''),
// //                 centerTitle: true,
// //                 backgroundColor: Colors.transparent, // Transparent to show background
// //                 elevation: 0, // Remove shadow for a clean look
// //               ),
// //               // Text at the bottom of the AppBar
// //               Align(
// //                 alignment: Alignment.bottomCenter,
// //                 child: Padding(
// //                   padding: const EdgeInsets.only(bottom:25), // Add some spacing
// //                   child: RichText(
// //                     text: TextSpan(
// //                       children: [
// //                         TextSpan(
// //                           text: 'Create ',
// //                           style: TextStyle(
// //                             color: Color(0xFF006064),
// //                             fontSize: 30,
// //                           ),
// //                         ),
// //                         TextSpan(
// //                           text: 'an ',
// //                           style: TextStyle(
// //                             color: Color(0xFF006064),
// //                             fontSize: 30,
// //                           ),
// //                         ),
// //                         TextSpan(
// //                           text: 'Account',
// //                           style: TextStyle(
// //                             color: Colors.black,
// //                             fontSize: 30,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             Form(
// //               key: formkey,
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.start,
// //                 children: [
// //                   Padding(
// //                     padding: EdgeInsets.all(16),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         SizedBox(height: 20,),
// //                         Text('Name',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(height: 10),
// //                         TextFormField(
// //                           controller: usernameController,
// //                           decoration: InputDecoration(
// //                             border: OutlineInputBorder(),
// //                             labelText: 'Enter your username',
// //                           ),
// //                           validator: (value){
// //                             if(value == null || value.isEmpty){
// //                               return 'Username cannot be Empty';
// //                             }
// //                             return null;
// //                           },
// //                         ),
// //                         SizedBox(height: 20),
// //                         Text('Email',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(height: 10),
// //                         TextFormField(
// //                           controller: emailController,
// //                           decoration: InputDecoration(
// //                             border: OutlineInputBorder(),
// //                             labelText: 'Email',
// //                           ),
// //                           keyboardType: TextInputType.emailAddress,
// //                           validator: (value){
// //                             if(value == null || value.isEmpty){
// //                               return 'Email cannot be Empty';
// //                             }
// //                             else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
// //                               return "Enter a valid email address";
// //                             }
// //                             return null;
// //                           },
// //                         ),
// //                         SizedBox(height: 30,),
// //                         Text(' Password',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(height: 10,),
// //                         TextFormField(
// //                           controller: passwordController,
// //                           obscureText: !isPasswordVisible,
// //                           decoration: InputDecoration(
// //                             border: OutlineInputBorder(),
// //                             labelText: 'Contain 1number and 1special character',
// //                             suffixIcon: IconButton(
// //                               onPressed: (){
// //                                 setState(() {
// //                                   isPasswordVisible = !isPasswordVisible;
// //                                 });
// //                               },
// //                               icon: Icon(
// //                                 isPasswordVisible ? Icons.visibility : Icons.visibility_off,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                           validator: (value){
// //                             if(value == null || value.isEmpty){
// //                               return 'Password is not Empty';
// //                             }
// //                             else if(!passwordRegex.hasMatch(passwordController.text)){
// //                               return 'Password must contain one number and special character';
// //                             }
// //                             return null;
// //                           },
// //                         ),
// //                         FlutterPwValidator(
// //                             width: 10,
// //                             height: 10,
// //                             minLength: 6,
// //                             specialCharCount: 1,
// //                             numericCharCount: 1,
// //                             onSuccess: onPasswordvalid,
// //                             onFail: onPasswordInvalid,
// //                             controller: passwordController
// //                         ),
// //                         SizedBox(height: 30),
// //                         Text('Confirm Password',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(height: 10),
// //                         TextFormField(
// //                           controller: confirmpasswordController,
// //                           obscureText: !isConfirmPasswordVisible,
// //                           decoration: InputDecoration(
// //                             border: OutlineInputBorder(),
// //                             labelText: 'Confirm the password',
// //                             suffixIcon: IconButton(
// //                               onPressed: (){
// //                                 setState(() {
// //                                   isConfirmPasswordVisible = !isConfirmPasswordVisible;
// //                                 });
// //                               },
// //                               icon: Icon(
// //                                 isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                           validator: (value){
// //                             if(value == null || value.isEmpty){
// //                               return 'Confirm password cannot be Empty';
// //                             }
// //                             else if(value != passwordController.text){
// //                               return 'Password does not match';
// //                             }
// //                             return null;
// //                           },
// //                         ),
// //                         FlutterPwValidator(
// //                             width: 10,
// //                             height: 10,
// //                             minLength: 6,
// //                             specialCharCount: 1,
// //                             numericCharCount: 1,
// //                             onSuccess: onPasswordvalid,
// //                             onFail: onPasswordInvalid,
// //                             controller: passwordController
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 10,),
// //                   SizedBox(
// //                     width: 370,
// //                     height: 50,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         if(formkey.currentState!.validate()){
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: Text('All details are valid')),
// //                           );
// //                           Navigator.push(context,
// //                             MaterialPageRoute(builder: (context) => FirstScreen()),
// //                           );
// //                         }
// //                         else{
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: Text('Please correct the errors')),
// //                           );
// //                         }
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Color(0xFF006064),
// //                         foregroundColor: Colors.white,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(36),
// //                         ),
// //                       ),
// //                       child: Text('Sign Up',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class FirstScreen extends StatefulWidget{
// //   FirstScreenPage createState() => FirstScreenPage();
// // }
// //
// // class FirstScreenPage extends State<FirstScreen>{
// //   final formkey = GlobalKey<FormState>();
// //   final TextEditingController usernameController = TextEditingController();
// //   final TextEditingController emailController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //   final TextEditingController confirmpasswordController = TextEditingController();
// //   final RegExp passwordRegex = RegExp(r'^(?=.[0-9])(?=.[!@#$%^&*(),.?":{}|<>]).+$');
// //   bool isPasswordValid = false;
// //   bool isPasswordVisible = false;
// //   bool isConfirmPasswordVisible = false;
// //
// //   @override
// //   void dispose(){
// //     emailController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   void disposepassword(){
// //     passwordController.dispose();
// //     super.dispose();
// //   }
// //
// //   void onPasswordvalid(){
// //     if(!isPasswordValid){
// //       setState(() {
// //         isPasswordValid = true;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Password is strong!'),
// //             backgroundColor: Colors.green,
// //           ));
// //     }
// //   }
// //
// //   void onPasswordInvalid(){
// //     if(isPasswordValid){
// //       setState(() {
// //         isPasswordValid = false;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Password is weak'),
// //             backgroundColor: Colors.red,
// //           )
// //       );
// //     }
// //   }
// //
// //
// //   @override
// //   Widget build(BuildContext context){
// //     return Scaffold(
// //       appBar: PreferredSize(
// //         preferredSize: Size.fromHeight(150), // Adjust height for image and text
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.vertical(
// //             bottom: Radius.circular(30), // Rounded corners
// //           ),
// //           child: Stack(
// //             children: [
// //               // Background container with image and gradient
// //               Container(
// //                 decoration: BoxDecoration(
// //                   image: DecorationImage(
// //                     image: AssetImage('lib/icons/bi_peace-fill.png'), // Replace with your image path
// //                   ),
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       Color(0xFFE0F7FA),
// //                       Color(0xFF80DEEA)
// //                     ],
// //                     begin: Alignment.topCenter,
// //                     end: Alignment.bottomCenter,
// //                   ),
// //                 ),
// //               ),
// //               // AppBar content
// //               AppBar(
// //                 title: Text(''),
// //                 centerTitle: true,
// //                 backgroundColor: Colors.transparent, // Transparent to show background
// //                 elevation: 0, // Remove shadow for a clean look
// //               ),
// //               // Text at the bottom of the AppBar
// //               Align(
// //                 alignment: Alignment.bottomCenter,
// //                 child: Padding(
// //                   padding: const EdgeInsets.only(bottom:25), // Add some spacing
// //                   child: RichText(
// //                     text: TextSpan(
// //                       children: [
// //                         TextSpan(
// //                           text: 'Welcome ',
// //                           style: TextStyle(
// //                             color: Color(0xFF006064),
// //                             fontSize: 30,
// //                           ),
// //                         ),
// //                         TextSpan(
// //                           text: 'Back!',
// //                           style: TextStyle(
// //                             color: Colors.black,
// //                             fontSize: 30,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             Form(
// //               key: formkey,
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.start,
// //                 children: [
// //                   Padding(
// //                     padding: EdgeInsets.all(16),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         SizedBox(height: 20),
// //                         Text('Email',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(height: 10),
// //                         TextFormField(
// //                           controller: emailController,
// //                           decoration: InputDecoration(
// //                             border: OutlineInputBorder(),
// //                             labelText: 'Email',
// //                           ),
// //                           keyboardType: TextInputType.emailAddress,
// //                           validator: (value){
// //                             if(value == null || value.isEmpty){
// //                               return 'Email cannot be Empty';
// //                             }
// //                             else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
// //                               return "Enter a valid email address";
// //                             }
// //                             return null;
// //                           },
// //                         ),
// //                         SizedBox(height: 30,),
// //                         Text(' Password',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(height: 10,),
// //                         TextFormField(
// //                           controller: passwordController,
// //                           obscureText: !isPasswordVisible,
// //                           decoration: InputDecoration(
// //                             border: OutlineInputBorder(),
// //                             labelText: 'Contain 1number and 1special character',
// //                             suffixIcon: IconButton(
// //                               onPressed: (){
// //                                 setState(() {
// //                                   isPasswordVisible = !isPasswordVisible;
// //                                 });
// //                               },
// //                               icon: Icon(
// //                                 isPasswordVisible ? Icons.visibility : Icons.visibility_off,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                           validator: (value){
// //                             if(value == null || value.isEmpty){
// //                               return 'Password is not Empty';
// //                             }
// //                             else if(!passwordRegex.hasMatch(passwordController.text)){
// //                               return 'Password must contain one number and special character';
// //                             }
// //                             return null;
// //                           },
// //                         ),
// //                         FlutterPwValidator(
// //                             width: 10,
// //                             height: 10,
// //                             minLength: 6,
// //                             specialCharCount: 1,
// //                             numericCharCount: 1,
// //                             onSuccess: onPasswordvalid,
// //                             onFail: onPasswordInvalid,
// //                             controller: passwordController
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 10,),
// //                   SizedBox(
// //                     width: 370,
// //                     height: 50,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         if(formkey.currentState!.validate()){
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: Text('All details are valid')),
// //                           );
// //                           Navigator.push(context,
// //                             MaterialPageRoute(builder: (context) => FirstScreen()),
// //                           );
// //                         }
// //                         else{
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: Text('Please correct the errors')),
// //                           );
// //                         }
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Color(0xFF006064),
// //                         foregroundColor: Colors.white,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(36),
// //                         ),
// //                       ),
// //                       child: Text('Sign Up',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class DoctorCard extends StatelessWidget {
// //   final Doctor doctor;
// //
// //   const DoctorCard({
// //     super.key,
// //     required this.doctor,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       elevation: 0,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         side: BorderSide(color: Colors.grey.shade300),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Row(
// //           children: [
// //             CircleAvatar(
// //               radius: 30,
// //               backgroundImage: AssetImage(doctor.imageUrl),
// //             ),
// //             const SizedBox(width: 16),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     doctor.name,
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     doctor.specialization,
// //                     style: TextStyle(
// //                       color: Colors.grey[600],
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {},
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF00897B),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //               ),
// //               child: const Text(
// //                 'Chat Now',
// //                 style: TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class DoctorsScreen extends StatelessWidget {
// //   const DoctorsScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.lightBlue[100],
// //         elevation: 0,
// //         leading: const Icon(Icons.settings, color: Color(0xFF00897B)),
// //         title: const Text(
// //           'Meet the Doctors',
// //           style: TextStyle(
// //             color: Colors.black87,
// //             fontSize: 20,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         actions: const [
// //           Padding(
// //             padding: EdgeInsets.only(right: 16.0),
// //             child: Icon(Icons.notifications, color: Color(0xFF00897B)),
// //           ),
// //         ],
// //       ),
// //       body: ListView.builder(
// //         padding: const EdgeInsets.all(16),
// //         itemCount: doctors.length,
// //         itemBuilder: (context, index) {
// //           return DoctorCard(doctor: doctors[index]);
// //         },
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         type: BottomNavigationBarType.fixed,
// //         currentIndex: 0,
// //         items: const [
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.home),
// //             label: '',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.calendar_today),
// //             label: '',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.people),
// //             label: '',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.person),
// //             label: '',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class Doctor {
// //   final String name;
// //   final String specialization;
// //
// //   const Doctor({
// //     required this.name,
// //     required this.specialization,
// //   });
// // }
// //
// // final List<Doctor> doctors = [
// //   const Doctor(
// //     name: 'Dr. Sean John',
// //     specialization: 'Neurologist',
// //   ),
// //   const Doctor(
// //     name: 'Dr. Jane Smith',
// //     specialization: 'Psychologist',
// //   ),
// //   const Doctor(
// //     name: 'Dr. Alex Turner',
// //     specialization: 'Psychiatrist',
// //   ),
// //   const Doctor(
// //     name: 'Dr. Maria Khan',
// //     specialization: 'Clinical Psychologist',
// //   ),
// //   const Doctor(
// //     name: 'Dr. John Doe',
// //     specialization: 'Cognitive Therapist',
// //   ),
// // ];
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';
// // import 'package:mental_ease/user/Providers/Auth_Provider/SignUp_Provider.dart';
// // import 'package:mental_ease/user/Providers/Auth_Provider/login_Provider.dart';
// // import 'package:mental_ease/user/Providers/Dashboard_Provider/Dashboard_Provider.dart';
// // import 'package:mental_ease/user/Providers/Profile_Provider/Profile_Provider.dart';
// // import 'package:provider/provider.dart';
// //
// // import 'Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
// // import 'SplashScreen.dart';
// // import 'firebase_options.dart';
// //
// // Future<void> main() async {
// //   runApp(
// //     MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider(create: (_) => SignupProvider()),
// //         ChangeNotifierProvider(create: (_) => AuthProvider()),
// //         ChangeNotifierProvider(create: (_) => DashboardProvider()),
// //         ChangeNotifierProvider(create: (_) => UserProfileProvider()),
// //         ChangeNotifierProvider(create: (_) => PsychologistProvider()),
// //         ChangeNotifierProvider(create: (_) => PsychologistProfileProvider())
// //
// //       ],
// //       child: const MyApp(),
// //     ),
// //   );
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// // }
// //
// // class MyApp extends StatefulWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   State<MyApp> createState() => _MyAppState();
// // }
// //
// // class _MyAppState extends State<MyApp> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return SafeArea(
// //       child: MaterialApp(
// //         theme: ThemeData(
// //           fontFamily: "CustomFont", // Apply font globally
// //         ),
// //         debugShowCheckedModeBanner: false,
// //         home: SplachScreen(),
// //       ),
// //     );
// //   }
// // }
// //
//
//
// //
// //
// // Card(
// // elevation: 4,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(12),
// // ),
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // // Image Section
// // Stack(
// // children: [
// // Container(
// // height: screenHeight * 0.2,
// // decoration: BoxDecoration(
// // borderRadius: const BorderRadius.only(
// // topLeft: Radius.circular(12),
// // topRight: Radius.circular(12),
// // ),
// // image: DecorationImage(
// // image: AssetImage(item.image),
// // fit: BoxFit.cover,
// // ),
// // ),
// // ),
// // // Optional: Add a gradient overlay for text readability
// // Positioned.fill(
// // child: Container(
// // decoration: BoxDecoration(
// // borderRadius: const BorderRadius.only(
// // topLeft: Radius.circular(12),
// // topRight: Radius.circular(12),
// // ),
// // gradient: LinearGradient(
// // colors: [
// // Colors.black.withOpacity(0.2),
// // Colors.black.withOpacity(0.0),
// // ],
// // begin: Alignment.topCenter,
// // end: Alignment.bottomCenter,
// // ),
// // ),
// // ),
// // ),
// // ],
// // ),
// // Padding(
// // padding: const EdgeInsets.all(8.0),
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // // Row for Name and Price
// // Row(
// // mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // children: [
// // // Item Name
// // Expanded(
// // child: Text(
// // item.name,
// // overflow: TextOverflow.ellipsis, // Handle text overflow
// // maxLines: 1, // Limit to a single line
// // style: TextStyle(
// // fontWeight: FontWeight.bold,
// // fontSize: screenHeight * 0.018,
// // ),
// // ),
// // ),
// // SizedBox(height: screenHeight * 0.01),
// // // Price
// // Text(
// // item.price,
// // textAlign: TextAlign.right,
// // style: TextStyle(
// // color: Colors.green,
// // fontSize: screenHeight * 0.016,
// // fontWeight: FontWeight.w600,
// // ),
// // ),
// // ],
// // ),
// // SizedBox(height: screenHeight * 0.001),
// // // Item Description
// // Text(
// // item.description,
// // overflow: TextOverflow.ellipsis, // Handle text overflow
// // maxLines: 1, // Limit description to 2 lines
// // style: TextStyle(
// // color: Colors.grey,
// // fontSize: screenHeight * 0.015,
// // ),
// // ),
// //
// // SizedBox(height: screenHeight * 0.005),
// // // Row for Item Sold and Rating
// // Row(
// // mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // children: [
// // // Sold Items
// // Text(
// // '${item.soldItem} Sold',
// // overflow: TextOverflow.ellipsis,
// // maxLines: 1,
// // style: TextStyle(
// // fontWeight: FontWeight.bold,
// // color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
// // fontSize: screenHeight * 0.015,
// // ),
// // ),
// //
// // // Rating Stars
// // Row(
// // children: List.generate(5, (index) {
// // if (index < item.rating.floor()) {
// // // Full star
// // return Icon(
// // Icons.star,
// // color: Colors.orange,
// // size: screenHeight * 0.02,
// // );
// // } else if (index < item.rating) {
// // // Half star
// // return Icon(
// // Icons.star_half,
// // color: Colors.orange,
// // size: screenHeight * 0.02,
// // );
// // } else {
// // // Empty star
// // return Icon(
// // Icons.star_border,
// // color: Colors.orange,
// // size: screenHeight * 0.02,
// // );
// // }
// // }),
// // ),
// // ],
// // ),
// // ],
// // ),
// // ),
// // ],
// // ),
// // ),
//
//
//
//
//
//
//
// import 'dart:io';
// import 'dart:math';
//
// import 'package:app_settings/app_settings.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationServices{
//
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   Future<void> requestNotificationPermission() async {
//
//     NotificationSettings settings = await messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true
//     );
//     if(settings.authorizationStatus == AuthorizationStatus.authorized){
//       print("User granted permission");
//
//     }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
//       print("User granted provisional permission");
//
//     }else {
//       AppSettings.openAppSettings();
//       print("User denied permission");
//
//     }
//
//   }
//
//
//
//   Future<void> initLocalNotifications(BuildContext context, RemoteMessage message) async {
//
//     var androidInitialization = AndroidInitializationSettings("@mipmap/ic_launcher");
//     var iosInitialilization = DarwinInitializationSettings();
//     var initializationSettings = InitializationSettings(
//
//       android: androidInitialization,
//       iOS: iosInitialilization,
//
//     );
//
//     await _flutterLocalNotificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: (payload){
//
//         }
//     );
//   }
//
//   void firebaseInit(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((message) {
//
//       if (Platform.isAndroid) {
//         initLocalNotifications(context, message);
//         showNotification(message);
//       }
//     });
//   }
//
//
//
//   Future<void> showNotification (RemoteMessage message) async{
//
//     AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
//         Random.secure().nextInt(10000).toString(),
//         "High importance Notification",
//         importance: Importance.max
//     );
//
//     AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//         androidNotificationChannel.id.toString(),
//         androidNotificationChannel.name.toString(),
//         channelDescription: 'My channel Description',
//         importance: Importance.high,
//         priority: Priority.high,
//         ticker: 'ticker'
//     );
//
//
//     DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     NotificationDetails notificationDetails = NotificationDetails(
//         android: androidNotificationDetails,
//         iOS: darwinNotificationDetails
//     );
//
//     Future.delayed(Duration.zero,
//             (){
//           _flutterLocalNotificationsPlugin.show(
//               0,
//               message.notification?.title.toString(),
//               message.notification?.body.toString(),
//               notificationDetails
//           );
//         }
//     );
//
//   }
//
//   Future<String?> getDeviceToken() async{
//     String? token = await messaging.getToken();
//     return token;
//   }
//
//   void isTokenRefresh () async{
//     messaging.onTokenRefresh.listen((event){
//       event.toString();
//       print("refresh");
//     });
//
//
//   }
//
//
//
//
//
// }
//
// Image.asset(
// 'assets/images/hi.png', // Ensure correct asset path
// width: MediaQuery.of(context).size.width * 0.15,
// height: MediaQuery.of(context).size.width * 0.15,
// fit: BoxFit.cover,
// errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 50),
// )




// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'dart:async';
//
// import 'Video_Call_Service.dart';
//
// class callPage extends StatefulWidget {
//   final String? channelName;
//   final String? role;
//   final String? DoctorId;
//
//   callPage(this.channelName, this.role, this.DoctorId);
//
//   @override
//   State<callPage> createState() => _callPageState();
// }
//
// class _callPageState extends State<callPage> {
//   final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   bool viewPanel = false;
//   late RtcEngine _engine;
//   String channelId  = 'call_464yLmzMzJeHsymcFkMGbIIKqUJ2_Xd4evN6WJ6PHlba3nBMrBEVt3O42';
//   final _uid = FirebaseAuth.instance.currentUser?.uid;
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');
//   String? role;
//   bool isSubmitting = false;
//
//
//   // Position for the floating local video
//   Offset _localVideoPosition = Offset(20, 80);
//   bool _isLocalVideoDragging = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initialize();
//   }
//
//   @override
//   void dispose() {
//     _users.clear();
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }
//
//   Future<void> initialize() async {
//     DatabaseEvent event = await _dbRef.child(_uid!).child("role").once();
//     role = event.snapshot.value.toString();
//     if (appId.isEmpty) {
//       setState(() {
//         _infoStrings.add("App Id is missing Please Provide App Id in Video_Call_Service.dart");
//         _infoStrings.add("Agora Engine is not starting");
//       });
//       return;
//     }
//
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: appId,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));
//
//     await _engine.enableVideo();
//     await _engine.enableAudio();
//     await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     _addAgoraEventHandlers();
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration(
//       dimensions: VideoDimensions(width: 1920, height: 1080),
//     );
//     await _engine.setVideoEncoderConfiguration(configuration);
//     await _engine.joinChannel(
//       token: token,
//       channelId: "Mental Ease",
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }
//
//   void _addAgoraEventHandlers() {
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onError: (err, msg) {
//           setState(() {
//             _infoStrings.add(msg.toString());
//           });
//         },
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           final info = 'connection created $connection';
//           setState(() {
//             _infoStrings.add(info);
//           });
//         },
//         onLeaveChannel: (RtcConnection, stats) {
//           setState(() {
//             _infoStrings.add("Leave channel");
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           setState(() {
//             final info = 'user joined $remoteUid';
//             _infoStrings.add(info);
//             _users.add(remoteUid);
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
//           setState(() {
//             final info = 'user offline $remoteUid';
//             _infoStrings.add(info);
//             _users.remove(remoteUid);
//           });
//           if (_users.isEmpty) {
//             Future.delayed(Duration(seconds: 5), () {
//               _endCall();
//             });
//           }
//         },
//         onFirstRemoteVideoFrame: (RtcConnection connection, int uid, int elapsed, int width, int height) {
//           setState(() {
//             final info = 'First remote Video $uid ${width} x ${height}';
//             _infoStrings.add(info);
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _viewRows() {
//     return Stack(
//       children: [
//         // Remote video (full screen)
//         if (_users.isNotEmpty)
//           Positioned.fill(
//             child: AgoraVideoView(
//               controller: VideoViewController.remote(
//                 rtcEngine: _engine,
//                 canvas: VideoCanvas(uid: _users.first),
//                 connection: RtcConnection(channelId: "Mental Ease" ?? "default_channel"),
//               ),
//             ),
//           ),
//         // Floating local video
//         if (widget.role == "broadcaster")
//           Positioned(
//             left: _localVideoPosition.dx,
//             top: _localVideoPosition.dy,
//             child: GestureDetector(
//               onPanStart: (details) {
//                 setState(() {
//                   _isLocalVideoDragging = true;
//                 });
//               },
//               onPanUpdate: (details) {
//                 setState(() {
//                   _localVideoPosition += details.delta;
//                 });
//               },
//               onPanEnd: (details) {
//                 setState(() {
//                   _isLocalVideoDragging = false;
//                 });
//               },
//               child: Container(
//                 width: 120,
//                 height: 180,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _isLocalVideoDragging ? Colors.blue : Colors.white,
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine,
//                       canvas: const VideoCanvas(uid: 0),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _toolbar() {
//     return widget.role == "audience"
//         ? Container()
//         : Container(
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           _buildToolbarButton(
//             icon: muted ? Icons.mic_off : Icons.mic,
//             color: muted ? Colors.red : Colors.blue,
//             onPressed: () {
//               setState(() {
//                 muted = !muted;
//               });
//               _engine.muteLocalAudioStream(muted);
//             },
//           ),
//           _buildToolbarButton(
//             icon: Icons.call_end,
//             color: Colors.red,
//             onPressed: _endCall,
//             size: 56,
//           ),
//           _buildToolbarButton(
//             icon: Icons.cameraswitch,
//             color: Colors.blue,
//             onPressed: () {
//               _engine.switchCamera();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildToolbarButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//     double size = 48,
//   }) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(icon, color: color, size: size * 0.6),
//         onPressed: onPressed,
//         padding: EdgeInsets.zero,
//       ),
//     );
//   }
//
//   void _endCall() {
//     _engine.leaveChannel();
//
//     if (role == 'user') {
//       // Show feedback first
//       _showFeedbackPrompt().then((_) {
//         if (mounted) {
//           Navigator.pop(context);
//         }
//       });
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   Future<void> _showFeedbackPrompt() async {
//     bool? wantFeedback = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Session Completed"),
//           content: Text("Would you like to provide feedback about your session?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text("Yes"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text("No"),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (wantFeedback == true && mounted) {
//       await _showFeedbackForm();
//     }
//   }
//
//   Future<void> _showFeedbackForm() async {
//     double rating = 3.0;
//     TextEditingController feedbackController = TextEditingController();
//     bool isSubmitting = false;
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text("Feedback"),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("How would you rate your session?"),
//                     SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(5, (index) => Icon(
//                         Icons.star,
//                         color: rating >= index + 1 ? Colors.amber : Colors.grey,
//                       )),
//                     ),
//                     Slider(
//                       value: rating,
//                       min: 1,
//                       max: 5,
//                       divisions: 4,
//                       onChanged: (value) => setState(() => rating = value),
//                     ),
//                     SizedBox(height: 20),
//                     Text("Share your experience:"),
//                     TextField(
//                       controller: feedbackController,
//                       maxLines: 4,
//                       maxLength: 300,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         hintText: "How was your session?",
//                       ),
//                     ),
//                     if (isSubmitting) CircularProgressIndicator(),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
//                   child: Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: isSubmitting ? null : () async {
//                     setState(() => isSubmitting = true);
//                     await _submitFeedback(rating, feedbackController.text);
//                     setState(() => isSubmitting = false);
//                     Navigator.of(context).pop();
//                   },
//                   child: Text("Submit"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _submitFeedback(double newRating, String feedback) async {
//     try {
//       setState(() => isSubmitting = true);
//
//       // 1. Get references
//       final doctorRef = _dbRef.child(widget.DoctorId!);
//       final userRef = _dbRef.child(_uid!);
//
//       // 2. Fetch current user data
//       final userSnapshot = await userRef.get();
//       if (!userSnapshot.exists) {
//         throw Exception('User profile not found');
//       }
//
//       final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
//       final username = userData['username']?.toString() ?? 'Anonymous';
//
//       // 3. Generate unique key for new feedback
//       final newFeedbackKey = doctorRef.child('feedbacks').push().key;
//       if (newFeedbackKey == null) {
//         throw Exception('Could not generate feedback key');
//       }
//
//       // 4. Create feedback object with timestamp
//       final feedbackData = <String, dynamic>{
//         'ratings': newRating,  // Changed from 'ratings' to 'rating' for consistency
//         'comment': feedback,
//         'userId': _uid,
//         'username': username,
//         'timestamp': ServerValue.timestamp,
//       };
//
//       // 5. Prepare updates - adds new feedback while preserving old ones
//       final updates = <String, dynamic>{
//         'feedbacks/$newFeedbackKey': feedbackData,
//       };
//
//       // 6. Calculate new average rating including this feedback
//       final doctorSnapshot = await doctorRef.get();
//       final doctorData = Map<String, dynamic>.from(doctorSnapshot.value as Map? ?? {});
//
//       // Get current average rating (safe parsing)
//       double currentAverageRating = 0.0;
//       if (doctorData['ratings'] != null) {
//         currentAverageRating = (doctorData['ratings'] is num)
//             ? (doctorData['ratings'] as num).toDouble()
//             : double.tryParse(doctorData['rating'].toString()) ?? 0.0;
//       }
//
//       // Get all existing feedbacks
//       final existingFeedbacks = doctorData['feedbacks'] as Map<dynamic, dynamic>? ?? {};
//       final allRatings = [
//         newRating,
//         ...existingFeedbacks.values.map((f) {
//           return (f['ratings'] is num)
//               ? (f['ratings'] as num).toDouble()
//               : double.tryParse(f['ratings'].toString()) ?? 0.0;
//         })
//       ];
//
//       // Calculate new average
//       final updatedRating = (newRating+currentAverageRating) /2;
//       updates['ratings'] = updatedRating.toString();
//
//       // 7. Perform the update
//       await doctorRef.update(Map<String, Object?>.from(updates));
//
//       // 8. Show confirmation
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Thank you for your feedback!"))
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error: ${e.toString()}"))
//         );
//       }
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Call - ${widget.channelName ?? ''}'),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: <Widget>[
//             _viewRows(),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 30,
//               child: _toolbar(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


List<Map<String,dynamic>> questionsList = [
  {
    'question': 'I found myself getting upset by quite trivial things.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I was aware of dryness of my mouth.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I could not seem to experience any positive feeling at all.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I experienced breathing difficulty (eg, excessively rapid breathing,)',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I just couldn&#39;t seem to get going.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I tended to over-react to situations.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I had a feeling of shakiness (eg, legs going to give way).',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I found it difficult to relax.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I found myself in situations that made me so anxious I was most relieved when they ended.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I felt that I had nothing to look forward to.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I found myself getting upset rather easily.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I felt that I was using a lot of nervous energy.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I felt sad and depressed.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I found myself getting impatient when I was delayed in any way (eg, elevators, traffic lights)',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question' : 'I had a feeling of faintness.',
    'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
  },
  {
    'question': 'I felt that I had lost interest in just about everything.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': "I felt I wasn't worth much as a person.",
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt that I was rather touchy.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I perspired noticeably in the absence of high temperatures or physical exertion.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt scared without any good reason.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': "I felt that life wasn't worthwhile.",
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I found it hard to wind down.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I had difficulty in swallowing.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': "I couldn't seem to get any enjoyment out of the things I did.",
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I was aware of the action of my heart in the absence of physical exertion .',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt down-hearted and blue.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I found that I was very irritable.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt I was close to panic.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I found it hard to calm down after something upset me.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I feared that I would be "thrown" by some trivial but unfamiliar task.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I was unable to become enthusiastic about anything.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I found it difficult to tolerate interruptions to what I was doing.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I was in a state of nervous tension.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt I was pretty worthless.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I was intolerant of anything that kept me from getting on with what I was doing.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt terrified.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I could see nothing in the future to be hopeful about.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I felt that life was meaningless.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I found myself getting agitated.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I was worried about situations in which I might panic and make a fool of myself.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I experienced trembling (eg, in the hands).',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question': 'I found it difficult to work up the initiative to do things.',
    'options': [
      'Did not apply to me at all',
      'Applied to me to some degree, or some of the time',
      'Applied to me to a considerable degree, or a good part of the time',
      'Applied to me very much, or most of the time'
    ],
  },
  {
    'question' : 'Extraverted, enthusiastic.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },

  {
    'question' : 'Critical, quarrelsome.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Dependable, self-disciplined.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Anxious, easily upset.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Open to new experiences, complex',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Reserved, quiet.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Sympathetic, warm.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Disorganized, careless.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Calm, emotionally stable.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'Conventional, uncreative.',
    'options': [
      'Disagree strongly',
      'Disagree moderately',
      'Disagree a little',
      'Neither agree nor disagree',
      'Agree a little',
      'Agree moderately',
      'Agree strongly',
    ]
  },
  {
    'question' : 'How much education have you completed?',
    'options': [
      'Less than high school',
      'High school',
      'University degree',
      'Graduate degree',

    ]
  },
  {
    'question' : 'What type of area did you live when you were a child?',
    'options': [
      'Rural (country side)',
      'Suburban',
      'Urban (town, city)',
    ]
  },
  {
    'question' : 'What is your gender?',
    'options': [
      'Male',
      'Female',
      'Other',
    ]
  },

  {
    'question' : 'How many years old are you?',
    'isTextInput': true,
    'inputType' : 'number'
  },
  {
    'question' : 'What is your religion?',
    'options': [
      'Hindu',
      'Jewish',
      'Muslim',
      'Buddhist',
      'Atheist',
      'Agnostic',
      'Christian (Other)',
      'Christian (Protestant)',
      'Christian (Mormon)',
      'Christian (Catholic)',
      'Sikh',
      'Other',
    ]
  },
  {
    'question' : 'What is your race?',
    'options': [
      'Asian',
      'Arab',
      'Black',
      'Indigenous Australian',
      'Native American',
      'White',
      'Other'
    ]
  },

  {
    'question' : 'What is your marital status?',
    'options': [
      'married	',
      'Never married',
      'Currently married',
      'Previously married',
    ]
  },
  {
    'question' : 'Including you, how many children did your mother have?',
    'isTextInput': true,
    'inputType' : 'number'
  },

];