import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/vitals_provider.dart';
import '../widgets/vital_card.dart';
import '../widgets/ecg_chart.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        final vitals = provider.currentVitals;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Vital cards grid
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1, // slightly taller to fit 4 lines of text
                ),
                delegate: SliverChildListDelegate([
                  VitalCard(
                    title: 'Temperature',
                    value: vitals?.temperature.toStringAsFixed(1) ?? '36.8',
                    unit: '°C',
                    icon: Icons.thermostat,
                    color: const Color(0xFF1D9E75),
                    status: '✓ Normal',
                    hint: 'Target: 36.0 – 37.5 °C',
                    isAlert: vitals != null && !vitals.isTemperatureNormal,
                  ),
                  VitalCard(
                    title: 'Humidity',
                    value: vitals?.humidity.toStringAsFixed(0) ?? '62',
                    unit: '%',
                    icon: Icons.water_drop,
                    color: const Color(0xFF378ADD),
                    status: '✓ Optimal',
                    hint: 'Target: 60–70 %',
                    isAlert: vitals != null && !vitals.isHumidityNormal,
                  ),
                  VitalCard(
                    title: 'Heart rate',
                    value: vitals?.heartRate.toString() ?? '138',
                    unit: 'bpm',
                    icon: Icons.favorite,
                    color: const Color(0xFFE24B4A),
                    status: '✓ Within normal',
                    hint: 'Normal: 110–160 bpm',
                    isAlert: vitals != null && !vitals.isHeartRateNormal,
                  ),
                  VitalCard(
                    title: 'Jaundice index',
                    value: vitals?.jaundiceLevel.toStringAsFixed(0) ?? '28',
                    unit: '%',
                    icon: Icons.wb_sunny,
                    color: const Color(0xFFEF9F27),
                    status: '⚠ Elevated, monitoring',
                    hint: 'Threshold: < 25 %',
                    isWarning: true,
                  ),
                ]),
              ),
            ),

            // Bottom row: ECG + Alerts/Controls
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildEcgPanel(provider)),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: _buildAlertsAndControls(provider)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildEcgPanel(provider),
                          const SizedBox(height: 12),
                          _buildAlertsAndControls(provider),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEcgPanel(VitalsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ECG SIGNAL — LEAD II · 250 HZ SAMPLING',
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Stack to overlay the grid lines and chart
          Stack(
            children: [
              // Mock grid lines
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dashedLine(),
                    Container(height: 0.5, color: const Color(0xFFE1F5EE)), // baseline
                    _dashedLine(),
                  ],
                ),
              ),
              EcgChart(data: provider.ecgHistory, height: 100),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Normal sinus rhythm detected',
                style: GoogleFonts.inter(fontSize: 10, color: Colors.black54),
              ),
              Text(
                'Refreshed 0.5s ago',
                style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashedLine() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? const Color(0xFFE1F5EE) : Colors.transparent,
            height: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsAndControls(VitalsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alerts List Mock
          _mockAlertRow('✓', 'Temperature stable', const Color(0xFF3B6D11), const Color(0xFFEAF3DE), 'Now'),
          const SizedBox(height: 8),
          _mockAlertRow('✓', 'Heart rate normal', const Color(0xFF3B6D11), const Color(0xFFEAF3DE), 'Now'),
          const SizedBox(height: 8),
          _mockAlertRow('!', 'Jaundice elevated', const Color(0xFF854F0B), const Color(0xFFFAEEDA), '13:10'),
          const SizedBox(height: 8),
          _mockAlertRow('i', 'Humidity adjusted +2%', const Color(0xFF185FA5), const Color(0xFFE6F1FB), '12:44'),
          
          const SizedBox(height: 16),
          Container(height: 0.5, color: Colors.black.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          
          Text(
            'SYSTEM CONTROLS',
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _controlRow('Heater'),
          const SizedBox(height: 8),
          _controlRow('Phototherapy'),
          const SizedBox(height: 8),
          _controlRow('Humidity auto'),
          const SizedBox(height: 8),
          _controlRow('Mobile alerts'),

          const SizedBox(height: 16),
          
          // Jaundice Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jaundice index', style: GoogleFonts.inter(fontSize: 12)),
              Text('28%', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFEF9F27), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.56,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9F27),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
              Text('Safe <25%', style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
              Text('50', style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mockAlertRow(String iconChar, String message, Color textColor, Color bgColor, String time) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            iconChar,
            style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _controlRow(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
        Text(
          'ON',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF3B6D11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
