import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title on top
            const Text(
              "Monthly Trend",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Pie Chart and Legend side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                        sections: _getSections(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Legend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Year 2025',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C4043),
                      ),
                    ),
                    SizedBox(height: 10),
                    LegendItem(color: Colors.orange, label: 'Jul'),
                    LegendItem(color: Colors.blue, label: 'Aug'),
                    LegendItem(color: Colors.red, label: 'Sep'),
                    LegendItem(color: Colors.green, label: 'Oct'),
                    LegendItem(color: Colors.purple, label: 'Jun'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    const data = [
      {'value': "", 'color': '', 'label': ''},
      {'value': "", 'color': '', 'label': ''},
      {'value': "", 'color': '', 'label': ''},
      {'value': "", 'color': '', 'label': ''},
      {'value': "", 'color': '', 'label': ''},
    ];

    return List.generate(data.length, (i) {
      final item = data[i];
      return PieChartSectionData(
        value: item['value'] as double,
        title: item['label'] as String,
        color: item['color'] as Color,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: item['color'] as Color,
        ),
        radius: 80,
        titlePositionPercentageOffset: 1.2,
      );
    });
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
