import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/Login.dart';
import 'package:mental_ease/user/Providers/Auth_Provider/SignUp_Provider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  final RegExp passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String role = "user"; // Default role

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Signupprovider = Provider.of<SignupProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bi_peace-fill.png'),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 18),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Create ',
                          style: TextStyle(
                            fontFamily: 'CustomFont',
                            color: Color(0xFF006064),
                            fontSize: 30,
                          ),
                        ),
                        TextSpan(
                          text: 'an ',
                          style: TextStyle(
                            fontFamily: 'CustomFont',
                            color: Color(0xFF006064),
                            fontSize: 30,
                          ),
                        ),
                        TextSpan(
                          text: 'Account',
                          style: TextStyle(
                            fontFamily: 'CustomFont',
                            color: Colors.black,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 20, bottom: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Name", "Enter your name", usernameController),
                  _buildTextField("Email", "Enter your email", emailController, isEmail: true),
                  _buildPasswordField("Password", "password", passwordController),
                  _buildPasswordField("Confirm Password", "Confirm password", confirmpasswordController, isConfirm: true),


                  // Role selection
                  Text("Select Role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Center(
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: Color(0xFF006064),
                      color: Colors.black,
                      isSelected: [role == "user", role == "Psychologist"],
                      onPressed: (int index) {
                        setState(() {
                          role = index == 0 ? "user" : "Psychologist";
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("user"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("Psychologist"),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Signupprovider.signUpUser(
                              username: usernameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              role: role, // Pass role to the signup function
                              context: context,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please correct the errors')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF006064),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                        ),
                        child: Signupprovider.isLoading ? CircularProgressIndicator(color: Colors.white,) : Text('Sign Up', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return LoginPage();
                      }));
                    },
                    child: Text("Already Have an Account? Login",style: TextStyle(color: Color(0xFF006064)),),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),), labelText: hint),
            validator: (value) {
              if (value == null || value.isEmpty) return '$label cannot be empty';
              if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email address";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, {bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isConfirm ? !isConfirmPasswordVisible : !isPasswordVisible,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),),
              labelText: hint,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    } else {
                      isPasswordVisible = !isPasswordVisible;
                    }
                  });
                },
                icon: Icon(
                  isConfirm ? (isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off) :
                  (isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  color: Colors.black,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return '$label cannot be empty';
              if (!isConfirm && !passwordRegex.hasMatch(value)) return 'Password must contain one number and one special character';
              if (isConfirm && value != passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
