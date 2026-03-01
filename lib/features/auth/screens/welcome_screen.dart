import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                "Welcome",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Smart Nutrition Assistant",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              /// Cart Image (no background)
              Image.asset(
                'assets/images/green_cart.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              /// Glassy Log In Button
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
                          color: const Color.fromARGB(255, 48, 82, 39)
                              .withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 10, 107, 10)
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LoginScreen(),
                                ),
                              );
                            },
                            child: const Center(
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: Color(0xFF222222),
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}