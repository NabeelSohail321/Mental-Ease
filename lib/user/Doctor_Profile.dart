import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_ease/user/ChatScreen.dart';
import 'package:provider/provider.dart';
import '../Phycologist/Providers/Phycologist_Profile_Provider/Phycologist_Profile_Provider.dart';
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

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PsychologistProfileViewProvider>(context, listen: false);
    provider.fetchProfileData(widget.doctorId!);
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
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black, size: 30),
            onPressed: () {},
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
                    onPressed: () {},
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