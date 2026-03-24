class Vitals {
  final double temperature;
  final double humidity;
  final int heartRate;
  final double ecgValue; // Keep for backwards compatibility
  final List<double> ecgWavefront; // New array from WebSockets
  final double jaundiceLevel;
  final DateTime timestamp;

  Vitals({
    required this.temperature,
    required this.humidity,
    required this.heartRate,
    this.ecgValue = 0.0,
    this.ecgWavefront = const [],
    required this.jaundiceLevel,
    required this.timestamp,
  });

  factory Vitals.fromJson(Map<String, dynamic> json) {
    // Check if we have an array of ECG values (WebSocket)
    List<double> wavefront = [];
    if (json.containsKey('ecgWavefront') && json['ecgWavefront'] is List) {
      wavefront = (json['ecgWavefront'] as List).map((e) {
        double raw = (e as num).toDouble();
        // Normalize 0-4095 to range -1.0 to 1.0 roughly
        return (raw - 2048) / 2048.0;
      }).toList();
    }

    // Handle single value legacy (HTTP poll)
    double singleEcg = 0.0;
    if (json.containsKey('ecgValue') && json['ecgValue'] is num) {
      singleEcg = (json['ecgValue'] as num).toDouble();
      if (wavefront.isEmpty) {
        singleEcg = (singleEcg - 2048) / 2048.0;
      }
    }

    return Vitals(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
      ecgValue: singleEcg,
      ecgWavefront: wavefront,
      jaundiceLevel: (json['jaundiceLevel'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'heartRate': heartRate,
        'ecgValue': ecgValue,
        'jaundiceLevel': jaundiceLevel,
        'timestamp': timestamp.toIso8601String(),
      };

  // Helper getters for status evaluation
  bool get isTemperatureNormal => temperature >= 36.0 && temperature <= 37.5;
  bool get isHeartRateNormal => heartRate >= 100 && heartRate <= 160;
  bool get isHumidityNormal => humidity >= 40 && humidity <= 60;
  bool get isJaundiceNormal => jaundiceLevel < 50;

  String get temperatureStatus {
    if (temperature < 36.0) return 'LOW';
    if (temperature > 37.5) return 'HIGH';
    return 'NORMAL';
  }

  String get heartRateStatus {
    if (heartRate < 100) return 'LOW';
    if (heartRate > 160) return 'HIGH';
    return 'NORMAL';
  }

  String get jaundiceStatus {
    if (jaundiceLevel < 30) return 'NORMAL';
    if (jaundiceLevel < 50) return 'MILD';
    if (jaundiceLevel < 70) return 'MODERATE';
    return 'SEVERE';
  }
}

class ThresholdSettings {
  double minTemperature;
  double maxTemperature;
  int minHeartRate;
  int maxHeartRate;
  double minHumidity;
  double maxHumidity;
  double jaundiceThreshold;

  ThresholdSettings({
    this.minTemperature = 36.0,
    this.maxTemperature = 37.5,
    this.minHeartRate = 100,
    this.maxHeartRate = 160,
    this.minHumidity = 40,
    this.maxHumidity = 60,
    this.jaundiceThreshold = 25,
  });
}
