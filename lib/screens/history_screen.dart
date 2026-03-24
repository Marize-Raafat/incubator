import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/vitals_provider.dart';
import '../models/vitals.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        // Reverse history to show newest at top (vitalsHistory appends to end)
        final history = provider.vitalsHistory.reversed.toList();

        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'RECENT READINGS (LAST 60 RECORDS)',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          'Waiting for data...',
                          style: GoogleFonts.inter(color: Colors.black45, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: history.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return _buildHistoryRow(history[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryRow(Vitals vitals) {
    final timeStr = '${vitals.timestamp.hour.toString().padLeft(2, '0')}:${vitals.timestamp.minute.toString().padLeft(2, '0')}:${vitals.timestamp.second.toString().padLeft(2, '0')}';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          SizedBox(
            width: 65,
            child: Text(
              timeStr,
              style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.black54),
            ),
          ),
          
          // Temp
          _buildStatCol(Icons.thermostat, '${vitals.temperature.toStringAsFixed(1)} °C', vitals.isTemperatureNormal ? Colors.black87 : const Color(0xFFE24B4A)),
          
          // HR
          _buildStatCol(Icons.favorite, '${vitals.heartRate} bpm', vitals.isHeartRateNormal ? Colors.black87 : const Color(0xFFE24B4A)),
          
          // Hum
          _buildStatCol(Icons.water_drop, '${vitals.humidity.toStringAsFixed(0)} %', vitals.isHumidityNormal ? Colors.black87 : const Color(0xFFEF9F27)),
          
          // Jaundice
          _buildStatCol(Icons.wb_sunny, '${vitals.jaundiceLevel.toStringAsFixed(1)} %', vitals.jaundiceLevel <= 25 ? Colors.black87 : const Color(0xFFEF9F27)),
        ],
      ),
    );
  }

  Widget _buildStatCol(IconData icon, String value, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.black38),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: color == Colors.black87 ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
