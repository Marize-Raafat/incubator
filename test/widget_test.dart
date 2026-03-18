import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:baby_incubator/main.dart';
import 'package:baby_incubator/providers/vitals_provider.dart';
import 'package:baby_incubator/services/esp_service.dart';
import 'package:baby_incubator/services/notification_service.dart';

void main() {
  testWidgets('App renders dashboard screen', (WidgetTester tester) async {
    final espService = EspService(simulationMode: true);
    final notificationService = NotificationService();
    await notificationService.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => VitalsProvider(
              espService: espService,
              notificationService: notificationService,
            )..startMonitoring(),
          ),
        ],
        child: const BabyIncubatorApp(),
      ),
    );

    // Verify the app renders with the dashboard title
    expect(find.text('Infant Incubator'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

