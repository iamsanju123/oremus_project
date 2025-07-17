import 'package:flutter/material.dart';

class TimesheetTable extends StatelessWidget {
  const TimesheetTable({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> timesheetData = [
      {
        "week": "Sep 15, 2025 – Sep 21, 2025",
        "hours": 75,
        "status": "Pending",
        "submitted": "7/13/2025",
        "color": Colors.orange
      },
      {
        "week": "Sep 1, 2025 – Sep 7, 2025",
        "hours": 43,
        "status": "Rejected",
        "submitted": "7/12/2025",
        "color": Colors.red
      },
      {
        "week": "Aug 25, 2025 – Aug 31, 2025",
        "hours": 54,
        "status": "Approved",
        "submitted": "7/11/2025",
        "color": Colors.green
      },
      {
        "week": "Aug 18, 2025 – Aug 24, 2025",
        "hours": 43,
        "status": "Approved",
        "submitted": "7/10/2025",
        "color": Colors.green
      },
      {
        "week": "Aug 11, 2025 – Aug 17, 2025",
        "hours": 50,
        "status": "Rejected",
        "submitted": "7/9/2025",
        "color": Colors.red
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Timesheet Records",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("Week")),
                  DataColumn(label: Text("Total Hours")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Submitted At")),
                  DataColumn(label: Text("Action")),
                ],
                rows: timesheetData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data['week'])),
                      DataCell(Text(data['hours'].toString())),
                      DataCell(Text(
                        data['status'],
                        style: TextStyle(
                          color: data['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      DataCell(Text(data['submitted'])),
                      DataCell(
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "View",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
