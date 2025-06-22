import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import '../../../Notification_Services.dart';
import '../../../serverkey.dart';

class Phycologistchatprovider with ChangeNotifier {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref().child('messages');
  final DatabaseReference _chatsRef = FirebaseDatabase.instance.ref().child('chats');
  final DatabaseReference _userChatsRef = FirebaseDatabase.instance.ref().child('userChats');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  NotificationServices notificationServices =  NotificationServices();


  List<Map<dynamic, dynamic>> _messages = [];
  List<Map<dynamic, dynamic>> get messages => _messages;

  List<Map<String, dynamic>> _userChats = [];
  List<Map<String, dynamic>> get userChats => _userChats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _chatId;
  String? get chatId => _chatId;

  String? _currentUserId; // Track the current user ID (receiver)

  // Set the current user ID (receiver)
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Generate or fetch chatId based on senderId and receiverId
  Future<String> getOrCreateChatId(String senderId, String receiverId) async {
    final userChatsSnapshot = await _userChatsRef.child(senderId).get();
    if (userChatsSnapshot.exists) {
      final userChats = userChatsSnapshot.value as Map<dynamic, dynamic>;
      for (final chatId in userChats.keys) {
        final chatSnapshot = await _chatsRef.child(chatId).get();
        if (chatSnapshot.exists) {
          final chatData = chatSnapshot.value as Map<dynamic, dynamic>;
          if (chatData['participants'][receiverId] == true) {
            _chatId = chatId;
            notifyListeners();
            return chatId;
          }
        }
      }
    }

    // If no existing chat, create a new one
    final newChatRef = _chatsRef.push();
    _chatId = newChatRef.key;
    await newChatRef.set({
      'lastMessage': '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'unreadCount': 0,
      'participants': {
        senderId: true,
        receiverId: true,
      },
    });

    // Add chat to userChats for both participants
    await _userChatsRef.child('$senderId/$_chatId').set(true);
    await _userChatsRef.child('$receiverId/$_chatId').set(true);

    notifyListeners();
    return _chatId!;
  }

  // Fetch user chats and listen for changes in lastMessage and unreadCount
  Future<void> fetchUserChats(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userChatsSnapshot = await _userChatsRef.child(userId).get();
      if (userChatsSnapshot.exists) {
        final userChats = userChatsSnapshot.value as Map<dynamic, dynamic>;
        _userChats = [];

        for (final chatId in userChats.keys) {
          final chatSnapshot = await _chatsRef.child(chatId).get();
          if (chatSnapshot.exists) {
            final chatData = chatSnapshot.value as Map<dynamic, dynamic>;
            final participants = chatData['participants'] as Map<dynamic, dynamic>;

            // Get the other participant's ID
            final otherUserId = participants.keys.firstWhere(
                  (id) => id != userId,
              orElse: () => null,
            );

            if (otherUserId != null) {
              // Fetch user details (name and profile image)
              final userSnapshot = await _usersRef.child(otherUserId).get();
              if (userSnapshot.exists) {
                final userData = userSnapshot.value as Map<dynamic, dynamic>;
                final userName = userData['username'];
                print(userName);
                final userImage = userData['profileImage'];

                _userChats.add({
                  'chatId': chatId,
                  'otherUserId': otherUserId,
                  'otherUserName': userName,
                  'otherUserImage': userImage,
                  'lastMessage': chatData['lastMessage'],
                  'timestamp': chatData['timestamp'],
                  'unreadCount': chatData['unreadCount'],
                });

                // Listen for changes in lastMessage and unreadCount
                _chatsRef.child(chatId).onValue.listen((event) {
                  final updatedChatData = event.snapshot.value as Map<dynamic, dynamic>?;
                  if (updatedChatData != null) {
                    final updatedLastMessage = updatedChatData['lastMessage'];
                    final updatedUnreadCount = updatedChatData['unreadCount'];
                    final index = _userChats.indexWhere((chat) => chat['chatId'] == chatId);
                    if (index != -1) {
                      _userChats[index]['lastMessage'] = updatedLastMessage;
                      _userChats[index]['unreadCount'] = updatedUnreadCount;
                      notifyListeners();
                    }
                  }
                });
              }
            }
          }
        }

        // Sort chats by unreadCount (descending) and then by timestamp (descending)
        _userChats.sort((a, b) {
          if (a['unreadCount'] != b['unreadCount']) {
            return b['unreadCount'].compareTo(a['unreadCount']); // Higher unreadCount first
          } else {
            return b['timestamp'].compareTo(a['timestamp']); // Newer timestamp first
          }
        });
      }
    } catch (e) {
      print('Error fetching user chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch messages for a specific chat
  Future<void> fetchMessages(String chatId) async {
    _messagesRef.child(chatId).onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _messages = data.entries.map((entry) {
          return {
            'messageId': entry.key,
            ...entry.value,
          };
        }).toList();

        // Sort messages by timestamp (oldest first)
        _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        // Mark messages as read if the current user is the receiver
        if (_currentUserId != null) {
          await _markMessagesAsReadByReceiver(chatId, _currentUserId!);
        }

        notifyListeners();
      }
    });
  }

  // Mark messages as read by the receiver
  Future<void> _markMessagesAsReadByReceiver(String chatId, String receiverId) async {
    try {
      final messagesSnapshot = await _messagesRef.child(chatId).get();
      if (messagesSnapshot.exists) {
        final messages = messagesSnapshot.value as Map<dynamic, dynamic>;
        for (final entry in messages.entries) {
          final messageId = entry.key;
          final messageData = entry.value;

          // Mark as read if the message is sent to the receiver and is unread
          if (messageData['senderId'] == receiverId && messageData['isRead'] == false) {
            await _messagesRef.child('$chatId/$messageId/isRead').set(true);
          }
        }

        // Reset unread count for the chat
        await _chatsRef.child(chatId).update({'unreadCount': 0});
      }
    } catch (e) {
      print('Error marking messages as read by receiver: $e');
    }
  }

  // Send a text message
  Future<void> sendMessage(String chatId, String senderId, String receiverId, String message) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add new message
      final newMessageRef = _messagesRef.child(chatId).push();
      await newMessageRef.set({
        'senderId': senderId,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isRead': false,
      });

      // Fetch sender's details (name)
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
            Uri.parse(
                'https://fcm.googleapis.com/v1/projects/installmentapp-1cf69/messages:send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, dynamic>{
              "message": {
                "token": receiverToken,
                "notification": {
                  "body": message, // Message content
                  "title": senderName, // Use the sender's name as the title
                },
                "data": {"story_id": "story_12345"}
              }
            }),
          );
          print(response.body);
        }
      }

      // Update chat
      await _chatsRef.child(chatId).update({
        'lastMessage': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'unreadCount': ServerValue.increment(1),
      });

    } catch (e) {
      print('Error sending message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }}