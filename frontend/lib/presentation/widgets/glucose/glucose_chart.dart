import 'dart:ui' show lerpDouble;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/glucose_models.dart';
import '../../../data/models/nutrition_models.dart';
import 'package:intl/intl.dart';

class GlucoseChart extends StatelessWidget {
  final List<GlucoseMeasurement> history;
  final int? targetMin;
  final int? targetMax;

  /// Optional insulin administration events to overlay as orange triangle markers.
  final List<MealLogEntry>? insulinEvents;

  const GlucoseChart({
    super.key,
    required this.history,
    this.targetMin,
    this.targetMax,
    this.insulinEvents,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    // Sort by timestamp
    final sorted = List<GlucoseMeasurement>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Prepare glucose spots
    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.glucoseValue.toDouble());
    }).toList();

    final minVal = (targetMin ?? 90).toDouble();
    final maxVal = (targetMax ?? 180).toDouble();
    final chartMaxY =
        (sorted.map((e) => e.glucoseValue).reduce((a, b) => a > b ? a : b) +
                50)
            .toDouble();

    // Compute insulin marker spots by mapping event timestamps → x-axis indices
    final insulinData = _buildInsulinData(sorted, chartMaxY);

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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                // Series 0 = glucose, Series 1 = insulin markers
                if (spot.barIndex == 1) {
                  final idx = spot.spotIndex;
                  final units = idx < insulinData.bolusUnits.length
                      ? insulinData.bolusUnits[idx]
                      : 0.0;
                  return LineTooltipItem(
                    '💉 ${units.toStringAsFixed(1)} U insulina',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }
                // Glucose tooltip
                final index = spot.x.toInt();
                if (index >= 0 && index < sorted.length) {
                  final m = sorted[index];
                  return LineTooltipItem(
                    '${m.glucoseValue} mg/dL\n${DateFormat('HH:mm').format(m.timestamp)}',
                    const TextStyle(color: Colors.white),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sorted.length) {
                  return const SizedBox.shrink();
                }

                final interval = (sorted.length / 5).ceil();
                if (index % interval != 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Transform.rotate(
                    angle: -0.5,
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
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Colors.grey.shade300)),
        minX: 0,
        maxX: (sorted.length - 1).toDouble(),
        minY: 0,
        maxY: chartMaxY,
        lineBarsData: [
          // Series 0: Glucose line
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          // Series 1: Insulin markers (orange triangles at chart top)
          if (insulinData.spots.isNotEmpty)
            LineChartBarData(
              spots: insulinData.spots,
              isCurved: false,
              barWidth: 0,
              color: Colors.transparent,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    _InsulinDotPainter(
                  bolusUnits: spot.y,
                ),
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
              label: HorizontalLineLabel(
                  show: true, labelResolver: (_) => 'Min'),
            ),
            HorizontalLine(
              y: maxVal,
              color: Colors.blue.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                  show: true, labelResolver: (_) => 'Max'),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps insulin event timestamps to x-axis positions within the glucose chart.
  /// Returns both the FlSpots (for positioning) and the real bolus units (for
  /// tooltips). These two lists are parallel: bolusUnits[i] belongs to spots[i].
  _InsulinChartData _buildInsulinData(
      List<GlucoseMeasurement> sorted, double chartMaxY) {
    final events = insulinEvents;
    if (events == null || events.isEmpty || sorted.length < 2) {
      return _InsulinChartData(const [], const []);
    }

    final firstTs = sorted.first.timestamp.millisecondsSinceEpoch.toDouble();
    final lastTs = sorted.last.timestamp.millisecondsSinceEpoch.toDouble();
    final range = lastTs - firstTs;
    if (range <= 0) return _InsulinChartData(const [], const []);

    final spots = <FlSpot>[];
    final units = <double>[];
    for (final entry in events) {
      final bolus = entry.bolusUnitsAdministered;
      if (bolus == null || bolus <= 0) continue;

      final ts = entry.parsedTimestamp;
      if (ts == null) continue;

      final tsMs = ts.millisecondsSinceEpoch.toDouble();
      if (tsMs < firstTs || tsMs > lastTs) continue;

      final x = (tsMs - firstTs) / range * (sorted.length - 1);
      // y is chart position (near top); actual bolus stored separately
      spots.add(FlSpot(x, chartMaxY - 10));
      units.add(bolus);
    }
    return _InsulinChartData(spots, units);
  }
}

/// Holds parallel lists for insulin marker spots and their real bolus values.
class _InsulinChartData {
  final List<FlSpot> spots;
  final List<double> bolusUnits;
  const _InsulinChartData(this.spots, this.bolusUnits);
}

/// Custom fl_chart dot painter that draws an orange upward triangle (▲).
class _InsulinDotPainter extends FlDotPainter {
  final double bolusUnits;

  _InsulinDotPainter({required this.bolusUnits});

  @override
  void draw(Canvas canvas, FlSpot spot, Offset center) {
    const size = 10.0;
    final paint = Paint()..color = Colors.orange;

    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx - size * 0.8, center.dy + size * 0.5)
      ..lineTo(center.dx + size * 0.8, center.dy + size * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  Size getSize(FlSpot spot) => const Size(20, 20);

  @override
  Color get mainColor => Colors.orange;

  @override
  Color get strokeColor => Colors.deepOrange;

  @override
  double get strokeWidth => 1.0;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    final aP = a as _InsulinDotPainter;
    final bP = b as _InsulinDotPainter;
    return _InsulinDotPainter(
      bolusUnits: lerpDouble(aP.bolusUnits, bP.bolusUnits, t) ?? bolusUnits,
    );
  }

  @override
  List<Object?> get props => [bolusUnits];
}
