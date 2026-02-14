
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/glucose_models.dart';
import 'package:intl/intl.dart';

class GlucoseChart extends StatelessWidget {
  final List<GlucoseMeasurement> history;
  final int? targetMin;
  final int? targetMax;

  const GlucoseChart({
    super.key,
    required this.history,
    this.targetMin,
    this.targetMax,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    // Sort by timestamp
    final sorted = List<GlucoseMeasurement>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Prepare spots
    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.glucoseValue.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sorted.length) {
                  // Show date every 5 points roughly
                  if (index % (sorted.length > 5 ? sorted.length ~/ 5 : 1) == 0) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                         DateFormat('dd/MM HH:mm').format(sorted[index].timestamp),
                         style: const TextStyle(fontSize: 10),
                       ),
                     );
                  }
                }
                return const SizedBox.shrink();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        minX: 0,
        maxX: (sorted.length - 1).toDouble(),
        minY: 0,
        maxY: (sorted.map((e) => e.glucoseValue).reduce((a, b) => a > b ? a : b) + 50).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
        extraLinesData: targetMin != null && targetMax != null
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: targetMin!.toDouble(),
                    color: Colors.green.withOpacity(0.5),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Min'),
                  ),
                   HorizontalLine(
                    y: targetMax!.toDouble(),
                    color: Colors.green.withOpacity(0.5),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Max'),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
