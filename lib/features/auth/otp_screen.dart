import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../profile/screens/profile_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({
    super.key,
    required this.phone,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  void showMessage(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> login() async {
    final code = otpController.text.trim();

    if (code.isEmpty) {
      showMessage("Please enter the OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        // ✅ IMPORTANT: use 10.0.2.2 for Android emulator
        Uri.parse('http://127.0.0.1:8000/api/accounts/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone_number": widget.phone,
          "code": code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final accessToken = data["access"];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(
              accessToken: accessToken,
            ),
          ),
        );
      } else {
        showMessage(data["error"] ?? "Verification failed");
      }
    } catch (e) {
      showMessage("Server connection failed");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              const Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Enter the OTP sent to ${widget.phone}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Enter 6-digit OTP",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30),
                          color: const Color(0xFF305227)
                              .withOpacity(0.15),
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A6B0A)
                                  .withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(30),
                            onTap: isLoading ? null : login,
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Verify",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w600,
                                        color:
                                            Color(0xFF222222),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}