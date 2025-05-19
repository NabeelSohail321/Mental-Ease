import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/ChatScreen.dart';
import 'package:provider/provider.dart';
// import '../Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
import 'Online_Appointment.dart';
import 'Physical_Appoinment.dart';
import 'Providers/Doctors_Provider/DoctorProfileProvider.dart';

class DoctorProfile extends StatefulWidget {
  final String? doctorId;

  DoctorProfile(this.doctorId);

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  bool _isExpandedDescription = false;
  bool _isExpandedLocation = false;
  bool _isExpandedRatings = false;
  bool _isExpandedExperience = false;
  bool _isExpandedAppointmentFee = false;
  bool _isExpandedClinicTimings = false;
  bool _isExpandedWeekDays = false;
  bool _showMoreSlots = false;
  int _feedbackDisplayLimit = 5;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PsychologistProfileViewProvider>(context, listen: false);
    provider.fetchProfileData(widget.doctorId!);
  }


  Future<void> _showAppointmentOptions(BuildContext context, String doctorId) async {
    // Check if doctor is verified
    final doctorProvider = Provider.of<PsychologistProfileViewProvider>(context, listen: false);
    await doctorProvider.fetchProfileData(doctorId); // Ensure data is loaded
    bool isVerified = doctorProvider.isVerfied ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400; // Adjust breakpoint as needed

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenWidth * 0.9 : 500,
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose Appointment Type',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  if (isVerified)
                    Text(
                      doctorProvider.onlineTimeSlots?.isNotEmpty ?? false
                          ? 'This doctor offers both appointment types:'
                          : 'This doctor currently has no online availability',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'This doctor is not verified for online appointments yet.',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Physical Appointment Button
                  _buildResponsiveOptionButton(
                    context,
                    isVerified ? 'Physical Appointment' : 'Physical Appointment Only',
                    Icons.location_on,
                    Colors.blue,
                    isSmallScreen,
                        () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailsScreen(
                            doctorId: doctorId,
                            currentUserId: uid as String,
                          ),
                        ),
                      );
                    },
                  ),

                  if (isVerified) ...[
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    // Online Appointment Button
                    _buildResponsiveOptionButton(
                      context,
                      'Online Appointment',
                      Icons.video_call,
                      doctorProvider.onlineTimeSlots?.isNotEmpty ?? false
                          ? Colors.green
                          : Colors.grey,
                      isSmallScreen,
                          () {
                        if (doctorProvider.onlineTimeSlots?.isNotEmpty ?? false) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnlineAppointmentScreen(
                                doctorId: doctorId,
                                currentUserId: uid as String,
                              ),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No online time slots available. Please check back later."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveOptionButton(
      BuildContext context,
      String text,
      IconData icon,
      Color color,
      bool isSmallScreen,
      VoidCallback onPressed,
      ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 12 : 16,
          horizontal: isSmallScreen ? 8 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _showFeedbacksDialog(BuildContext context) async {
    final provider = Provider.of<PsychologistProfileViewProvider>(context, listen: false);
    final feedbacks = await provider.getAllFeedbacks(widget.doctorId!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final feedbacksToShow = feedbacks.take(_feedbackDisplayLimit).toList();
            final hasMore = feedbacks.length > _feedbackDisplayLimit;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Patient Reviews',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006064),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (feedbacks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: feedbacksToShow.map((feedback) => Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        feedback['username'] ?? 'Anonymous',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF006064),
                                        ),
                                      ),
                                      // Text(
                                      //   _formatDate(feedback['timestamp']),
                                      //   style: TextStyle(
                                      //     color: Colors.grey[600],
                                      //     fontSize: 12,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    feedback['comment'] ?? 'No comment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (feedback['rating'] as num).toInt()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    if (hasMore)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _feedbackDisplayLimit += 5;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF006064),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Show More',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _feedbackDisplayLimit = 5;
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _showReportDialog(BuildContext context) async {
    String? reportReason;
    String customReport = '';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? screenWidth * 0.9 : 500,
                  minWidth: isSmallScreen ? screenWidth * 0.8 : 400,
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Report Doctor',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Reason Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select reason',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        isExpanded: true,
                        items: [
                          'Inappropriate Behavior',
                          'Unprofessional Conduct',
                          'Fake Profile',
                          'Other'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            reportReason = value;
                          });
                        },
                      ),

                      // Custom Report Field (conditionally shown)
                      if (reportReason == 'Other') ...[
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Describe your issue',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          onChanged: (value) {
                            customReport = value;
                          },
                        ),
                      ],

                      // Buttons Row
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 16),
                          ElevatedButton(
                            onPressed: () {
                              if (reportReason != null) {
                                if (reportReason == 'Other' && customReport.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please describe your issue'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context, {
                                  'reason': reportReason,
                                  'customReport': customReport,
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final reportRef = FirebaseDatabase.instance.ref('reports').push();
        await reportRef.set({
          'doctorId': widget.doctorId,
          'userId': userId,
          'reason': result['reason'],
          'customReport': result['customReport'],
          'timestamp': ServerValue.timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.info_outline, color: Colors.black, size: 30),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'report',
                child: Text('Report'),
              ),
            ],
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog(context);
              }
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Consumer<PsychologistProfileViewProvider>(
              builder: (context, provider, child) {
                if (provider.name == null) {
                  return Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    if (provider.profileImageUrl != null)
                      Container(
                        height: screenHeight * 0.35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(provider.profileImageUrl!),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.name ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    provider.specialization ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDescriptionField(provider.description),
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.8,
                              child: Divider(thickness: 2, color: Colors.black.withOpacity(0.1)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Location',
                                  content: Text(provider.address ?? 'Not available'),
                                  isExpanded: _isExpandedLocation,
                                  onTap: () {
                                    setState(() => _isExpandedLocation = !_isExpandedLocation);
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Ratings',
                                  content: _buildStarRating(provider.ratings ?? 0.0),
                                  isExpanded: _isExpandedRatings,
                                  onTap: () {
                                    setState(() => _isExpandedRatings = !_isExpandedRatings);
                                  },
                                  showButton: true,
                                  buttonText: 'Show Reviews',
                                  onButtonPressed: () => _showFeedbacksDialog(context),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.8,
                              child: Divider(thickness: 2, color: Colors.black.withOpacity(0.1)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Experience',
                                  content: Text(provider.experience!.isNotEmpty
                                      ? "${provider.experience} years"
                                      : "Not Available"),
                                  isExpanded: _isExpandedExperience,
                                  onTap: () {
                                    setState(() => _isExpandedExperience = !_isExpandedExperience);
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Appointment Fee',
                                  content: Text(provider.appointmentFee!.isNotEmpty
                                      ? "${provider.appointmentFee}\$"
                                      : "Not Available"),
                                  isExpanded: _isExpandedAppointmentFee,
                                  onTap: () {
                                    setState(() => _isExpandedAppointmentFee = !_isExpandedAppointmentFee);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.8,
                              child: Divider(thickness: 2, color: Colors.black.withOpacity(0.1)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Clinic Timings',
                                  content: Text(provider.clinicTiming ?? 'Not available'),
                                  isExpanded: _isExpandedClinicTimings,
                                  onTap: () {
                                    setState(() => _isExpandedClinicTimings = !_isExpandedClinicTimings);
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Week Days',
                                  content: Text(provider.weekDays ?? 'Not available'),
                                  isExpanded: _isExpandedWeekDays,
                                  onTap: () {
                                    setState(() => _isExpandedWeekDays = !_isExpandedWeekDays);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.8,
                              child: Divider(thickness: 2, color: Colors.black.withOpacity(0.1)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Online Appointment Slots',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          ..._buildOnlineTimeSlots(provider),
                          if (provider.onlineTimeSlots != null && provider.onlineTimeSlots!.length > 2)
                            GestureDetector(
                              onTap: () {
                                setState(() => _showMoreSlots = !_showMoreSlots);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  _showMoreSlots ? 'Show Less' : 'Show More',
                                  style: TextStyle(
                                    color: Color(0xFF006064),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.8,
                              child: Divider(thickness: 2, color: Colors.black.withOpacity(0.1)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Contact Us',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Email',
                                  content: Text(provider.email ?? 'Not available'),
                                  isExpanded: false,
                                  onTap: () {},
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildExpandableBox(
                                  title: 'Phone Number',
                                  content: Text(provider.phoneNumber ?? 'Not available'),
                                  isExpanded: false,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.1),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 8,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ChatScreen(uid!, widget.doctorId as String);
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF006064),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Icon(Icons.message, color: Colors.white, size: 30),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAppointmentOptions(context, widget.doctorId as String);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF006064),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Text('Appointment', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final textSpan = TextSpan(text: description ?? 'Not available', style: TextStyle(fontSize: 14));
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: 3,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(maxWidth: constraints.maxWidth);

            if (textPainter.didExceedMaxLines) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isExpandedDescription
                      ? Text(description ?? 'Not available', style: TextStyle(fontSize: 14))
                      : ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.7, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Text(
                      description ?? 'Not available',
                      style: TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isExpandedDescription = !_isExpandedDescription),
                    child: Text(
                      _isExpandedDescription ? 'Show Less' : 'Show More',
                      style: TextStyle(
                        color: Color(0xFF006064),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Text(description ?? 'Not available', style: TextStyle(fontSize: 14));
            }
          },
        ),
      ],
    );
  }

  Widget _buildExpandableBox({
    required String title,
    required Widget content,
    required bool isExpanded,
    required VoidCallback onTap,
    bool showButton = false,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  SizedBox(height: 8),
                ],
              );
            },
          ),
          if (showButton && buttonText != null && onButtonPressed != null)
            Column(
              children: [
                SizedBox(height: 8),
                GestureDetector(
                  onTap: onButtonPressed,
                  child: Text(
                    'Show Reviews',
                    style: TextStyle(
                      color: Color(0xFF006064),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Icons.star, color: Colors.orange, size: 20);
            } else if (index < rating) {
              return Icon(Icons.star_half, color: Colors.orange, size: 20);
            } else {
              return Icon(Icons.star_border, color: Colors.orange, size: 20);
            }
          }),
        ),
        Text("${rating}"),
      ],
    );
  }

  List<Widget> _buildOnlineTimeSlots(PsychologistProfileViewProvider provider) {
    if (provider.onlineTimeSlots == null || provider.onlineTimeSlots!.isEmpty) {
      return [Center(child: Container(child: Text("No Slots Available Right Now")))];
    }

    final slotsToShow = _showMoreSlots
        ? provider.onlineTimeSlots!.entries
        : provider.onlineTimeSlots!.entries.take(2);

    return slotsToShow.map((entry) {
      final dateKey = entry.key;
      final timeSlots = entry.value;
      return Card(
        margin: EdgeInsets.symmetric(vertical: 5),
        color: Colors.grey[200],
        child: ListTile(
          title: Text('Date: $dateKey'),
          subtitle: Text('Time Slots: ${timeSlots.map((time) => time.format(context)).join(', ')}'),
        ),
      );
    }).toList();
  }
}