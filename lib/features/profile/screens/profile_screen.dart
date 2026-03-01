import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String accessToken;

  const ProfileScreen({super.key, required this.accessToken});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String selectedGoal = "Maintain";
  String selectedHealth = "None";
  String selectedAllergy = "None";

  double? bmi;
  bool isLoading = false;
  bool isFetching = true;

  final List<String> goals = ["Lose", "Maintain", "Gain"];
  final List<String> healthOptions = [
    "None",
    "Diabetes",
    "Blood Pressure",
    "Heart Disease"
  ];
  final List<String> allergyOptions = [
    "None",
    "Nuts",
    "Dairy",
    "Seafood",
    "Gluten"
  ];

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // ===============================
  // FETCH PROFILE FROM BACKEND
  // ===============================
  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse("hhttp://127.0.0.1:8000/api/accounts/me/"),
        headers: {
          "Authorization": "Bearer ${widget.accessToken}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          nameController.text = data["full_name"] ?? "";
          heightController.text =
              data["height"]?.toString() ?? "";
          weightController.text =
              data["weight"]?.toString() ?? "";
          ageController.text =
              data["age"]?.toString() ?? "";

          selectedGoal = data["goal"] ?? "Maintain";
          selectedHealth =
              data["health_condition"] ?? "None";
          selectedAllergy =
              data["allergies"] ?? "None";
        });

        calculateBMI();
      }
    } catch (e) {
      showMessage("Failed to load profile",
          color: Colors.red);
    }

    setState(() => isFetching = false);
  }

  // ===============================
  // SAVE PROFILE TO BACKEND
  // ===============================
  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    try {
      final response = await http.patch(
        Uri.parse(
            "http://127.0.0.1:8000/api/accounts/me/update/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${widget.accessToken}",
        },
        body: jsonEncode({
          "full_name": nameController.text,
          "height":
              double.tryParse(heightController.text),
          "weight":
              double.tryParse(weightController.text),
          "age": int.tryParse(ageController.text),
          "goal": selectedGoal,
          "health_condition": selectedHealth,
          "allergies": selectedAllergy,
        }),
      );

      if (response.statusCode == 200) {
        showMessage("Profile saved successfully ✅");
      } else {
        showMessage("Update failed ❌",
            color: Colors.red);
      }
    } catch (e) {
      showMessage("Server error ❌",
          color: Colors.red);
    }

    setState(() => isLoading = false);
  }

  void showMessage(String message,
      {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ===============================
  // BMI LOGIC (UNCHANGED)
  // ===============================
  void calculateBMI() {
    double? height =
        double.tryParse(heightController.text);
    double? weight =
        double.tryParse(weightController.text);

    if (height != null &&
        weight != null &&
        height > 0) {
      double heightInMeters = height / 100;
      setState(() {
        bmi = weight /
            (heightInMeters * heightInMeters);
      });
    } else {
      setState(() {
        bmi = null;
      });
    }
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  // ===============================
  // UI (UNCHANGED)
  // ===============================
  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
                  horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 45,
                backgroundColor:
                    Color(0xFFE0E5E2),
                child: Icon(
                  Icons.person,
                  size: 45,
                  color:
                      Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),

              _label("Full Name"),
              _textField(nameController,
                  "Enter your full name"),

              const SizedBox(height: 20),

              _label("Height (cm)"),
              _textField(
                heightController,
                "Enter height",
                keyboardType:
                    TextInputType.number,
                onChanged: (_) =>
                    calculateBMI(),
              ),

              const SizedBox(height: 20),

              _label("Weight (kg)"),
              _textField(
                weightController,
                "Enter weight",
                keyboardType:
                    TextInputType.number,
                onChanged: (_) =>
                    calculateBMI(),
              ),

              const SizedBox(height: 20),

              _label("Age"),
              _textField(
                ageController,
                "Enter age",
                keyboardType:
                    TextInputType.number,
              ),

              const SizedBox(height: 20),

              if (bmi != null)
                Container(
                  padding:
                      const EdgeInsets.all(
                          16),
                  margin:
                      const EdgeInsets.only(
                          bottom: 20),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(20),
                  ),
                  child: Text(
                    "BMI: ${bmi!.toStringAsFixed(1)} (${getBMICategory(bmi!)})",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),

              _label("Goal"),
              _dropdown(
                  selectedGoal, goals,
                  (val) {
                setState(() =>
                    selectedGoal = val);
              }),

              const SizedBox(height: 20),

              _label("Health Condition"),
              _dropdown(selectedHealth,
                  healthOptions, (val) {
                setState(() =>
                    selectedHealth =
                        val);
              }),

              const SizedBox(height: 20),

              _label("Allergies"),
              _dropdown(selectedAllergy,
                  allergyOptions, (val) {
                setState(() =>
                    selectedAllergy =
                        val);
              }),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: GestureDetector(
                  onTap: isLoading
                      ? null
                      : saveProfile,
                  child: Container(
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(30),
                      color:
                          const Color(
                                  0xFF305227)
                              .withOpacity(
                                  0.15),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Save Profile",
                              style:
                                  TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment:
          Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(
                bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType =
        TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  20),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown(
      String value,
      List<String> items,
      Function(String) onChanged) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                20),
      ),
      child:
          DropdownButtonHideUnderline(
        child:
            DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) =>
                  DropdownMenuItem(
                    value: item,
                    child: Text(
                        item),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue !=
                null) {
              onChanged(
                  newValue);
            }
          },
        ),
      ),
    );
  }
}