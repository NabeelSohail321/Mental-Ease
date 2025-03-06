import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';

class PsychologistProfileScreen extends StatefulWidget {
  @override
  _PsychologistProfileScreenState createState() => _PsychologistProfileScreenState();
}

class _PsychologistProfileScreenState extends State<PsychologistProfileScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _degreeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<PsychologistProfileProvider>().fetchProfileData();
    });
  }

  Future<void> _pickImage(String fieldName) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await context.read<PsychologistProfileProvider>().uploadImage(fieldName, pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PsychologistProfileProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Psychologist Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileSection(provider, size),
            SizedBox(height: 20),
            _buildTextField(_descriptionController, provider.description, 'Description'),
            _buildTextField(_phoneNumberController, provider.phoneNumber, 'Phone Number'),
            _buildTextField(_addressController, provider.address, 'Address'),
            _buildTextField(_degreeNameController, provider.degreeName, 'Degree Name'),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                provider.updateProfileData(
                  description: _descriptionController.text,
                  phoneNumber: _phoneNumberController.text,
                  address: _addressController.text,
                  degreeName: _degreeNameController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile Updated')));
              },
              child: Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(PsychologistProfileProvider provider, Size size) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage:
              provider.profileImageUrl != null ? NetworkImage(provider.profileImageUrl!) : null,
              child: provider.profileImageUrl == null ? Icon(Icons.person, size: 80, color: Colors.grey) : null,
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.teal),
              onPressed: () => _pickImage('profileImageUrl'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text('Edit Profile Image', style: TextStyle(color: Colors.teal)),
        SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            provider.degreeImageUrl != null
                ? Image.network(
              provider.degreeImageUrl!,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.school, size: 80),
            )
                : Icon(Icons.school, size: 80, color: Colors.grey),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.teal),
              onPressed: () => _pickImage('degreeImageUrl'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text('Edit Degree Image', style: TextStyle(color: Colors.teal)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String? initialValue, String label) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
