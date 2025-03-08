import 'package:flutter/material.dart';
import 'package:mental_ease/user/UserDashboard.dart';
import 'package:provider/provider.dart';

import '../Auth_Provider/login_Provider.dart';
import 'Providers/Profile_Provider/Profile_Provider.dart';


class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    HomeScreen();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      await provider.getUserInfo();
      _nameController.text = provider.userName ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProfileProvider>(context);
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(size.height * 0.03)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/hi.png',
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 50),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hi, Welcome! ',
                                style: TextStyle(
                                  color: Color(0xFF006064),
                                  fontSize: size.height * 0.028,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: provider.userName ?? "Guest",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.height * 0.028,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      width: size.width * 0.7,
                      child: Divider(thickness: 2, height: size.width * 0.035),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.03),
              _buildListTile("Email", provider.email ?? "Loading...", Icons.edit, () => _showEditNameDialog(provider)),
              Divider(),
              _buildListTile("Name", provider.userName ?? "Loading...", Icons.edit, () => _showEditNameDialog(provider)),
              Divider(),
              _buildListTile("Change Password", "", Icons.edit, () => _showChangePasswordDialog(provider)),
              Divider(),
              _buildListTile("Sign out", "", Icons.exit_to_app, () async => await authProvider.signOut(context), isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE0F7FA),
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing:Icon( title != 'Email'?icon: null, color: isLogout ? Colors.red : null),
        onTap:title == 'Email'? null: onTap,
      ),
    );
  }

  void _showEditNameDialog(UserProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Name",style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),),
        content: TextField(controller: _nameController, decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),),
          labelText: 'Name',

        ),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF006064)
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
              await provider.updateUserName(_nameController.text, context);
              Navigator.pop(context);
            },
            child: provider.isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(UserProfileProvider provider) {
    final RegExp passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');
    bool _obscureCurrent = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Change Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current Password Field
                TextField(
                  controller: _currentPassController,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),),
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                      icon: Icon(
                        _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 5,),
                // New Password Field
                TextFormField(
                  controller: _newPassController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),),
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                      icon: Icon(
                        _obscureNew ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'password cannot be empty';
                    else if (!passwordRegex.hasMatch(value)) return 'Password must contain one number and one special character';
                    return null;
                  },
                ),
                SizedBox(height: 5,),
                // Confirm New Password Field
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: _obscureConfirm,
                  decoration:InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),),
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm password cannot be empty';
                    else if (!passwordRegex.hasMatch(value)) return 'Password must contain one number and one special character';
                    else if (value != _newPassController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  _newPassController.text = '';
                  _currentPassController.text = '';
                  _confirmPassController.text = '';
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF006064),
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                  if ((_newPassController.text != _confirmPassController.text)||_newPassController.text.isEmpty||_confirmPassController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Passwords do not match")),
                    );
                    return;
                  }
                  await provider.changePassword(_currentPassController.text, _newPassController.text);
                  _newPassController.text = '';
                  _currentPassController.text = '';
                  _confirmPassController.text = '';
                  Navigator.pop(context);
                },
                child: provider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }
}
