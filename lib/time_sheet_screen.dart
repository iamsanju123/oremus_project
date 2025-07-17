import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oremus_project/edit_timesheet_entry_screen.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  List<double> hours = List.filled(7, 0);
  bool sendForApproval = false;

  // Replace with your actual API endpoint
  final String baseUrl = 'https://dashboard/reporting-manager-info';

  @override
  void initState() {
    super.initState();
    fetchTimesheet();
  }

  Future<void> fetchTimesheet() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/entry?user_id=123'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Example response mapping
        List<dynamic> fetchedHours = data['hours'] ?? List.filled(7, 0);
        setState(() {
          hours = List<double>.from(fetchedHours.map((h) => h.toDouble()));
          sendForApproval = data['send_for_approval'] ?? false;
        });
      } else {
        print("Failed to fetch timesheet");
      }
    } catch (e) {
      print("Error fetching timesheet: $e");
    }
  }

  Future<void> saveTimesheet() async {
    final body = {
      "user_id": 123,
      "client": "divyansh",
      "billing": "Billable",
      "task": "API Integration for Timesheet Submission",
      "week": "04 Aug - 10 Aug",
      "hours": hours,
      "send_for_approval": sendForApproval,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Timesheet saved successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved Successfully")),
        );
      } else {
        print("Failed to save timesheet: ${response.body}");
      }
    } catch (e) {
      print("Error while saving timesheet: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = hours.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timesheet", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekHeader(),
            const SizedBox(height: 16),
            _buildTable(total),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: sendForApproval,
                  onChanged: (val) {
                    setState(() => sendForApproval = val ?? false);
                  },
                ),
                const Text("Send For Approval"),
              ],
            ),
            const SizedBox(height: 12),
            _buildRejectedBox(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveTimesheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text("Save"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
            child: const Text("Previous Week", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 10),
          const Text(
            "Week: 04 Aug - 10 Aug",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
            child: const Text("Next Week", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(double total) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          _buildHeaderRow(),
          _buildDataRow(total),
          _buildInputRow(),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE5E8EF)),
      children: [
        _HeaderCell('Client'),
        _HeaderCell('Billing'),
        _HeaderCell('Task'),
        _HeaderCell('Mon\n04 Aug'),
        _HeaderCell('Tue\n05 Aug'),
        _HeaderCell('Wed\n06 Aug'),
        _HeaderCell('Thu\n07 Aug'),
        _HeaderCell('Fri\n08 Aug'),
        _HeaderCell('Sat\n09 Aug'),
        _HeaderCell('Sun\n10 Aug'),
        _HeaderCell('Total'),
        SizedBox(), // Action icon
      ],
    );
  }

  TableRow _buildDataRow(double total) {
    return TableRow(
      children: [
        _TableCell("divyansh"),
        _TableCell("Billable"),
        _TableCell("API Integration for Timesheet Submission"),
        _HourCell(value: "8.5", color: Colors.red[100]!),
        _HourCell(value: "8", color: Colors.red[100]!),
        _HourCell(value: "8", color: Colors.green[100]!),
        _HourCell(value: "9", color: Colors.green[100]!),
        _HourCell(value: "9", color: Colors.green[100]!),
        const _TableCell(""),
        const _TableCell(""),
        _TableCell(total.toStringAsFixed(1)),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditTimesheetEntryScreen()));
          },
        )
      ],
    );
  }

  TableRow _buildInputRow() {
    return TableRow(
      children: [
        const _DropDownCell(),
        const _DropDownCell(),
        const _DropDownCell(),
        for (int i = 0; i < 7; i++) _HourInput(i),
        _TableCell(hours.reduce((a, b) => a + b).toStringAsFixed(1)),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _HourInput(int index) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 50,
        child: TextFormField(
          initialValue: hours[index].toString(),
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            setState(() {
              hours[index] = double.tryParse(value) ?? 0;
            });
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedBox() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.close, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Rejected by Manager",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Reason: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "hfh"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Supporting Widgets

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  final String value;
  final Color color;
  const _HourCell({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(value),
    );
  }
}

class _DropDownCell extends StatelessWidget {
  const _DropDownCell();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        value: null,
        items: const [
          DropdownMenuItem(value: "Option1", child: Text("Option1")),
          DropdownMenuItem(value: "Option2", child: Text("Option2")),
        ],
        onChanged: (value) {},
        hint: const Text("Select"),
      ),
    );
  }
}
