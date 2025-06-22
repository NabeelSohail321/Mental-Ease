import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import 'ChatScreen.dart';
import 'Providers/Chat_Providers/Chat_Provider.dart'; // For timestamp formatting

class InboxScreen extends StatefulWidget {
  final String currentUserId;

  InboxScreen(this.currentUserId);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    // Delay fetching user chats until after the build process is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.fetchUserChats(widget.currentUserId);
    });
  }

  // Format timestamp
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date); // Today, show time (e.g., 10:30 AM)
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MM/dd/yyyy').format(date); // Older, show date (e.g., 10/15/2023)
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.2),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Welcome to ',
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Color(0xFF006064),
                                      fontSize: screenHeight * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Inbox",
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      body: chatProvider.isLoading
          ? Center(
        child: CircularProgressIndicator(), // Show loading indicator
      )
          : chatProvider.userChats.isEmpty
          ? Center(
        child: Text('No chats found'), // Show message if no chats
      )
          : ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.03),
        itemCount: chatProvider.userChats.length,
        itemBuilder: (context, index) {
          final chat = chatProvider.userChats[index];

          // Safe property access with null checks
          final otherUserId = chat?['otherUserId'] ?? '';
          final otherUserName = chat?['otherUserName'] ?? 'Unknown';
          final otherUserImage = chat?['otherUserImage'];
          final lastMessage = chat?['lastMessage'] ?? 'No messages';
          final timestamp = chat?['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
          final unreadCount = chat?['unreadCount'] ?? 0;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: otherUserImage != null && otherUserImage.isNotEmpty
                    ? NetworkImage(otherUserImage)
                    : null,
                child: otherUserImage == null || otherUserImage.isEmpty
                    ? Text(otherUserName.isNotEmpty ? otherUserName[0] : '?')
                    : null,
              ),
              title: Text(otherUserName),
              subtitle: Text(lastMessage),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: screenHeight * 0.015,
                      color: Colors.grey,
                    ),
                  ),
                  if (unreadCount > 0)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      child: Text(unreadCount.toString()),
                    ),

                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      widget.currentUserId,
                      otherUserId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}