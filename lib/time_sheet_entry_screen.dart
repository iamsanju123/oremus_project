import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TimesheetEntryScreen extends StatefulWidget {
  const TimesheetEntryScreen({super.key});
  @override
  State<TimesheetEntryScreen> createState() => _TimesheetEntryScreenState();
}

class _TimesheetEntryScreenState extends State<TimesheetEntryScreen> {
  DateTime currentWeekStart = DateTime.now();
  List<AttendanceEntry> attendanceEntries = [];
  bool sendForApproval = false;
  bool isLoading = true;
  final rejectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentWeekStart = _findLastSunday(DateTime.now());
    _loadAttendance();
  }

  DateTime _findLastSunday(DateTime date) =>
      date.subtract(Duration(days: date.weekday % 7));

  String weekRangeString() {
    final end = currentWeekStart.add(const Duration(days: 6));
    final f = DateFormat('dd MMM');
    return '${f.format(currentWeekStart)} - ${f.format(end)}';
  }

  Future<void> _loadAttendance() async {
    setState(() => isLoading = true);
    try {
      final resp = await http.get(
        Uri.parse(
          'https://api.righted.in/api/auth/dashboard/reporting-manager-info=${currentWeekStart.toIso8601String()}',
        ),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(resp.body)['data'] as Map<String, dynamic>;
      final list = data['timesheet_rows'] as List<dynamic>;
      sendForApproval = data['sent_for_approval'] ?? false;
      attendanceEntries =
          list.map((e) => AttendanceEntry.fromJson(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _save() async {
    final payload = attendanceEntries.map((e) => e.toJson()).toList();
    final resp = await http.post(
      Uri.parse('https://api.yoursite.com/timesheet/save'),
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'week_start': currentWeekStart.toIso8601String(),
        'send_for_approval': sendForApproval,
        'entries': payload,
      }),
    );
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved successfully')));
      _loadAttendance();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: ${resp.body}')));
    }
  }

  Future<void> _reject() async {
    final message = rejectionController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a rejection message')),
      );
      return;
    }

    final resp = await http.post(
      Uri.parse('https://api.yoursite.com/timesheet/reject'),
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'week_start': currentWeekStart.toIso8601String(),
        'rejection_message': message,
      }),
    );
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Rejected')));
      rejectionController.clear();
      _loadAttendance();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Reject failed: ${resp.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timesheet Entry')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentWeekStart =
                          currentWeekStart.subtract(const Duration(days: 7));
                    });
                    _loadAttendance();
                  },
                  child: const Text("Previous Week"),
                ),
                const SizedBox(width: 16),
                Text('Week: ${weekRangeString()}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentWeekStart =
                          currentWeekStart.add(const Duration(days: 7));
                    });
                    _loadAttendance();
                  },
                  child: const Text("Next Week"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                  MaterialStateColor.resolveWith((_) => Colors.grey[200]!),
                  columns: [
                    const DataColumn(
                        label: Text("Client", style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text("Billing", style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text("Task", style: TextStyle(fontWeight: FontWeight.bold))),
                    for (int i = 0; i < 7; i++)
                      DataColumn(
                        label: Text(DateFormat('E\ndd MMM')
                            .format(currentWeekStart.add(Duration(days: i)))),
                      ),
                  ],
                  rows: attendanceEntries.map((e) {
                    return DataRow(cells: [
                      DataCell(_dropdownCell(
                          e.client, (v) => e.client = v) as Widget),
                      DataCell(_dropdownCell(
                          e.billing, (v) => e.billing = v) as Widget),
                      DataCell(_dropdownCell(
                          e.task, (v) => e.task = v,
                          fullWidth: true) as Widget),
                      for (int i = 0; i < 7; i++)
                        DataCell(_timeInputCell(e.hours, i) as Widget),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                    value: sendForApproval,
                    onChanged: (v) {
                      setState(() => sendForApproval = v!);
                    }),
                const Text("Send For Approval"),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: rejectionController,
              decoration: const InputDecoration(
                labelText: "Rejection Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _reject,
                  child: const Text("Reject"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _save,
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataCell _timeInputCell(List<String> hours, int dayIndex) {
    return DataCell(TextFormField(
      initialValue: hours[dayIndex],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      onChanged: (val) => hours[dayIndex] = val,
    ));
  }

  DataCell _dropdownCell(String initial, void Function(String) onChange,
      {bool fullWidth = false}) {
    return DataCell(
      SizedBox(
        width: fullWidth ? 200 : 120,
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          value: initial.isNotEmpty ? initial : null,
          items: ["Client A", "Client B"]
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (s) => onChange(s ?? ''),
        ),
      ),
    );
  }
}

class AttendanceEntry {
  String client;
  String billing;
  String task;
  List<String> hours;

  AttendanceEntry({
    required this.client,
    required this.billing,
    required this.task,
    required this.hours,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      client: json['client'] ?? '',
      billing: json['billing'] ?? '',
      task: json['task'] ?? '',
      hours: (json['hours'] as List<dynamic>?)
          ?.map((h) => h.toString())
          .toList() ??
          List.filled(7, '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': client,
      'billing': billing,
      'task': task,
      'hours': hours,
    };
  }
}
