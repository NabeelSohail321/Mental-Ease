import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_ease/Phycologist/phycologist_video_call.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Video_Call_Service.dart';
import '../serverkey.dart';
import '../user/Providers/Chat_Providers/Chat_Provider.dart';
import '../user/Providers/Doctors_Provider/DoctorProfileProvider.dart';
import '../videoCall.dart';


class Phycologistchatscreen extends StatefulWidget {
  final String senderId;
  final String receiverId;

  Phycologistchatscreen(this.senderId, this.receiverId);

  @override
  State<Phycologistchatscreen> createState() => _PhycologistchatscreenState();
}

class _PhycologistchatscreenState extends State<Phycologistchatscreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _chatId;
  bool _isLoading = true;
  bool _isVideoCallEnabled = false;
  final channelController = 'Mental Ease';
  bool _validateError = false;
  ClientRoleType? _role = ClientRoleType.clientRoleBroadcaster;
  String? appointmentId;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PsychologistProfileViewProvider>(context, listen: false);
    provider.fetchProfileData(widget.receiverId);
    _initializeChat();
    _checkVideoCallAvailability();
  }

  Future<void> _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setCurrentUserId(widget.receiverId);
    _chatId = await chatProvider.getOrCreateChatId(widget.senderId, widget.receiverId);
    await chatProvider.fetchMessages(_chatId);
    setState(() {
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _checkVideoCallAvailability() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final dbRef = FirebaseDatabase.instance.ref('online_Appointments');
    final snapshot = await dbRef
        .orderByChild('doctorId')
        .equalTo(widget.senderId)
        .once();

    if (snapshot.snapshot.value != null) {
      final appointments = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      for (var entry in appointments.entries) {
        final appointment = Map<String, dynamic>.from(entry.value as Map);

        // Check doctor ID, date, status, and user ID
        if (appointment['doctorId'] == widget.senderId &&
            appointment['date'] == today &&
            appointment['status'] == 'pending' &&
            appointment['userId'] == widget.receiverId) {

          final appointmentTime = appointment['time'] as String;
          final timeParts = appointmentTime.split(':');
          if (timeParts.length == 2) {
            final appointmentHour = int.tryParse(timeParts[0]) ?? 0;
            final appointmentMinute = int.tryParse(timeParts[1]) ?? 0;

            final appointmentDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              appointmentHour,
              appointmentMinute,
            );

            final timeDiff = now.difference(appointmentDateTime);

            // Enable video call if current time is after appointment time and within 3 hours
            if (!timeDiff.isNegative && timeDiff.inHours < 3) {
              setState(() {
                _isVideoCallEnabled = true;
                appointmentId = entry.key; // ✅ Save the appointment node ID
              });
              return;
            }
          }
        }
      }
    }

    setState(() {
      _isVideoCallEnabled = false;
      appointmentId = null; // or "" if you prefer
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final chatProvider = Provider.of<ChatProvider>(context);
    final provider = Provider.of<PsychologistProfileViewProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(screenHeight * 0.03),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: provider.name,
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Color(0xFF006064),
                                      fontSize: screenHeight * 0.03,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.video_call,
                              size: screenHeight * 0.04,
                              color: _isVideoCallEnabled ? Colors.blue : Colors.grey,
                            ),
                            onPressed: _isVideoCallEnabled ? () {
                              onJoin();
                            } : (){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You don't have booked Appointment with ${provider.name} on this Time check back later when ${provider.name} book Online Appointment")));
                            },
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          width: screenWidth * 0.7,
                          child: Divider(
                            thickness: 2,
                            height: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? Center(
              child: Container(
                height: screenHeight * 0.4,
                width: screenWidth * 0.8,
                child: Image.asset('assets/images/chat.gif'),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(screenWidth * 0.03),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                final isSender = message['senderId'] == widget.senderId;

                return Align(
                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: isSender ? Color(0xFFE0F7FA) : Color(0xFF80DEEA),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(fontSize: screenHeight * 0.02),
                        ),
                        if (isSender)
                          Text(
                            message['isRead'] ? 'Read' : 'Delivered',
                            style: TextStyle(
                              fontSize: screenHeight * 0.015,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      final message = _messageController.text;
                      setState(() {
                        _messageController.clear();
                      });
                      await chatProvider.sendMessage(
                        _chatId,
                        widget.senderId,
                        widget.receiverId,
                        message,
                      );
                      _messageController.clear();
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onJoin() async {
    setState(() {
      channelController.isEmpty ? _validateError = true : _validateError = false;
    });
    if (channelController.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);

      final channelId = await generateChannelId(widget.senderId, widget.receiverId);
      _sendCallNotification(widget.senderId, widget.receiverId, channelId);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhycologistVideoCall(channelController, "broadcaster", widget.receiverId,appointmentId),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status.toString());
  }
}

Future<void> _sendCallNotification(String senderId, String receiverId, String channelId) async {
  final _usersRef = FirebaseDatabase.instance.ref('users');
  final senderSnapshot = await _usersRef.child(senderId).get();

  if (senderSnapshot.exists) {
    final senderData = senderSnapshot.value as Map<dynamic, dynamic>;
    final senderName = senderData['username'];

    final receiverSnapshot = await _usersRef.child(receiverId).get();
    if (receiverSnapshot.exists) {
      final receiverData = receiverSnapshot.value as Map<dynamic, dynamic>;
      final receiverToken = receiverData['deviceToken'];

      final get = get_server_key();
      String token = await get.server_token();

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/installmentapp-1cf69/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'token': receiverToken,
            'notification': {
              'title': 'Join Video Session',
              'body': 'With $senderName',
            },
            'data': {
              'type': 'video_call',
              'receiverId': receiverId,
              'callerId': channelId,
              'callerName': senderName,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'android_channel_id': 'video_calls_channel',
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'video_calls_channel',
                'sound': 'default',
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'category': 'VIDEO_CALL',
                  'mutable-content': 1,
                  'content-available': 1
                }
              }
            }
          }
        }),
      );
      print(response.body);
    }
  }
}