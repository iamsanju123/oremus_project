import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTimesheetEntryScreen extends StatefulWidget {
  const EditTimesheetEntryScreen({super.key});

  @override
  State<EditTimesheetEntryScreen> createState() => _EditTimesheetEntryScreenState();
}

class _EditTimesheetEntryScreenState extends State<EditTimesheetEntryScreen> {
  final List<String> days = [
    "Mon 11/08/2025",
    "Tue 12/08/2025",
    "Wed 13/08/2025",
    "Thu 14/08/2025",
    "Fri 15/08/2025",
    "Sat 16/08/2025",
    "Sun 17/08/2025",
  ];

  final List<TextEditingController> controllers = List.generate(7, (_) => TextEditingController());
  final double fieldWidth = 210;

  // Replace with your actual API endpoint
  final String updateApiUrl = 'https://your-api.com/api/timesheet/update';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: Center(
        child: Container(
          width: 750,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Blue Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Edit Timesheet Entry",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Task name
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Task Name", style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Card(
                        color: Color(0xFFF5F6F8),
                        child: ListTile(
                          leading: Icon(Icons.location_on_outlined, color: Colors.black),
                          title: Text("API Integration for Timesheet Submission"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // First row (3 inputs)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 115, child: buildDayInput(0)),
                    SizedBox(width: 115, child: buildDayInput(1)),
                    SizedBox(width: 115, child: buildDayInput(2)),
                  ],
                ),
                const SizedBox(height: 20),

                // Second row (3 inputs)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 115, child: buildDayInput(3)),
                    SizedBox(width: 115, child: buildDayInput(4)),
                    SizedBox(width: 115, child: buildDayInput(5)),
                  ],
                ),
                const SizedBox(height: 20),

                // Third row (1 input)
                Row(
                  children: [
                    SizedBox(width: 115, child: buildDayInput(6)),
                  ],
                ),

                const SizedBox(height: 30),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: updateEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Update Entry", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDayInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(days[index], style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controllers[index],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.access_time_outlined),
            suffixText: "hrs",
            hintText: "0.0",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Future<void> updateEntry() async {
    List<double> hours = [];

    for (var controller in controllers) {
      double hour = double.tryParse(controller.text.trim()) ?? 0.0;
      hours.add(hour);
    }

    final body = {
      "user_id": 123,
      "task": "API Integration for Timesheet Submission",
      "week": "11 Aug - 17 Aug",
      "hours": hours,
    };

    try {
      final response = await http.post(
        Uri.parse(updateApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entry updated successfully")),
        );
        Navigator.pop(context);
      } else {
        print("Failed to update: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("API Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server")),
      );
    }
  }
}
