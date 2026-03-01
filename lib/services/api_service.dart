import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔗 BACKEND BASE URL
  static const String baseUrl = "http://127.0.0.1:8000";
  // If Android emulator → 10.0.2.2
  // If real phone → your PC IP (e.g. 192.168.1.5)

  /// 📩 SEND OTP
  static Future<bool> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phone}),
    );

    return response.statusCode == 200;
  }

  /// ✅ VERIFY OTP
  static Future<bool> verifyOtp(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phone,
        'otp': code,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['access']);
      return true;
    }
    return false;
  }
}