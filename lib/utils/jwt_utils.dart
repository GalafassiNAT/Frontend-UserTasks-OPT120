import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final taskRoute = dotenv.env['TASK_ROUTE'];


Map<String, dynamic> decodeJwtToken(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final resp = utf8.decode(base64Url.decode(normalized));
  final payloadMap = json.decode(resp) as Map<String, dynamic>;
  return payloadMap;

}

Future<String?> getJwtToken() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  return token;
}

Future<String?> getTokenSP() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token;
}

Future<void> removeTokenSP() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}

Future<bool> isTokenValidWithBackendCheck(String? token) async {
  if(token == null){
    return false;
  }

  // Replace with your API endpoint that requires authentication
  final url = Uri.parse('$taskRoute');

  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });

  // If the status code is 401 (Unauthorized), the token is not valid
  if (response.statusCode == 401) {
    return false;
  }

  // Otherwise, assume the token is valid
  return true;
}


Future<bool> isTokenValid(String? token) async{
  if(token == null) {
    return false;
  }
    return await isTokenValidWithBackendCheck(token);
}

void checkTokenExpiration(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid token');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final resp = utf8.decode(base64Url.decode(normalized));
  final payloadMap = json.decode(resp);

  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('Invalid payload');
  }

  final expiry = payloadMap['exp'] as int;
  final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);

  if (expiryDate.isBefore(DateTime.now())) {
    print('Token has expired');
  } else {
    print('Token is valid until $expiryDate');
  }
}