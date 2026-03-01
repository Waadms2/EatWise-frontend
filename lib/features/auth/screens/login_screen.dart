import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      showMessage("Please enter your phone number");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/accounts/send-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(phone: phone),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        showMessage(data["error"] ?? "Error sending OTP");
      }
    } catch (e) {
      showMessage("Failed to connect to server");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                "Sign In",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Enter your phone number to continue",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              /// Phone Field
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// Glassy Button
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
                          borderRadius: BorderRadius.circular(30),
                          color: const Color.fromARGB(255, 48, 82, 39).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 10, 107, 10).withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: isLoading ? null : sendOtp,
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
                                      "Send OTP",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: Color.fromARGB(255, 34, 34, 34),
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