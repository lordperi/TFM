
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

    final minVal = (targetMin ?? 90).toDouble();
    final maxVal = (targetMax ?? 180).toDouble();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: minVal,
              y2: maxVal,
              color: Colors.blue.withOpacity(0.1),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, // Increased for rotated text
              interval: 1, // We control filtering in getTitlesWidget
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sorted.length) return const SizedBox.shrink();
                
                // Show max 5 labels
                final interval = (sorted.length / 5).ceil();
                if (index % interval != 0) return const SizedBox.shrink();

                return Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: Transform.rotate(
                      angle: -0.5, // Rotate roughly 30 degrees
                      child: Text(
                        DateFormat('dd/MM HH:mm').format(sorted[index].timestamp),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
              },
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
              show: false, // Turn off since we have the range band
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: minVal,
              color: Colors.blue.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Min'),
            ),
            HorizontalLine(
              y: maxVal,
              color: Colors.blue.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Max'),
            ),
          ],
        ),
      ),
    );
  }
}
