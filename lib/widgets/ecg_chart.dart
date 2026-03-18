import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EcgChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final bool showDots;
  final double height;

  const EcgChart({
    super.key,
    required this.data,
    this.lineColor = const Color(0xFF00E676),
    this.showDots = false,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Waiting for ECG data...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: -0.8,
          maxY: 1.5,
          minX: 0,
          maxX: data.length.toDouble() - 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withValues(alpha: 0.3),
                    lineColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              shadow: Shadow(
                color: lineColor.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
        duration: const Duration(milliseconds: 0),
      ),
    );
  }
}
