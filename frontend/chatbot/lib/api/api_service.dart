import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class KYCApiService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<Map<String, dynamic>> submitKYCApplication({
    required String fullName,
    required String phoneNumber,
    required DateTime dob,
    required String address,
    required String idType,
    required String idNumber,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kyc-applications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'dob': dob.toString().split(' ')[0], // Format as YYYY-MM-DD
          'address': address,
          'idType': idType,
          'idNumber': idNumber,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to submit KYC application: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Updated document upload method that works for both web and mobile
  Future<Map<String, dynamic>> uploadDocument({
    required int applicationId,
    String? filePath, // For mobile
    Uint8List? fileBytes, // For web
    required String fileName,
    required String documentType,
    String? specialNote,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/documents/$applicationId'),
      );

      // Add file - handle both web and mobile paths
      if (kIsWeb && fileBytes != null) {
        // For web, use bytes
        var multipartFile = http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        );
        request.files.add(multipartFile);
      } else if (!kIsWeb && filePath != null) {
        // For mobile, use file path
        var file = await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('application', 'pdf'),
        );
        request.files.add(file);
      } else {
        throw Exception('No valid file data provided');
      }

      // Add text fields
      request.fields['documentType'] = documentType;
      if (specialNote != null) {
        request.fields['specialNote'] = specialNote;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to upload document: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  // Method to save chat messages
  Future<Map<String, dynamic>> saveChatMessage({
    required int applicationId,
    required String message,
    bool isSystemMessage = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$applicationId'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'message': message,
          'isSystemMessage': isSystemMessage.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to save chat message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving chat message: $e');
    }
  }
}
