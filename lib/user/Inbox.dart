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
      appBar: AppBar(
        title: Text('Inbox'),
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
          final otherUserId = chat['otherUserId'];
          final otherUserName = chat['otherUserName'];
          final otherUserImage = chat['otherUserImage'];
          final lastMessage = chat['lastMessage'];
          final timestamp = chat['timestamp'];
          final unreadCount = chat['unreadCount'];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: otherUserImage != null
                  ? NetworkImage(otherUserImage)
                  : null,
              child: otherUserImage == null
                  ? Text(otherUserName[0]) // Fallback to the first letter of the name
                  : null,
            ),
            title: Text(otherUserName),
            subtitle: Text(lastMessage ?? 'No messages'),
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
                    child: Text(unreadCount.toString()),
                  ),
              ],
            ),
            onTap: () {
              // Navigate to the chat screen
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
          );
        },
      ),
    );
  }
}