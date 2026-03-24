import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/vitals.dart';

class EspService {
  String _baseUrl;
  bool _simulationMode;
  final Random _random = Random();
  
  WebSocketChannel? _channel;
  final StreamController<Vitals> _vitalsController = StreamController<Vitals>.broadcast();
  Timer? _simulationTimer;

  // Simulation state for realistic ECG waveform
  int _ecgPhase = 0;
  double _baseTemp = 36.8;
  double _baseHumidity = 50.0;

  EspService({
    String baseUrl = 'http://10.89.230.33', // ESP32 IP from Serial Monitor
    bool simulationMode = true,
  })  : _baseUrl = baseUrl,
        _simulationMode = simulationMode;

  String get baseUrl => _baseUrl;
  bool get isSimulating => _simulationMode;
  
  Stream<Vitals> get vitalsStream => _vitalsController.stream;

  void updateBaseUrl(String url) {
    _baseUrl = url;
    if (!_simulationMode) {
      _connectWebSocket();
    }
  }

  void setSimulationMode(bool enabled) {
    _simulationMode = enabled;
    _simulationTimer?.cancel();
    _channel?.sink.close();
    
    if (_simulationMode) {
      _startSimulation();
    } else {
      _connectWebSocket();
    }
  }

  void connect() {
    if (_simulationMode) {
      _startSimulation();
    } else {
      _connectWebSocket();
    }
  }
  
  void disconnect() {
    _simulationTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _connectWebSocket() {
    _channel?.sink.close(); // Close any existing connection
    
    // Convert http:// IP to ws:// IP on port 81 (as defined in our Arduino sketch)
    String wsUrl = _baseUrl.replaceFirst('http://', 'ws://');
    wsUrl = wsUrl.replaceFirst('https://', 'ws://');
    
    // Removing any trailing paths or ports
    Uri uri = Uri.parse(wsUrl);
    String targetWs = 'ws://${uri.host}:81';
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(targetWs));
      
      _channel!.stream.listen((message) {
        try {
          final Map<String, dynamic> json = jsonDecode(message);
          _vitalsController.add(Vitals.fromJson(json));
        } catch (e) {
          _vitalsController.addError('Failed to parse WebSocket message: $e');
        }
      }, onError: (error) {
         _vitalsController.addError('WebSocket Error: $error');
      }, onDone: () {
         _vitalsController.addError('WebSocket Closed');
         // Could attempt auto-reconnect here...
      });
    } catch (e) {
      _vitalsController.addError('Failed to connect to WebSocket: $e');
    }
  }

  /// Send command to ESP32 (e.g., activate heater)
  /// Uses the HTTP API for commands since WebSockets are mostly for broadcasting data here
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

  /// Start the simulation to pump out data every 100ms
  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _vitalsController.add(_generateSimulatedVitals());
    });
  }

  /// Generate realistic simulated vitals for demo purposes
  Vitals _generateSimulatedVitals() {
    // Generate an array of 10 fast ECG points (representing 100ms of data at 100Hz)
    List<double> simulatedWavefront = [];
    for (int i = 0; i < 10; i++) {
        _ecgPhase = (_ecgPhase + 1) % 100;
        simulatedWavefront.add(_generateEcgSample(_ecgPhase));
    }

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
      ecgValue: simulatedWavefront.last, // Fallback
      ecgWavefront: simulatedWavefront,
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
