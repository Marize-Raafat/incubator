import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/vitals_provider.dart';
import '../services/notification_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        final alerts = provider.activeAlerts;

        return Container(
          color: Colors.white,
          child: alerts.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: alerts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return _buildAlertTile(alert);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFF3B6D11), size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Alerts',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3B6D11),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All patient vitals are within normal ranges.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(HealthAlert alert) {
    Color textColor;
    Color bgColor;
    IconData iconData;

    if (alert.level == AlertLevel.critical) {
      textColor = const Color(0xFFE24B4A);
      bgColor = const Color(0xFFFDE9E9);
      iconData = Icons.warning_amber_rounded;
    } else if (alert.level == AlertLevel.warning) {
      textColor = const Color(0xFF854F0B);
      bgColor = const Color(0xFFFAEEDA);
      iconData = Icons.error_outline;
    } else {
      textColor = const Color(0xFF3B6D11);
      bgColor = const Color(0xFFEAF3DE);
      iconData = Icons.info_outline;
    }

    final timeStr = '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}';
    final dateStr = '${alert.timestamp.day}/${alert.timestamp.month}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(iconData, color: textColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black45),
              ),
              Text(
                dateStr,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
