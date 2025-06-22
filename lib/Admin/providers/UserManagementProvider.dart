import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../serverkey.dart';

class UserManagementProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all'; // 'all', 'admins', 'users'
  String _searchQuery = '';

  List<AppUser> get users => _users;
  List<AppUser> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _filter;

  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch all users instead of filtering by role in the query
      final usersSnapshot = await _dbRef.child('users').get();

      // Parse and filter only 'user' and 'Admin' roles
      _users = _parseUsersSnapshot(usersSnapshot).where(
            (user) => user.role == 'user' || user.role == 'Admin',
      ).toList();

      _applyFilterAndSearch();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch users: ${e.toString()}';
      _users = [];
      _filteredUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AppUser> _parseUsersSnapshot(DataSnapshot snapshot) {
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
    return usersMap.entries.map((entry) {
      return AppUser.fromMap(
        entry.key.toString(),
        Map<String, dynamic>.from(entry.value),
      );
    }).where((user) => user.role != 'SuperAdmin').toList();
  }

  void setFilter(String filter) {
    _filter = filter;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilterAndSearch();
    notifyListeners();
  }

  void _applyFilterAndSearch() {
    // First apply the filter
    List<AppUser> tempUsers;
    switch (_filter) {
      case 'admins':
        tempUsers = _users.where((user) => user.role == 'Admin').toList();
        break;
      case 'users':
        tempUsers = _users.where((user) => user.role != 'Admin').toList();
        break;
      default:
        tempUsers = List.from(_users);
    }

    // Then apply search if query is not empty
    if (_searchQuery.isNotEmpty) {
      tempUsers = tempUsers.where((user) {
        final username = user.username?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        return username.contains(_searchQuery) || email.contains(_searchQuery);
      }).toList();
    }

    _filteredUsers = tempUsers;
  }

  Future<void> toggleAdminRole(String userId, String currentRole) async {
    try {
      final newRole = currentRole == 'Admin' ? 'user' : 'Admin';
      await _dbRef.child('users/$userId/role').set(newRole);

      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: newRole);
        _applyFilterAndSearch();
        notifyListeners();

        // Send notification about role change
        await _sendRoleChangeNotification(
          userId: userId,
          newRole: newRole,
        );
      }
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }

  Future<void> _sendRoleChangeNotification({
    required String userId,
    required String newRole,
  }) async {
    try {
      // Get user data
      final userSnapshot = await _usersRef.child(userId).get();
      if (!userSnapshot.exists) return;

      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      final userToken = userData['deviceToken'] ?? '';
      final username = userData['username'] ?? 'User';

      if (userToken.isEmpty) return;

      // Get FCM server token
      final get = get_server_key();
      final String token = await get.server_token();

      // Prepare notification data
      final title = 'Account Role Updated';
      final body = newRole == 'Admin'
          ? 'Congratulations! You have been granted Admin privileges.'
          : 'Your Admin privileges have been revoked.';

      await _sendSingleNotification(
        token: token,
        receiverToken: userToken,
        title: title,
        body: body,
        data: {
          'type': 'role_changed',
          'userId': userId,
          'newRole': newRole,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
    } catch (e) {
      debugPrint('Error sending role change notification: $e');
    }
  }

  Future<void> _sendSingleNotification({
    required String token,
    required String receiverToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
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
              'title': title,
              'body': body,
            },
            'data': data,
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'account_channel',
                'sound': 'default',
                'icon': '@mipmap/ic_notification',
                'color': '#006064',
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'badge': 1,
                  'category': 'ACCOUNT_UPDATE',
                  'mutable-content': 1
                }
              }
            }
          }
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to send notification: ${response.body}');
      } else {
        debugPrint('Notification sent successfully');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}

class AppUser {
  final String id;
  final String role;
  final String? username;
  final String? email;

  AppUser({
    required this.id,
    required this.role,
    this.username,
    this.email,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      role: map['role'] ?? 'user',
      username: map['username'],
      email: map['email'],
    );
  }

  AppUser copyWith({
    String? role,
  }) {
    return AppUser(
      id: id,
      role: role ?? this.role,
      username: username,
      email: email,
    );
  }
}

