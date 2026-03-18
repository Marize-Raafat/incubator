import '../models/vitals.dart';

/// Alert level enumeration
enum AlertLevel { normal, warning, critical }

/// Represents an active alert
class HealthAlert {
  final String title;
  final String message;
  final AlertLevel level;
  final DateTime timestamp;

  HealthAlert({
    required this.title,
    required this.message,
    required this.level,
    required this.timestamp,
  });
}

class NotificationService {
  final List<HealthAlert> _activeAlerts = [];
  final Map<String, DateTime> _lastAlertTime = {};
  static const Duration _cooldown = Duration(seconds: 30);

  List<HealthAlert> get activeAlerts => List.unmodifiable(_activeAlerts);

  /// Initialize notification service
  Future<void> initialize() async {
    // Notification initialization placeholder
    // In production, initialize flutter_local_notifications here
  }

  /// Check vitals against thresholds and generate alerts
  List<HealthAlert> checkVitals(Vitals vitals, ThresholdSettings thresholds) {
    final newAlerts = <HealthAlert>[];

    // Temperature check
    if (vitals.temperature < thresholds.minTemperature) {
      final alert = _createAlertIfCooldown(
        'temp_low',
        'Low Temperature ⚠️',
        'Temperature is ${vitals.temperature}°C — below minimum ${thresholds.minTemperature}°C. Heater activated.',
        AlertLevel.critical,
      );
      if (alert != null) newAlerts.add(alert);
    } else if (vitals.temperature > thresholds.maxTemperature) {
      final alert = _createAlertIfCooldown(
        'temp_high',
        'High Temperature ⚠️',
        'Temperature is ${vitals.temperature}°C — above maximum ${thresholds.maxTemperature}°C.',
        AlertLevel.critical,
      );
      if (alert != null) newAlerts.add(alert);
    }

    // Heart rate check
    if (vitals.heartRate < thresholds.minHeartRate) {
      final alert = _createAlertIfCooldown(
        'hr_low',
        'Low Heart Rate ⚠️',
        'Heart rate is ${vitals.heartRate} bpm — below minimum ${thresholds.minHeartRate} bpm.',
        AlertLevel.critical,
      );
      if (alert != null) newAlerts.add(alert);
    } else if (vitals.heartRate > thresholds.maxHeartRate) {
      final alert = _createAlertIfCooldown(
        'hr_high',
        'High Heart Rate ⚠️',
        'Heart rate is ${vitals.heartRate} bpm — above maximum ${thresholds.maxHeartRate} bpm.',
        AlertLevel.critical,
      );
      if (alert != null) newAlerts.add(alert);
    }

    // Humidity check
    if (vitals.humidity < thresholds.minHumidity ||
        vitals.humidity > thresholds.maxHumidity) {
      final alert = _createAlertIfCooldown(
        'humidity',
        'Humidity Alert',
        'Humidity is ${vitals.humidity}% — outside normal range (${thresholds.minHumidity}–${thresholds.maxHumidity}%).',
        AlertLevel.warning,
      );
      if (alert != null) newAlerts.add(alert);
    }

    // Jaundice check
    if (vitals.jaundiceLevel > thresholds.jaundiceThreshold) {
      final alert = _createAlertIfCooldown(
        'jaundice',
        'Jaundice Alert 🟡',
        'Jaundice level is ${vitals.jaundiceLevel.toStringAsFixed(1)} — above threshold ${thresholds.jaundiceThreshold}.',
        AlertLevel.warning,
      );
      if (alert != null) newAlerts.add(alert);
    }

    // Add new alerts to active list
    _activeAlerts.insertAll(0, newAlerts);
    // Keep only last 50
    if (_activeAlerts.length > 50) {
      _activeAlerts.removeRange(50, _activeAlerts.length);
    }

    return newAlerts;
  }

  /// Create an alert only if cooldown has elapsed
  HealthAlert? _createAlertIfCooldown(
    String key,
    String title,
    String message,
    AlertLevel level,
  ) {
    final now = DateTime.now();
    final lastTime = _lastAlertTime[key];

    if (lastTime != null && now.difference(lastTime) < _cooldown) {
      return null; // Still in cooldown
    }

    _lastAlertTime[key] = now;
    return HealthAlert(
      title: title,
      message: message,
      level: level,
      timestamp: now,
    );
  }

  /// Show a system notification
  Future<void> showNotification(HealthAlert alert) async {
    // In production, use flutter_local_notifications to show OS notification
    // For now, alerts are tracked in-app via the _activeAlerts list
  }

  /// Clear all alerts
  void clearAlerts() {
    _activeAlerts.clear();
  }
}
