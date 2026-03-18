import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/vitals_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VitalsProvider>();
    _ipController = TextEditingController(text: provider.espUrl);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monitor Configuration',
                style: GoogleFonts.inter(
                  color: const Color(0xFF042C53),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Connection Settings
              const _SectionHeader(title: 'DATA SOURCE'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _ToggleRow(
                    icon: Icons.science,
                    title: 'Simulation Mode',
                    subtitle: 'Use mocked patient data stream',
                    value: provider.isSimulating,
                    onChanged: (val) => provider.setSimulationMode(val),
                    color: const Color(0xFF185FA5),
                  ),
                  const Divider(color: Colors.black12, height: 30, thickness: 0.5),
                  // ESP URL
                  Row(
                    children: [
                      Icon(Icons.wifi,
                          color: const Color(0xFF185FA5).withValues(alpha: 0.8), size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _ipController,
                          style: GoogleFonts.inter(color: Colors.black87, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Telemetry Server IP',
                            labelStyle: GoogleFonts.inter(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.black.withValues(alpha: 0.15),
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF185FA5),
                                width: 1,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            provider.updateEspUrl(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          provider.updateEspUrl(_ipController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Telemetry source explicitly configured.',
                                style: GoogleFonts.inter(fontSize: 13),
                              ),
                              backgroundColor: const Color(0xFF042C53),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, color: Color(0xFF185FA5)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF185FA5).withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Temperature Thresholds
              const _SectionHeader(title: 'TEMPERATURE ALARMS'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SliderRow(
                    icon: Icons.thermostat,
                    title: 'Lower Limit',
                    value: provider.thresholds.minTemperature,
                    min: 34,
                    max: 37,
                    unit: '°C',
                    color: const Color(0xFF1D9E75),
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.minTemperature = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SliderRow(
                    icon: Icons.thermostat,
                    title: 'Upper Limit',
                    value: provider.thresholds.maxTemperature,
                    min: 37,
                    max: 40,
                    unit: '°C',
                    color: const Color(0xFF1D9E75),
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.maxTemperature = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Heart Rate Thresholds
              const _SectionHeader(title: 'CARDIAC ALARMS'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SliderRow(
                    icon: Icons.favorite,
                    title: 'Bradycardia Limit',
                    value: provider.thresholds.minHeartRate.toDouble(),
                    min: 60,
                    max: 120,
                    unit: 'bpm',
                    color: const Color(0xFFE24B4A),
                    divisions: 60,
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.minHeartRate = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SliderRow(
                    icon: Icons.favorite,
                    title: 'Tachycardia Limit',
                    value: provider.thresholds.maxHeartRate.toDouble(),
                    min: 140,
                    max: 200,
                    unit: 'bpm',
                    color: const Color(0xFFE24B4A),
                    divisions: 60,
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.maxHeartRate = val.round();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Jaundice Threshold
              const _SectionHeader(title: 'PHOTOTHERAPY PROTOCOL'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SliderRow(
                    icon: Icons.wb_sunny,
                    title: 'Intervention Threshold',
                    value: provider.thresholds.jaundiceThreshold,
                    min: 20,
                    max: 80,
                    unit: '%',
                    color: const Color(0xFFEF9F27),
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.jaundiceThreshold = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About
              const _SectionHeader(title: 'FIRMWARE TRADEMARK'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF185FA5).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Color(0xFF185FA5),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'NeoGuard Control System',
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Build TS-2026.04.12 • Verified Firmware\nSecure Telemetry • AD8232 Verified',
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        color: Colors.black.withValues(alpha: 0.45),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: GoogleFonts.inter(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color.withValues(alpha: 0.8),
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
