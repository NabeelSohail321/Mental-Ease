import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';

import 'Video_Call_Service.dart';

class callPage extends StatefulWidget {
  final String? channelName;
  final String? role;

  callPage(this.channelName, this.role);

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
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(
      token: token,
      channelId: "Mental Ease",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
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
    Navigator.pop(context);
    _showFeedbackPrompt();
  }

  void _showFeedbackPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Session Completed"),
              content: Text("Would you like to provide feedback about "),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showFeedbackForm();
                  },
                  child: Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("No"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFeedbackForm() {
    double rating = 3.0;
    TextEditingController feedbackController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Feedback for "),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("How would you rate your session?"),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: rating >= 1 ? Colors.amber : Colors.grey),
                        Icon(Icons.star, color: rating >= 2 ? Colors.amber : Colors.grey),
                        Icon(Icons.star, color: rating >= 3 ? Colors.amber : Colors.grey),
                        Icon(Icons.star, color: rating >= 4 ? Colors.amber : Colors.grey),
                        Icon(Icons.star, color: rating >= 5 ? Colors.amber : Colors.grey),
                      ],
                    ),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text("Share your experience (max 300 words):"),
                    SizedBox(height: 10),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "How was your session?",
                      ),
                    ),
                    if (isSubmitting)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () {
                    Navigator.of(context).pop();
                  },
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

  Future<void> _submitFeedback(double rating, String feedback) async {
    try {
      // Simulate network request
      await Future.delayed(Duration(seconds: 1));

      // Here you would typically send the feedback to your backend
      print("Feedback submitted:");
      print("Rating: $rating");
      print("Comments: $feedback");

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Thank you for your feedback!"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit feedback. Please try again."))
        );
      }
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