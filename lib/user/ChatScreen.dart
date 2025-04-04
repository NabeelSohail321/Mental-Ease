import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Video_Call_Service.dart';
import '../serverkey.dart';
import '../videoCall.dart';
import 'Providers/Chat_Providers/Chat_Provider.dart';
import 'Providers/Doctors_Provider/DoctorProfileProvider.dart';
import 'package:http/http.dart' as http;


class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;

  ChatScreen(this.senderId, this.receiverId);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _chatId;
  bool _isLoading = true; // Track loading state

  final channelController = 'Mental Ease';
  bool _validateError = false;
  ClientRoleType? _role = ClientRoleType.clientRoleBroadcaster;


  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    print(_role);
    super.initState();
    final provider = Provider.of<PsychologistProfileViewProvider>(context, listen: false);
    provider.fetchProfileData(widget.receiverId);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setCurrentUserId(widget.receiverId); // Set the current user ID (receiver)
    _chatId = await chatProvider.getOrCreateChatId(widget.senderId, widget.receiverId);
    await chatProvider.fetchMessages(_chatId); // Fetch messages and mark them as read
    setState(() {
      _isLoading = false; // Mark loading as complete
    });

    // Scroll to the bottom after messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to the sides
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
                            icon: Icon(Icons.video_call, size: screenHeight * 0.04), // Video call icon
                            onPressed: () {
                              onJoin();
                              // Add video call functionality here
                              print('Video call button pressed');
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
          ? Center(
        child: CircularProgressIndicator(), // Show loading indicator
      )
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
               // Display messages from bottom to top
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
                      await chatProvider.sendMessage(
                        _chatId,
                        widget.senderId,
                        widget.receiverId,
                        _messageController.text,
                      );


                      _messageController.clear();

                      // Scroll to the bottom after sending a message
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

  Future<void> onJoin() async{


    setState(() {
      channelController.isEmpty? _validateError = true: _validateError =false;
    });
    if(channelController.isNotEmpty){
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);


      final channelId = await generateChannelId(widget.senderId,widget.receiverId);

      _sendCallNotification(widget.senderId,widget.receiverId,channelId);
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return callPage(channelController,"broadcaster");
      },));
    }


  }


}

  Future<void> _handleCameraAndMic(Permission permission) async{
  final status = await permission.request();
  print(status.toString());


  }

Future<void> _sendCallNotification(String senderId, String receiverId, String channelId) async {
  final _usersRef = FirebaseDatabase.instance.ref('users');
  final senderSnapshot = await _usersRef.child(senderId).get();

  if (senderSnapshot.exists) {
    final senderData = senderSnapshot.value as Map<dynamic, dynamic>;
    final senderName = senderData['username']; // Current user's name (sender)

    // Fetch receiver's details (device token)
    final receiverSnapshot = await _usersRef.child(receiverId).get();
    if (receiverSnapshot.exists) {
      final receiverData = receiverSnapshot.value as Map<dynamic, dynamic>;
      final receiverToken = receiverData['deviceToken'];

      // Send notification to the receiver
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
              'title': 'Incoming Video Call',
              'body': 'From $senderName',
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