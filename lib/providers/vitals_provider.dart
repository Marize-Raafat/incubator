import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/vitals.dart';
import '../services/esp_service.dart';
import '../services/notification_service.dart';

class VitalsProvider extends ChangeNotifier {
  final EspService _espService;
  final NotificationService _notificationService;
  final ThresholdSettings thresholds = ThresholdSettings();

  Vitals? _currentVitals;
  final Queue<double> _ecgHistory = Queue<double>();
  final List<Vitals> _vitalsHistory = [];
  bool _isConnected = false;
  String? _errorMessage;
  bool _heaterActive = false;
  
  StreamSubscription<Vitals>? _vitalsSubscription;

  static const int ecgBufferSize = 300;

  VitalsProvider({
    required EspService espService,
    required NotificationService notificationService,
  })  : _espService = espService,
        _notificationService = notificationService;

  // Getters
  Vitals? get currentVitals => _currentVitals;
  List<double> get ecgHistory => _ecgHistory.toList();
  List<Vitals> get vitalsHistory => List.unmodifiable(_vitalsHistory);
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  bool get isSimulating => _espService.isSimulating;
  bool get heaterActive => _heaterActive;
  List<HealthAlert> get activeAlerts => _notificationService.activeAlerts;

  /// Start monitoring vitals data via WebSocket stream
  void startMonitoring() {
    _espService.connect();
    
    _vitalsSubscription?.cancel();
    _vitalsSubscription = _espService.vitalsStream.listen(
      (vitals) => _handleNewVitals(vitals),
      onError: (error) {
        _isConnected = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
      onDone: () {
        _isConnected = false;
        _errorMessage = "Connection closed.";
        notifyListeners();
      }
    );
  }

  /// Stop monitoring
  void stopMonitoring() {
    _vitalsSubscription?.cancel();
    _espService.disconnect();
  }

  /// Process incoming data from WebSocket stream
  Future<void> _handleNewVitals(Vitals vitals) async {
    _currentVitals = vitals;
    _isConnected = true;
    _errorMessage = null;

    // Fast Append ECG history from array
    if (vitals.ecgWavefront.isNotEmpty) {
      _ecgHistory.addAll(vitals.ecgWavefront);
    } else {
      _ecgHistory.add(vitals.ecgValue); // Fallback
    }

    while (_ecgHistory.length > ecgBufferSize) {
      _ecgHistory.removeFirst();
    }

    // Keep last 60 vitals records for trends
    _vitalsHistory.add(vitals);
    if (_vitalsHistory.length > 60) {
      _vitalsHistory.removeAt(0);
    }

    // Check thresholds and generate alerts
    final alerts = _notificationService.checkVitals(vitals, thresholds);
    for (final alert in alerts) {
      _notificationService.showNotification(alert);
    }

    // Auto-activate heater if temperature is low
    if (vitals.temperature < thresholds.minTemperature && !_heaterActive) {
      _heaterActive = true;
      await _espService.sendCommand('heater_on');
    } else if (vitals.temperature >= thresholds.minTemperature + 0.5 &&
        _heaterActive) {
      _heaterActive = false;
      await _espService.sendCommand('heater_off');
    }

    notifyListeners();
  }

  /// Update ESP32 base URL
  void updateEspUrl(String url) {
    _espService.updateBaseUrl(url);
    notifyListeners();
  }

  /// Toggle simulation mode
  void setSimulationMode(bool enabled) {
    _espService.setSimulationMode(enabled);
    notifyListeners();
  }

  /// Clear all alerts
  void clearAlerts() {
    _notificationService.clearAlerts();
    notifyListeners();
  }

  String get espUrl => _espService.baseUrl;

  @override
  void dispose() {
    _vitalsSubscription?.cancel();
    _espService.disconnect();
    super.dispose();
  }
}
