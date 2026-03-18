import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Connection Settings
              _SectionHeader(title: 'Connection'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  // Simulation toggle
                  _ToggleRow(
                    icon: Icons.science,
                    title: 'Simulation Mode',
                    subtitle: 'Use simulated data instead of ESP32',
                    value: provider.isSimulating,
                    onChanged: (val) => provider.setSimulationMode(val),
                    color: const Color(0xFFFFC107),
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  // ESP URL
                  Row(
                    children: [
                      Icon(Icons.wifi,
                          color: const Color(0xFF448AFF).withValues(alpha: 0.7), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _ipController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'ESP32 IP Address',
                            labelStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF448AFF),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.03),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
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
                              content: Text('ESP URL updated to ${_ipController.text}'),
                              backgroundColor: const Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save, color: Color(0xFF448AFF)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF448AFF).withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Temperature Thresholds
              _SectionHeader(title: 'Temperature Thresholds'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SliderRow(
                    icon: Icons.thermostat,
                    title: 'Min Temperature',
                    value: provider.thresholds.minTemperature,
                    min: 34,
                    max: 37,
                    unit: '°C',
                    color: const Color(0xFF448AFF),
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.minTemperature = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _SliderRow(
                    icon: Icons.thermostat,
                    title: 'Max Temperature',
                    value: provider.thresholds.maxTemperature,
                    min: 37,
                    max: 40,
                    unit: '°C',
                    color: const Color(0xFFFF5252),
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
              _SectionHeader(title: 'Heart Rate Thresholds'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SliderRow(
                    icon: Icons.favorite,
                    title: 'Min Heart Rate',
                    value: provider.thresholds.minHeartRate.toDouble(),
                    min: 60,
                    max: 120,
                    unit: 'bpm',
                    color: const Color(0xFFE040FB),
                    divisions: 60,
                    onChanged: (val) {
                      setState(() {
                        provider.thresholds.minHeartRate = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _SliderRow(
                    icon: Icons.favorite,
                    title: 'Max Heart Rate',
                    value: provider.thresholds.maxHeartRate.toDouble(),
                    min: 140,
                    max: 200,
                    unit: 'bpm',
                    color: const Color(0xFFE040FB),
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
              _SectionHeader(title: 'Jaundice Threshold'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SliderRow(
                    icon: Icons.wb_sunny,
                    title: 'Alert Threshold',
                    value: provider.thresholds.jaundiceThreshold,
                    min: 20,
                    max: 80,
                    unit: 'lvl',
                    color: const Color(0xFFFFD740),
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
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.baby_changing_station,
                        color: Color(0xFF00BCD4),
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Infant Incubator Monitor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'v1.0.0 • ESP32 WiFi Connected\nDHT11 • AD8232 • Color Sensor',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
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
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
        Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
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
            Icon(icon, color: color.withValues(alpha: 0.7), size: 18),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 4,
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
