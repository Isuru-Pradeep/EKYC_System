import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
