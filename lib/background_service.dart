import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  String userName = 'defaultUser';
  service.on('startService').listen((event) {
    if (event != null && event['userName'] != null) {
      userName = event['userName'];
    }
  });

  Geolocator.getPositionStream(
    locationSettings:
        Platform.isAndroid
            ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              intervalDuration: const Duration(
                seconds: 60,
              ), // ⏱ update every 60 seconds
              distanceFilter: 0,
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationText: "Tracking your location...",
                notificationTitle: "Tracking is running",
                enableWakeLock: true,
              ),
            )
            : AppleSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 0,
              pauseLocationUpdatesAutomatically: false,
              activityType: ActivityType.fitness,
              allowBackgroundLocationUpdates: true,
            ),
  ).listen((Position position) {
    service.invoke('updateLocation', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': position.timestamp.millisecondsSinceEpoch,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'heading': position.heading,
      'speed': position.speed,
      'speed_accuracy': position.speedAccuracy,
    });

    final url = Uri.parse(
      'https://grannyflatteam.com/location/alert'
      '?lat=${position.latitude}&lon=${position.longitude}&userid=$userName',
    );

    http
        .get(url)
        .then((response) {
          if (response.statusCode == 200) {
            print(
              '✅ Sent location: ${position.latitude}, ${position.longitude} at ${DateTime.now()}',
            );
          } else {
            print('⚠️ Failed to send location: ${response.statusCode}');
          }
        })
        .catchError((e) {
          print('❌ Error sending location: $e');
        });
  });
}
