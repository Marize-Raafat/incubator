import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/vitals.dart';

class EspService {
  String _baseUrl;
  bool _simulationMode;
  final Random _random = Random();

  // Simulation state for realistic ECG waveform
  int _ecgPhase = 0;
  double _baseTemp = 36.8;
  double _baseHumidity = 50.0;

  EspService({
    String baseUrl = 'http://192.168.4.1',
    bool simulationMode = true,
  })  : _baseUrl = baseUrl,
        _simulationMode = simulationMode;

  String get baseUrl => _baseUrl;
  bool get isSimulating => _simulationMode;

  void updateBaseUrl(String url) {
    _baseUrl = url;
  }

  void setSimulationMode(bool enabled) {
    _simulationMode = enabled;
  }

  /// Fetch current vitals from ESP32 or generate simulated data
  Future<Vitals> fetchVitals() async {
    if (_simulationMode) {
      return _generateSimulatedVitals();
    }

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/vitals'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Vitals.fromJson(json);
      } else {
        throw Exception('ESP returned status ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection to ESP32 timed out');
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  /// Send command to ESP32 (e.g., activate heater)
  Future<bool> sendCommand(String command, {Map<String, dynamic>? params}) async {
    if (_simulationMode) return true;

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/command'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'command': command, ...?params}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Generate realistic simulated vitals for demo purposes
  Vitals _generateSimulatedVitals() {
    _ecgPhase = (_ecgPhase + 1) % 100;

    // Slowly drift temperature
    _baseTemp += (_random.nextDouble() - 0.5) * 0.05;
    _baseTemp = _baseTemp.clamp(35.5, 38.0);

    // Slowly drift humidity
    _baseHumidity += (_random.nextDouble() - 0.5) * 0.3;
    _baseHumidity = _baseHumidity.clamp(35.0, 65.0);

    return Vitals(
      temperature: double.parse(_baseTemp.toStringAsFixed(1)),
      humidity: double.parse(_baseHumidity.toStringAsFixed(1)),
      heartRate: 130 + _random.nextInt(21) - 10, // 120-150 bpm
      ecgValue: _generateEcgSample(_ecgPhase),
      jaundiceLevel: 20.0 + _random.nextDouble() * 15, // 20-35 normal range
      timestamp: DateTime.now(),
    );
  }

  /// Generate a realistic ECG waveform sample (PQRST pattern)
  double _generateEcgSample(int phase) {
    double t = phase / 100.0;
    double value = 0;

    // P wave
    if (t >= 0.0 && t < 0.1) {
      value = 0.25 * sin(pi * (t / 0.1));
    }
    // PR segment
    else if (t >= 0.1 && t < 0.15) {
      value = 0;
    }
    // Q wave
    else if (t >= 0.15 && t < 0.18) {
      value = -0.15 * sin(pi * ((t - 0.15) / 0.03));
    }
    // R wave (tall spike)
    else if (t >= 0.18 && t < 0.24) {
      value = 1.0 * sin(pi * ((t - 0.18) / 0.06));
    }
    // S wave
    else if (t >= 0.24 && t < 0.28) {
      value = -0.3 * sin(pi * ((t - 0.24) / 0.04));
    }
    // ST segment
    else if (t >= 0.28 && t < 0.4) {
      value = 0.05;
    }
    // T wave
    else if (t >= 0.4 && t < 0.55) {
      value = 0.35 * sin(pi * ((t - 0.4) / 0.15));
    }
    // Baseline
    else {
      value = 0;
    }

    // Add slight noise
    value += (_random.nextDouble() - 0.5) * 0.02;
    return value;
  }
}
