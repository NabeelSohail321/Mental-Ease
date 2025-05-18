import 'dart:convert';
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
    // Set loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Replace with your actual localhost API endpoint
      const String apiUrl = 'http://192.168.1.15:5000/predict'; // For Android emulator
      // const String apiUrl = 'http://localhost:5000/predict'; // For iOS simulator or real device
      // const String apiUrl = 'http://your-local-ip:5000/predict'; // For testing on real device


      Map<String, dynamic> map = {
        "features": inputData
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        // Successful request
        _predictionResult = jsonDecode(response.body);
        print(_predictionResult);
        dref.push().set({
          "status": _predictionResult['prediction'],
          "Uid": uid
        });
      } else {
        // Handle server errors
        _errorMessage = 'Failed to get prediction: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      // Handle network errors
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      // Reset loading state
      _isLoading = false;
      notifyListeners();
    }
  }
}