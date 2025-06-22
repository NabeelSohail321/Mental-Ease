// lib/Admin/providers/psychologist_verification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../serverkey.dart';

class PsychologistVerificationProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all'; // 'all', 'verified', 'unverified', 'psychologists', 'users', 'unlisted'
  String _searchQuery = '';

  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _filter;

  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final usersSnapshot = await _dbRef.child('users').get();
      _users = _parseUsersSnapshot(usersSnapshot);
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

  List<User> _parseUsersSnapshot(DataSnapshot snapshot) {
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
    return usersMap.entries.map((entry) {
      return User.fromMap(
        entry.key.toString(),
        Map<String, dynamic>.from(entry.value),
      );
    }).toList();
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
    List<User> tempUsers;
    switch (_filter) {
      case 'all':
        tempUsers = List.from(_users);
        break;
      case 'verified':
        tempUsers = _users.where((user) =>
        user.role == 'Psychologist' &&
            (user.isVerified ?? false) &&
            (user.isListed ?? false)).toList();
        break;
      case 'unverified':
        tempUsers = _users.where((user) =>
        user.role == 'Psychologist' &&
            !(user.isVerified ?? false) &&
            (user.isListed ?? false)).toList();
        break;
      case 'psychologists':
        tempUsers = _users.where((user) =>
        user.role == 'Psychologist').toList();
        break;
      case 'users':
        tempUsers = _users.where((user) =>
        user.role == 'user').toList();
        break;
      case 'unlisted':
        tempUsers = _users.where((user) =>
        user.role == 'Psychologist' &&
            !(user.isListed ?? false)).toList();
        break;
      default:
        tempUsers = List.from(_users);
    }

    // Then apply search if query is not empty
    if (_searchQuery.isNotEmpty) {
      tempUsers = tempUsers.where((user) {
        final name = user.name?.toLowerCase() ?? '';
        final username = user.username?.toLowerCase() ?? '';
        return name.contains(_searchQuery) || username.contains(_searchQuery);
      }).toList();
    }

    _filteredUsers = tempUsers;
  }

  Future<void> toggleVerification(String userId, bool isVerified) async {
    try {
      final newStatus = !isVerified;
      await _dbRef.child('users/$userId/isVerfied').set(newStatus);

      // Update local state
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isVerified: newStatus);
        _applyFilterAndSearch();
        notifyListeners();

        // Send notification to psychologist
        await _sendVerificationNotification(
          userId: userId,
          isVerified: newStatus,
        );
      }
    } catch (e) {
      throw Exception('Failed to update verification status: ${e.toString()}');
    }
  }

  Future<void> toggleListing(String userId, bool isListed) async {
    try {
      final newStatus = !isListed;
      await _dbRef.child('users/$userId/isListed').set(newStatus);

      // Update local state
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isListed: newStatus);
        _applyFilterAndSearch();
        notifyListeners();

        // Send notification to psychologist
        await _sendListingNotification(
          userId: userId,
          isListed: newStatus,
        );
      }
    } catch (e) {
      throw Exception('Failed to update listing status: ${e.toString()}');
    }
  }

  Future<void> _sendVerificationNotification({
    required String userId,
    required bool isVerified,
  })
  async {
    try {
      // Get user data
      final userSnapshot = await _usersRef.child(userId).get();
      if (!userSnapshot.exists) return;

      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      final userName = userData['username'] ?? 'Psychologist';
      final userToken = userData['deviceToken'] ?? '';

      if (userToken.isEmpty) return;

      // Get FCM server token
      final get = get_server_key();
      final String token = await get.server_token();

      // Prepare notification data
      final status = isVerified ? 'verified' : 'unverified';
      final title = 'Account Verification $status';
      final body = isVerified
          ? 'Congratulations! Your account has been verified by the admin.'
          : 'Your account verification has been removed by the admin.';

      await _sendSingleNotification(
        token: token,
        receiverToken: userToken,
        title: title,
        body: body,
        data: {
          'type': 'verification_status_changed',
          'userId': userId,
          'status': status,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
    } catch (e) {
      debugPrint('Error sending verification notification: $e');
    }
  }

  Future<void> _sendListingNotification({
    required String userId,
    required bool isListed,
  })
  async {
    try {
      // Get user data
      final userSnapshot = await _usersRef.child(userId).get();
      if (!userSnapshot.exists) return;

      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      final userName = userData['username'] ?? 'Psychologist';
      final userToken = userData['deviceToken'] ?? '';

      if (userToken.isEmpty) return;

      // Get FCM server token
      final get = get_server_key();
      final String token = await get.server_token();

      // Prepare notification data
      final status = isListed ? 'listed' : 'unlisted';
      final title = 'Profile Listing Status Changed';
      final body = isListed
          ? 'Your profile is now visible to patients on the platform.'
          : 'Your profile has been unlisted and is no longer visible to patients.';

      await _sendSingleNotification(
        token: token,
        receiverToken: userToken,
        title: title,
        body: body,
        data: {
          'type': 'listing_status_changed',
          'userId': userId,
          'status': status,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
    } catch (e) {
      debugPrint('Error sending listing notification: $e');
    }
  }

  Future<void> _sendSingleNotification({
    required String token,
    required String receiverToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  })
  async {
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
                'channel_id': 'account_status_channel',
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
                  'category': 'ACCOUNT_STATUS',
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

class User {
  final String id;
  final String role;
  final String? username;
  final String? email;
  final String? name;
  final bool? isVerified;
  final bool? isListed;
  final String? profileImageUrl;
  final String? degreeImageUrl;
  final String? description;
  final String? specialization;
  final String? experience;
  final String? appointmentFee;
  final String? clinicTiming;
  final String? address;
  final String? phoneNumber;

  User({
    required this.id,
    required this.role,
    this.username,
    this.email,
    this.name,
    this.isVerified,
    this.isListed,
    this.profileImageUrl,
    this.degreeImageUrl,
    this.description,
    this.specialization,
    this.experience,
    this.appointmentFee,
    this.clinicTiming,
    this.address,
    this.phoneNumber,
  });

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      role: map['role'] ?? '',
      username: map['username'],
      email: map['email'],
      name: map['name'],
      isVerified: map['isVerfied'] ?? false,
      isListed: map['isListed'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      degreeImageUrl: map['degreeImageUrl'],
      description: map['description'],
      specialization: map['specialization'],
      experience: map['experience'],
      appointmentFee: map['appointmentFee'],
      clinicTiming: map['clinicTiming'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
    );
  }

  User copyWith({
    bool? isVerified,
    bool? isListed,
  }) {
    return User(
      id: id,
      role: role,
      username: username,
      email: email,
      name: name,
      isVerified: isVerified ?? this.isVerified,
      isListed: isListed ?? this.isListed,
      profileImageUrl: profileImageUrl,
      degreeImageUrl: degreeImageUrl,
      description: description,
      specialization: specialization,
      experience: experience,
      appointmentFee: appointmentFee,
      clinicTiming: clinicTiming,
      address: address,
      phoneNumber: phoneNumber,
    );
  }
}

