import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vitals_provider.dart';
import '../widgets/vital_card.dart';
import '../widgets/ecg_chart.dart';
import '../widgets/status_indicator.dart';
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
            // App bar area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Infant Incubator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time Monitoring',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    StatusIndicator(
                      label: 'ESP32',
                      isConnected: provider.isConnected,
                      isSimulating: provider.isSimulating,
                    ),
                  ],
                ),
              ),
            ),

            // Heater status banner
            if (provider.heaterActive)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.whatshot, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Heater Active — Restoring Temperature',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Vital cards grid
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate([
                  VitalCard(
                    title: 'Temperature',
                    value: vitals?.temperature.toStringAsFixed(1) ?? '--',
                    unit: '°C',
                    icon: Icons.thermostat,
                    color: const Color(0xFFFF5252),
                    status: vitals?.temperatureStatus ?? 'N/A',
                    isAlert: vitals != null && !vitals.isTemperatureNormal,
                  ),
                  VitalCard(
                    title: 'Humidity',
                    value: vitals?.humidity.toStringAsFixed(1) ?? '--',
                    unit: '%',
                    icon: Icons.water_drop,
                    color: const Color(0xFF448AFF),
                    status: vitals != null && vitals.isHumidityNormal
                        ? 'NORMAL'
                        : (vitals != null ? 'ALERT' : 'N/A'),
                    isAlert: vitals != null && !vitals.isHumidityNormal,
                  ),
                  VitalCard(
                    title: 'Heart Rate',
                    value: vitals?.heartRate.toString() ?? '--',
                    unit: 'bpm',
                    icon: Icons.favorite,
                    color: const Color(0xFFE040FB),
                    status: vitals?.heartRateStatus ?? 'N/A',
                    isAlert: vitals != null && !vitals.isHeartRateNormal,
                  ),
                  VitalCard(
                    title: 'Jaundice',
                    value: vitals?.jaundiceLevel.toStringAsFixed(1) ?? '--',
                    unit: 'lvl',
                    icon: Icons.wb_sunny,
                    color: const Color(0xFFFFD740),
                    status: vitals?.jaundiceStatus ?? 'N/A',
                    isAlert: vitals != null && !vitals.isJaundiceNormal,
                  ),
                ]),
              ),
            ),

            // Mini ECG preview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monitor_heart,
                                  color: const Color(0xFF00E676).withValues(alpha: 0.8),
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'ECG Monitor',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${vitals?.heartRate ?? "--"} BPM',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      EcgChart(
                        data: provider.ecgHistory,
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Alerts section
            if (provider.activeAlerts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Alerts',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => provider.clearAlerts(),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Color(0xFF448AFF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...provider.activeAlerts.take(3).map(
                            (alert) => _AlertTile(alert: alert),
                          ),
                    ],
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final HealthAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = alert.level == AlertLevel.critical
        ? const Color(0xFFF44336)
        : const Color(0xFFFFC107);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            alert.level == AlertLevel.critical
                ? Icons.error_outline
                : Icons.warning_amber,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
