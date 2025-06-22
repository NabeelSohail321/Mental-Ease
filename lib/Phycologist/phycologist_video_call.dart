import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../Video_Call_Service.dart';
import 'Providers/phycologist_online_appointment_provider.dart';

class PhycologistVideoCall extends StatefulWidget {
  final String? channelName;
  final String? role;
  final String? DoctorId;
  final String? appointmentId;

  PhycologistVideoCall(this.channelName, this.role, this.DoctorId, this.appointmentId);

  @override
  State<PhycologistVideoCall> createState() => _PhycologistVideoCallState();
}

class _PhycologistVideoCallState extends State<PhycologistVideoCall> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  RtcEngine? _engine; // Changed from late to nullable
  String channelId = 'call_464yLmzMzJeHsymcFkMGbIIKqUJ2_Xd4evN6WJ6PHlba3nBMrBEVt3O42';
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');
  String? role;
  bool isSubmitting = false;
  bool _isEngineInitialized = false; // Track engine initialization state

  // Position for the floating local video
  Offset _localVideoPosition = Offset(20, 80);
  bool _isLocalVideoDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeAgoraEngine();
  }

  Future<void> _initializeAgoraEngine() async {
    try {
      // Get user role first
      DatabaseEvent event = await _dbRef.child(_uid!).child("role").once();
      role = event.snapshot.value.toString();

      if (appId.isEmpty) {
        setState(() {
          _infoStrings.add("App Id is missing. Please provide App Id in Video_Call_Service.dart");
          _infoStrings.add("Agora Engine is not starting");
        });
        return;
      }

      // Create and initialize the engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      // Configure engine
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      await _engine!.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Set up event handlers
      _addAgoraEventHandlers();

      // Configure video encoder
      VideoEncoderConfiguration configuration = VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 1920, height: 1080),
      );
      await _engine?.setVideoEncoderConfiguration(configuration);

      // Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channelName ?? "Mental Ease",
        uid: 0,
        options: const ChannelMediaOptions(),
      );

      setState(() {
        _isEngineInitialized = true;
      });
    } catch (e) {
      setState(() {
        _infoStrings.add("Error initializing Agora: ${e.toString()}");
      });
    }
  }

  @override
  void dispose() {
    _users.clear();
    if (_engine != null) {
      _engine!.leaveChannel();
      _engine!.release();
    }
    super.dispose();
  }

  void _addAgoraEventHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          setState(() {
            _infoStrings.add("Error: $msg");
          });
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _infoStrings.add("Connected to channel successfully");
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            _infoStrings.add("Left channel");
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _infoStrings.add("User joined: $remoteUid");
            _users.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _infoStrings.add("User offline: $remoteUid");
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
            _infoStrings.add("First remote video frame from $uid ($width x $height)");
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
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _users.first),
                connection: RtcConnection(channelId: widget.channelName ?? "default_channel"),
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
                      rtcEngine: _engine!,
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
    if (!_isEngineInitialized || _engine == null || widget.role == "audience") {
      return Container();
    }

    return Container(
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
              _engine?.muteLocalAudioStream(muted);
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
              _engine?.switchCamera();
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

  Future<void> _showCompletionConfirmation(BuildContext context) async {
    if (!mounted) return;

    if ((widget.appointmentId != null&& widget.appointmentId!='') && role == 'Psychologist') {
      try {
        bool? confirmCompletion = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Session Completed"),
              content: const Text("Do you want to mark this appointment as complete?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final provider = Provider.of<phycologistOnlineAppointmentProvider>(
                        dialogContext,
                        listen: false,
                      );

                      await provider.updateAppointmentStatus(
                          widget.appointmentId!,
                          'completed',
                          dialogContext,
                          'videocall'
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Status Updated"))
                        );
                      }
                      Navigator.of(dialogContext).pop(true);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error updating appointment: ${e.toString()}")),
                        );
                      }
                      Navigator.of(dialogContext).pop(false);
                    }
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            );
          },
        );

        if (confirmCompletion == true && mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      }
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  void _endCall() {
    if (_engine != null) {
      _engine!.leaveChannel();
    }

    if (role?.toLowerCase() == 'user') {
      _showFeedbackPrompt().then((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      if (widget.appointmentId != null && role == 'Psychologist') {
        _showCompletionConfirmation(context).then((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showFeedbackPrompt() async {
    bool? wantFeedback = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Session Completed"),
          content: const Text("Would you like to provide feedback about your session?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
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
              title: const Text("Feedback"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("How would you rate your session?"),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    const Text("Share your experience:"),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "How was your session?",
                      ),
                    ),
                    if (isSubmitting) const CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    setState(() => isSubmitting = true);
                    await _submitFeedback(rating, feedbackController.text);
                    setState(() => isSubmitting = false);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Submit"),
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

      final doctorRef = _dbRef.child(widget.DoctorId!);
      final userRef = _dbRef.child(_uid!);

      final userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        throw Exception('User profile not found');
      }

      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      final username = userData['username']?.toString() ?? 'Anonymous';

      final newFeedbackKey = doctorRef.child('feedbacks').push().key;
      if (newFeedbackKey == null) {
        throw Exception('Could not generate feedback key');
      }

      final feedbackData = <String, dynamic>{
        'rating': newRating,
        'comment': feedback,
        'userId': _uid,
        'username': username,
        'timestamp': ServerValue.timestamp,
      };

      final updates = <String, dynamic>{
        'feedbacks/$newFeedbackKey': feedbackData,
      };

      final doctorSnapshot = await doctorRef.get();
      final doctorData = Map<String, dynamic>.from(doctorSnapshot.value as Map? ?? {});

      double currentAverageRating = 0.0;
      if (doctorData['rating'] != null) {
        currentAverageRating = (doctorData['rating'] is num)
            ? (doctorData['rating'] as num).toDouble()
            : double.tryParse(doctorData['rating'].toString()) ?? 0.0;
      }

      final existingFeedbacks = doctorData['feedbacks'] as Map<dynamic, dynamic>? ?? {};
      final totalRatings = existingFeedbacks.length + 1;
      final updatedRating = ((currentAverageRating * existingFeedbacks.length) + newRating) / totalRatings;

      updates['rating'] = updatedRating;

      await doctorRef.update(updates);

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
  }

  @override
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