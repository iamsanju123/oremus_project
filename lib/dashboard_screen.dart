import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:oremus_project/login_screen.dart';
import 'package:oremus_project/pai_chart.dart';
import 'package:oremus_project/time_sheet_screen.dart';
import 'bar_chart.dart';
import 'employee_table.dart';
import 'info_cart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  EmployeeInfo? employeeInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEmployeeInfo();
  }

  Future<void> loadEmployeeInfo() async {
    final data = await fetchEmployeeInfo();
    setState(() {
      employeeInfo = data;
      isLoading = false;
    });
  }

  Future<EmployeeInfo?> fetchEmployeeInfo() async {
    try {
      const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJRCI6NDAsIlVTRVJfSUQiOiJlZGE5YmRmMi03NDY1LTRkZGItYWRjZC1iMTBlMzAyMTQwMGEiLCJGVUxMX05BTUUiOiJBbmtpdCBLdW1hciIsIlJPTEUiOiJlbXBsb3llZSIsIk9SR0FOSVpBVElPTl9JRCI6ImQyZmRkMjhlLTNmODMtMTFmMC1iMzJlLTY2YTE5MDQ2N2QyZiIsIk1BTkFHRVJfSUQiOiJlNjcxMWIyNS1mNzIwLTRlY2UtOGZjYy1kZWJlZDI4ZjY2Y2QiLCJpYXQiOjE3NTI3NDg3NjksImV4cCI6MTc1Mjc1MjM2OX0.NVNOVv_cM-3iHbiItANAc-2_F4YhQNK0eIojIoU1spU"; // replace with your actual token

      final response = await http.get(
        Uri.parse("https://api.righted.in/api/auth/dashboard/employee-info"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("HTTP status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          print("Data parsed successfully");
          return EmployeeInfo.fromJson(jsonData['data']);
        } else {
          print("API returned success=false or missing data.");
        }
      } else {
        print("Server responded with status ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: const NavigationDrawer(),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (employeeInfo != null) {
            return buildDashboardContent();
          } else {
            return const Center(
              child: Text(
                "Failed to load employee info.\nPlease check logs.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 6),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "TIME",
                  style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "SHEET",
                  style: TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text("Sanjay", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              InfoCard(
                icon: Icons.show_chart,
                value: employeeInfo!.dailyHours,
                title: "Average Daily Hours",
                diff: employeeInfo!.dailyDiff,
                iconColor: Colors.pink,
                diffColor: employeeInfo!.dailyDiff.startsWith('-') ? Colors.red : Colors.green,
                bgColor: const Color(0xFFFDE6EF),
              ),
              InfoCard(
                icon: Icons.calendar_month,
                value: employeeInfo!.weeklyHours,
                title: "Average Weekly Hours",
                diff: employeeInfo!.weeklyDiff,
                iconColor: Colors.purple,
                diffColor: employeeInfo!.weeklyDiff.startsWith('-') ? Colors.red : Colors.green,
                bgColor: const Color(0xFFF2E7FD),
              ),
              InfoCard(
                icon: Icons.calendar_today,
                value: employeeInfo!.monthlyHours,
                title: "Average Monthly Hours",
                diff: employeeInfo!.monthlyDiff,
                iconColor: Colors.blue,
                diffColor: employeeInfo!.monthlyDiff.startsWith('-') ? Colors.red : Colors.green,
                bgColor: const Color(0xFFDDEEFF),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: BarChartWidget()),
              SizedBox(width: 16),
              Expanded(child: PieChartWidget()),

            ],
          ),
          const SizedBox(height: 20),
          const TimesheetTable(),
        ],
      ),
    );
  }
}

class EmployeeInfo {
  final String dailyHours;
  final String dailyDiff;
  final String weeklyHours;
  final String weeklyDiff;
  final String monthlyHours;
  final String monthlyDiff;

  EmployeeInfo({
    required this.dailyHours,
    required this.dailyDiff,
    required this.weeklyHours,
    required this.weeklyDiff,
    required this.monthlyHours,
    required this.monthlyDiff,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      dailyHours: json['daily_hours']?.toString() ?? '0 hrs',
      dailyDiff: json['daily_diff']?.toString() ?? '',
      weeklyHours: json['weekly_hours']?.toString() ?? '0 hrs',
      weeklyDiff: json['weekly_diff']?.toString() ?? '',
      monthlyHours: json['monthly_hours']?.toString() ?? '0 hrs',
      monthlyDiff: json['monthly_diff']?.toString() ?? '',
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String selectedItem = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(child: Image.asset('assets/images/logo1.png', height: 80)),
            const Divider(height: 30, thickness: 1),
            ListTile(
              leading: Icon(Icons.dashboard,
                  color: selectedItem == 'Dashboard' ? Colors.blue : Colors.black),
              title: Text("Dashboard",
                  style: TextStyle(
                      color: selectedItem == 'Dashboard' ? Colors.blue : Colors.black)),
              onTap: () {
                setState(() => selectedItem = 'Dashboard');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.timer,
                  color: selectedItem == 'Timesheets' ? Colors.blue : Colors.black),
              title: Text("Timesheets",
                  style: TextStyle(
                      color: selectedItem == 'Timesheets' ? Colors.blue : Colors.black)),
              onTap: () {
                setState(() => selectedItem = 'Timesheets');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TimesheetScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
