import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class ModelProvider with ChangeNotifier {

  String? uid =  FirebaseAuth.instance.currentUser?.uid;

  final dref =  FirebaseDatabase.instance.ref('History');
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  dynamic _predictionResult;
  dynamic get predictionResult => _predictionResult;

  Future<void> modelPrediction(List<dynamic> inputData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      String? apiUrl = dotenv.env['URL'];
      if (apiUrl == null || apiUrl.isEmpty) {
        throw Exception('API URL is not configured');
      }

      Map<String, dynamic> map = {
        "features": inputData
      };

      debugPrint('Sending request to: $apiUrl');
      debugPrint('Request payload: ${jsonEncode(map)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(map),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        _predictionResult = responseBody;
        debugPrint('Prediction result: $_predictionResult');

        // Save to Firebase
        if (_predictionResult['prediction'] != null) {
          await dref.push().set({
            "status": _predictionResult['prediction'],
            "Uid": uid,
            "date": DateTime.now().toIso8601String()
          });
        } else {
          throw Exception('Prediction field missing in response');
        }
      } else {
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error: ${e.message}';
      debugPrint('Network error: $e');
    } on TimeoutException {
      _errorMessage = 'Request timed out';
      debugPrint('Request timed out');
    } on FormatException catch (e) {
      _errorMessage = 'Invalid response format: ${e.message}';
      debugPrint('JSON parsing error: $e');
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }}