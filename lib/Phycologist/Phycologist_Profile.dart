import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
import 'package:mental_ease/Auth_Provider/login_Provider.dart' as MyAuthProvider;

class PsychologistProfileScreen extends StatefulWidget {
  @override
  _PsychologistProfileScreenState createState() => _PsychologistProfileScreenState();
}

class _PsychologistProfileScreenState extends State<PsychologistProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _clinicTimingController = TextEditingController();
  final TextEditingController _weekDaysController = TextEditingController();
  final TextEditingController _appointmentFeeController = TextEditingController();
  final TextEditingController _stripeIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<String> _selectedDays = [];
  List<String> _selectedDegrees = [];
  Map<String, List<TimeOfDay>> _onlineTimeSlots = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<PsychologistProfileProvider>().fetchProfileData(FirebaseAuth.instance.currentUser!.uid).then((_) {
        final provider = context.read<PsychologistProfileProvider>();
        if (provider.clinicTiming != null) {
          _clinicTimingController.text = provider.clinicTiming!;
          final times = provider.clinicTiming!.split(' - ');
          if (times.length == 2) {
            _startTime = _parseTime(times[0]);
            _endTime = _parseTime(times[1]);
          }
        }
        if (provider.weekDays != null) {
          _weekDaysController.text = provider.weekDays!;
          _selectedDays = provider.weekDays!.split(', ');
        }
        if (provider.degrees != null) {
          _selectedDegrees = provider.degrees!;
        }
        if (provider.onlineTimeSlots != null) {
          setState(() {
            _onlineTimeSlots = provider.onlineTimeSlots!;
          });
        }
      });
    });
  }





  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage(String fieldName) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await context.read<PsychologistProfileProvider>().uploadImage(fieldName, pickedFile);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _startTime ?? TimeOfDay.now() : _endTime ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isStartTime ? 'Select Start Time' : 'Select End Time',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Divider(
                  thickness: 4,
                ),
              ),
              if (child != null) child,
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        if (_startTime != null && _endTime != null) {
          _clinicTimingController.text = '${_startTime!.format(context)} - ${_endTime!.format(context)}';
        }
      });
    }
  }

  void _selectDays() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Days'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                      return CheckboxListTile(
                        title: Text(day),
                        value: _selectedDays.contains(day),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              if (!_selectedDays.contains(day)) {
                                _selectedDays.add(day);
                              }
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _weekDaysController.text = _selectedDays.join(', ');
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addDegree(String degree) {
    if (_selectedDegrees.length < 5 && !_selectedDegrees.contains(degree)) {
      setState(() {
        _selectedDegrees.add(degree);
      });
    }
  }

  void _removeDegree(String degree) {
    setState(() {
      _selectedDegrees.remove(degree);
    });
  }

  Future<void> _selectDayAndTimeSlots() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 35)),
    );

    if (selectedDate != null) {
      final String dateKey = selectedDate.toIso8601String().split('T')[0];
      if (_onlineTimeSlots.containsKey(dateKey)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Time slots already added for this day')),
        );
        return;
      }

      // Ask how many slots the user wants to add (1-6)
      final int? slotCount = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          int selectedCount = 1;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Select Number of Time Slots'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('How many time slots do you want to add for this day?'),
                    SizedBox(height: 20),
                    DropdownButton<int>(
                      value: selectedCount,
                      items: List.generate(6, (index) => index + 1)
                          .map((count) => DropdownMenuItem(
                        value: count,
                        child: Text('$count slot${count > 1 ? 's' : ''}'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedCount = value!);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedCount),
                    child: Text('Confirm'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (slotCount == null || slotCount < 1) return;

      final List<TimeOfDay> timeSlots = [];
      TimeOfDay? lastSelectedTime;

      for (int i = 0; i < slotCount; i++) {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: lastSelectedTime ?? TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Time Slot ${i + 1}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (child != null) child,
                ],
              ),
            );
          },
        );

        if (selectedTime != null) {
          // Validate the selected time
          final now = DateTime.now();
          final selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          // Check if time is in the future
          if (selectedDateTime.isBefore(now)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected time must be in the future')),
            );
            continue;
          }

          // Check 3-hour gap from previous slot if exists
          if (lastSelectedTime != null) {
            final prevTimeInMinutes = lastSelectedTime.hour * 60 + lastSelectedTime.minute;
            final currentTimeInMinutes = selectedTime.hour * 60 + selectedTime.minute;

            if (currentTimeInMinutes < prevTimeInMinutes + 180) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Time slots must have at least 3 hours gap')),
              );
              continue;
            }
          }

          // Check if time already exists
          if (timeSlots.any((slot) =>
          slot.hour == selectedTime.hour &&
              slot.minute == selectedTime.minute)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('This time slot is already selected')),
            );
            continue;
          }

          timeSlots.add(selectedTime);
          lastSelectedTime = selectedTime;
        } else {
          break; // User canceled time selection
        }
      }

      if (timeSlots.isNotEmpty) {
        setState(() {
          _onlineTimeSlots[dateKey] = timeSlots;
        });
      }
    }
  }


  void _removeSlot(String dateKey) {
    setState(() {
      _onlineTimeSlots.remove(dateKey);
    });
  }

  void _editSlot(String dateKey) async {
    final List<TimeOfDay>? updatedSlots = await showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<TimeOfDay> slots = List.from(_onlineTimeSlots[dateKey]!);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Time Slots for $dateKey'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ...slots.asMap().entries.map((entry) {
                      final index = entry.key;
                      final slot = entry.value;
                      return ListTile(
                        title: Text(slot.format(context)),
                        subtitle: index > 0
                            ? Text('${_calculateTimeDifference(slots[index-1], slot)} gap from previous')
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              slots.removeAt(index);
                            });
                          },
                        ),
                      );
                    }).toList(),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? lastTime = slots.isNotEmpty ? slots.last : null;
                        final TimeOfDay? newSlot = await showTimePicker(
                          context: context,
                          initialTime: lastTime ?? TimeOfDay.now(),
                        );

                        if (newSlot != null) {
                          // Validate the new slot
                          final now = DateTime.now();
                          final selectedDate = DateTime.parse(dateKey);
                          final selectedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            newSlot.hour,
                            newSlot.minute,
                          );

                          if (selectedDateTime.isBefore(now)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected time must be in the future')),
                            );
                            return;
                          }

                          if (lastTime != null) {
                            final lastTimeInMinutes = lastTime.hour * 60 + lastTime.minute;
                            final newTimeInMinutes = newSlot.hour * 60 + newSlot.minute;

                            if (newTimeInMinutes < lastTimeInMinutes + 180) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Time slots must have at least 3 hours gap')),
                              );
                              return;
                            }
                          }

                          if (slots.any((slot) =>
                          slot.hour == newSlot.hour &&
                              slot.minute == newSlot.minute)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('This time slot is already selected')),
                            );
                            return;
                          }

                          setState(() {
                            slots.add(newSlot);
                          });
                        }
                      },
                      child: Text('Add New Slot'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(slots);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedSlots != null && updatedSlots.isNotEmpty) {
      setState(() {
        _onlineTimeSlots[dateKey] = updatedSlots;
      });
    } else if (updatedSlots != null && updatedSlots.isEmpty) {
      setState(() {
        _onlineTimeSlots.remove(dateKey);
      });
    }
  }

  String _calculateTimeDifference(TimeOfDay earlier, TimeOfDay later) {
    final earlierMinutes = earlier.hour * 60 + earlier.minute;
    final laterMinutes = later.hour * 60 + later.minute;
    final difference = laterMinutes - earlierMinutes;

    if (difference < 60) {
      return '$difference minutes';
    } else {
      final hours = difference ~/ 60;
      final minutes = difference % 60;
      return minutes > 0
          ? '$hours hours $minutes minutes'
          : '$hours hours';
    }
  }

  Widget _buildOnlineTimeSlotsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF006064),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36),
              ),
          ),
          onPressed: _selectDayAndTimeSlots,
          child: Text('Add Online Time Slots',style: TextStyle(fontSize: 16),),
        ),
        SizedBox(height: 10),
        ..._onlineTimeSlots.entries.map((entry) {
          final dateKey = entry.key;
          final timeSlots = entry.value;
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text('Date: $dateKey'),
              subtitle: Text('Time Slots: ${timeSlots.map((time) => time.format(context)).join(', ')}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editSlot(dateKey),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeSlot(dateKey),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  bool _validateFields() {
    final provider = context.read<PsychologistProfileProvider>();

    // Check text fields
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _selectedDegrees.isEmpty ||
        _specializationController.text.isEmpty ||
        _experienceController.text.isEmpty ||
        _clinicTimingController.text.isEmpty ||
        _weekDaysController.text.isEmpty ||
        _appointmentFeeController.text.isEmpty ||
        _stripeIdController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All text fields are required')),
      );
      return false;
    }

    // Check images
    if (provider.profileImageUrl == null || provider.profileImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image is required')),
      );
      return false;
    }

    if (provider.degreeImageUrl == null || provider.degreeImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Degree image is required')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PsychologistProfileProvider>();
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context);

    final bool isFormComplete =
        _nameController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _phoneNumberController.text.isNotEmpty &&
            _selectedDegrees.isNotEmpty &&
            _specializationController.text.isNotEmpty &&
            _experienceController.text.isNotEmpty &&
            _clinicTimingController.text.isNotEmpty &&
            _weekDaysController.text.isNotEmpty &&
            _appointmentFeeController.text.isNotEmpty &&
            _stripeIdController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            provider.profileImageUrl != null &&
            provider.profileImageUrl!.isNotEmpty &&
            provider.degreeImageUrl != null &&
            provider.degreeImageUrl!.isNotEmpty;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(size.height * 0.03)),
          child: Container(
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Complete your ',
                          style: TextStyle(
                            color: Color(0xFF006064),
                            fontSize: size.height * 0.035,
                            fontWeight: FontWeight.bold,
                            fontFamily: "CustomFont",
                          ),
                        ),
                        TextSpan(
                          text: 'Profile',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: size.height * 0.035,
                            fontWeight: FontWeight.bold,
                            fontFamily: "CustomFont",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Divider(thickness: 2, indent: 50, endIndent: 50),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          authProvider.signOut(context);
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.logout, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileSection(provider),
            SizedBox(height: 20),
            _buildTextField(_nameController, provider.name, 'Name', Icons.person),
            _buildAddressField(_addressController, provider.address, 'Clinic Address', Icons.location_on),
            _buildTextField(_phoneNumberController, provider.phoneNumber, 'Phone Number', Icons.phone, isNumeric: true),
            SizedBox(height: 10),
            _buildEmailField(provider.email, 'Email', Icons.email),
            _buildDegreeField(),
            _buildTextField(_specializationController, provider.specialization, 'Specialization', Icons.work),
            Row(
              children: [
                Expanded(child: _buildTextField(_experienceController, provider.experience, 'Experience (Years)', Icons.timeline, isNumeric: true)),
                SizedBox(width: 10),
                Expanded(child: _buildClinicTimingField()),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildWeekDaysField()),
                SizedBox(width: 10),
                Expanded(child: _buildTextField(_appointmentFeeController, provider.appointmentFee, 'Appointment Fee', Icons.attach_money, isNumeric: true)),
              ],
            ),
            SizedBox(height: 10),
            _buildTextField(_stripeIdController, provider.stripeId, 'Stripe Account ID', Icons.account_balance),
            SizedBox(height: 10),
            _buildDescriptionField(_descriptionController, provider.description, 'Description', Icons.description),
            _buildOnlineTimeSlotsField(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormComplete ? Color(0xFF006064) : Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              onPressed: isFormComplete ? () {
                if (_validateFields()) {
                  provider.updateProfileData(
                    name: _nameController.text,
                    address: _addressController.text,
                    phoneNumber: _phoneNumberController.text,
                    degrees: _selectedDegrees,
                    specialization: _specializationController.text,
                    experience: _experienceController.text,
                    clinicTiming: _clinicTimingController.text,
                    weekDays: _weekDaysController.text,
                    appointmentFee: _appointmentFeeController.text,
                    stripeId: _stripeIdController.text,
                    description: _descriptionController.text,
                    onlineTimeSlots: _onlineTimeSlots,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile Updated')),
                  );
                }
              } : null,
              child: Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(PsychologistProfileProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImageContainer(
          imageUrl: provider.profileImageUrl,
          placeholderIcon: Icons.person,
          onTap: () => _pickImage('profileImageUrl'),
          label: 'Profile Image',
        ),
        SizedBox(width: 20),
        _buildImageContainer(
          imageUrl: provider.degreeImageUrl,
          placeholderIcon: Icons.school,
          onTap: () => _pickImage('degreeImageUrl'),
          label: 'Latest Degree Image',
        ),
      ],
    );
  }

  Widget _buildDegreeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _degreeController,
          decoration: InputDecoration(
            labelText: 'Add Degree',
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_degreeController.text.isNotEmpty) {
                  _addDegree(_degreeController.text);
                  _degreeController.clear();
                }
              },
            ),
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: _selectedDegrees.map((degree) {
            return Chip(
              label: Text(degree),
              onDeleted: () => _removeDegree(degree),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String? initialValue, String label, IconData icon, {bool isNumeric = false}) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildAddressField(TextEditingController controller, String? initialValue, String label, IconData icon) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: 3,
        maxLength: 300,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildEmailField(String? email, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: email),
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildClinicTimingField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          await _selectTime(context, true);
          if (_startTime != null) {
            await _selectTime(context, false);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Clinic Timing',
            prefixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          child: Text(_clinicTimingController.text.isEmpty ? 'Select Time' : _clinicTimingController.text),
        ),
      ),
    );
  }

  Widget _buildWeekDaysField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: _selectDays,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Week Days',
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          child: Text(_weekDaysController.text.isEmpty ? 'Select Days' : _weekDaysController.text),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(TextEditingController controller, String? initialValue, String label, IconData icon) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }
    return TextField(
      controller: controller,
      maxLines: 4,
      maxLength: 1000,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildImageContainer({
    required String? imageUrl,
    required IconData placeholderIcon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(placeholderIcon, size: 60, color: Colors.grey),
                )
                    : Icon(placeholderIcon, size: 60, color: Colors.grey),
              ),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.teal),
              onPressed: onTap,
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}