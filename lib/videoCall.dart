import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';

import 'Video_Call_Service.dart';

class callPage extends StatefulWidget {
  final String? channelName;
  final String? role;
  final String? DoctorId;

  callPage(this.channelName, this.role, this.DoctorId);

  @override
  State<callPage> createState() => _callPageState();
}

class _callPageState extends State<callPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;
  String channelId  = 'call_464yLmzMzJeHsymcFkMGbIIKqUJ2_Xd4evN6WJ6PHlba3nBMrBEVt3O42';
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');
  String? role;
  bool isSubmitting = false;
  bool _isEngineInitialized = false;


  // Position for the floating local video
  Offset _localVideoPosition = Offset(20, 80);
  bool _isLocalVideoDragging = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> initialize() async {
    DatabaseEvent event = await _dbRef.child(_uid!).child("role").once();
    role = event.snapshot.value.toString();
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add("App Id is missing Please Provide App Id in Video_Call_Service.dart");
        _infoStrings.add("Agora Engine is not starting");
      });
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    await _engine.enableVideo();
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration(
      dimensions: VideoDimensions(width: 1920, height: 1080),
    );
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(
      token: token,
      channelId: "Mental Ease",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    setState(() {
      _isEngineInitialized = true;
    });
  }

  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          setState(() {
            _infoStrings.add(msg.toString());
          });
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          final info = 'connection created $connection';
          setState(() {
            _infoStrings.add(info);
          });
        },
        onLeaveChannel: (RtcConnection, stats) {
          setState(() {
            _infoStrings.add("Leave channel");
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            final info = 'user joined $remoteUid';
            _infoStrings.add(info);
            _users.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            final info = 'user offline $remoteUid';
            _infoStrings.add(info);
            _users.remove(remoteUid);
          });
          if (_users.isEmpty) {
            Future.delayed(Duration(seconds: 5), () {
              _endCall();
            });
          }
        },
        onFirstRemoteVideoFrame: (RtcConnection connection, int uid, int elapsed, int width, int height) {
          setState(() {
            final info = 'First remote Video $uid ${width} x ${height}';
            _infoStrings.add(info);
          });
        },
      ),
    );
  }

  Widget _viewRows() {
    if (!_isEngineInitialized || _engine == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Initializing video call..."),
            if (_infoStrings.isNotEmpty)
              ..._infoStrings.map((info) => Text(info)).toList(),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Remote video (full screen)
        if (_users.isNotEmpty)
          Positioned.fill(
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _users.first),
                connection: RtcConnection(channelId: "Mental Ease" ?? "default_channel"),
              ),
            ),
          ),
        // Floating local video
        if (widget.role == "broadcaster")
          Positioned(
            left: _localVideoPosition.dx,
            top: _localVideoPosition.dy,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isLocalVideoDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _localVideoPosition += details.delta;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isLocalVideoDragging = false;
                });
              },
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isLocalVideoDragging ? Colors.blue : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _toolbar() {
    return widget.role == "audience"
        ? Container()
        : Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildToolbarButton(
            icon: muted ? Icons.mic_off : Icons.mic,
            color: muted ? Colors.red : Colors.blue,
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
          ),
          _buildToolbarButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: _endCall,
            size: 56,
          ),
          _buildToolbarButton(
            icon: Icons.cameraswitch,
            color: Colors.blue,
            onPressed: () {
              _engine.switchCamera();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: size * 0.6),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _endCall() {
    _engine.leaveChannel();

    if (role == 'user') {
      // Show feedback first
      _showFeedbackPrompt().then((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _showFeedbackPrompt() async {
    bool? wantFeedback = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Session Completed"),
          content: Text("Would you like to provide feedback about your session?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No"),
            ),
          ],
        );
      },
    );

    if (wantFeedback == true && mounted) {
      await _showFeedbackForm();
    }
  }

  Future<void> _showFeedbackForm() async {
    double rating = 3.0;
    TextEditingController feedbackController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Feedback"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("How would you rate your session?"),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => Icon(
                        Icons.star,
                        color: rating >= index + 1 ? Colors.amber : Colors.grey,
                      )),
                    ),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) => setState(() => rating = value),
                    ),
                    SizedBox(height: 20),
                    Text("Share your experience:"),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "How was your session?",
                      ),
                    ),
                    if (isSubmitting) CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    setState(() => isSubmitting = true);
                    await _submitFeedback(rating, feedbackController.text);
                    setState(() => isSubmitting = false);
                    Navigator.of(context).pop();
                  },
                  child: Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitFeedback(double newRating, String feedback) async {
    try {
      setState(() => isSubmitting = true);

      // 1. Get references
      final doctorRef = _dbRef.child(widget.DoctorId!);
      final userRef = _dbRef.child(_uid!);

      // 2. Fetch current user data
      final userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        throw Exception('User profile not found');
      }

      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      final username = userData['username']?.toString() ?? 'Anonymous';

      // 3. Generate unique key for new feedback
      final newFeedbackKey = doctorRef.child('feedbacks').push().key;
      if (newFeedbackKey == null) {
        throw Exception('Could not generate feedback key');
      }

      // 4. Create feedback object with timestamp
      final feedbackData = <String, dynamic>{
        'ratings': newRating,  // Changed from 'ratings' to 'rating' for consistency
        'comment': feedback,
        'userId': _uid,
        'username': username,
        'timestamp': ServerValue.timestamp,
      };

      // 5. Prepare updates - adds new feedback while preserving old ones
      final updates = <String, dynamic>{
        'feedbacks/$newFeedbackKey': feedbackData,
      };

      // 6. Calculate new average rating including this feedback
      final doctorSnapshot = await doctorRef.get();
      final doctorData = Map<String, dynamic>.from(doctorSnapshot.value as Map? ?? {});

      // Get current average rating (safe parsing)
      double currentAverageRating = 0.0;
      if (doctorData['ratings'] != null) {
        currentAverageRating = (doctorData['ratings'] is num)
            ? (doctorData['ratings'] as num).toDouble()
            : double.tryParse(doctorData['rating'].toString()) ?? 0.0;
      }

      // Get all existing feedbacks
      final existingFeedbacks = doctorData['feedbacks'] as Map<dynamic, dynamic>? ?? {};
      final allRatings = [
        newRating,
        ...existingFeedbacks.values.map((f) {
          return (f['ratings'] is num)
              ? (f['ratings'] as num).toDouble()
              : double.tryParse(f['ratings'].toString()) ?? 0.0;
        })
      ];

      // Calculate new average
      final updatedRating = (newRating+currentAverageRating) /2;
      updates['ratings'] = updatedRating.toString();

      // 7. Perform the update
      await doctorRef.update(Map<String, Object?>.from(updates));

      // 8. Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thank you for your feedback!"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}"))
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call - ${widget.channelName ?? ''}'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: _toolbar(),
            ),
          ],
        ),
      ),
    );
  }
}