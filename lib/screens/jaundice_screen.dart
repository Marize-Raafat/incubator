import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vitals_provider.dart';

class JaundiceScreen extends StatelessWidget {
  const JaundiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        final vitals = provider.currentVitals;
        final level = vitals?.jaundiceLevel ?? 0;
        final status = vitals?.jaundiceStatus ?? 'N/A';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Jaundice Detection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bilirubin level estimation via color sensor',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Main gauge
              Center(
                child: _JaundiceGauge(level: level, status: status),
              ),
              const SizedBox(height: 32),

              // Status card
              _StatusCard(level: level, status: status),
              const SizedBox(height: 20),

              // Info cards
              _InfoSection(),
            ],
          ),
        );
      },
    );
  }
}

class _JaundiceGauge extends StatelessWidget {
  final double level;
  final String status;

  const _JaundiceGauge({required this.level, required this.status});

  Color get _statusColor {
    if (level < 30) return const Color(0xFF4CAF50);
    if (level < 50) return const Color(0xFFFFC107);
    if (level < 70) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _statusColor.withValues(alpha: 0.2),
            _statusColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny,
            color: _statusColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            level.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: _statusColor.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: _statusColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final double level;
  final String status;

  const _StatusCard({required this.level, required this.status});

  @override
  Widget build(BuildContext context) {
    String recommendation;
    IconData icon;
    Color color;

    if (level < 30) {
      recommendation = 'Bilirubin levels are within normal range. No action needed.';
      icon = Icons.check_circle_outline;
      color = const Color(0xFF4CAF50);
    } else if (level < 50) {
      recommendation =
          'Mild elevation detected. Continue monitoring. Consider phototherapy evaluation.';
      icon = Icons.info_outline;
      color = const Color(0xFFFFC107);
    } else if (level < 70) {
      recommendation =
          'Moderate elevation detected. Phototherapy recommended. Notify healthcare provider.';
      icon = Icons.warning_amber;
      color = const Color(0xFFFF9800);
    } else {
      recommendation =
          'Severe elevation detected! Immediate medical attention required. Intensive phototherapy needed.';
      icon = Icons.error_outline;
      color = const Color(0xFFF44336);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jaundice Scale',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _ScaleRow(label: 'Normal', range: '0 – 30', color: const Color(0xFF4CAF50)),
          _ScaleRow(label: 'Mild', range: '30 – 50', color: const Color(0xFFFFC107)),
          _ScaleRow(label: 'Moderate', range: '50 – 70', color: const Color(0xFFFF9800)),
          _ScaleRow(label: 'Severe', range: '70 – 100', color: const Color(0xFFF44336)),
          const SizedBox(height: 12),
          Text(
            'Detection via color sensor / LDR module',
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

class _ScaleRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _ScaleRow({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
