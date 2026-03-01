import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> profileData;

  const EditProfileScreen({
    super.key,
    required this.accessToken,
    required this.profileData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController goalController;
  late TextEditingController healthController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.profileData["full_name"] ?? "");
    heightController =
        TextEditingController(text: widget.profileData["height"]?.toString() ?? "");
    weightController =
        TextEditingController(text: widget.profileData["weight"]?.toString() ?? "");
    goalController =
        TextEditingController(text: widget.profileData["goal"] ?? "");
    healthController =
        TextEditingController(text: widget.profileData["health_condition"] ?? "");
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/accounts/me/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.accessToken}',
      },
      body: jsonEncode({
        "full_name": nameController.text,
        "height": double.tryParse(heightController.text),
        "weight": double.tryParse(weightController.text),
        "goal": goalController.text,
        "health_condition": healthController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // go back to ProfileScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Update failed ❌"),
          backgroundColor: Color.fromARGB(255, 139, 37, 29),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField("Full Name", nameController),
            buildField("Height", heightController),
            buildField("Weight", weightController),
            buildField("Goal", goalController),
            buildField("Health Condition", healthController),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : saveProfile,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}