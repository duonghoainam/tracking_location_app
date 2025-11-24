import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackingScreen extends StatefulWidget {
  final String userName;

  const TrackingScreen({super.key, required this.userName});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isLoading = false;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();

    service.on('updateLocation').listen((event) {
      if (event != null && mounted) {
        setState(() {
          _currentPosition = Position(
            latitude: (event['latitude'] as num).toDouble(),
            longitude: (event['longitude'] as num).toDouble(),
            timestamp: DateTime.fromMillisecondsSinceEpoch(event['timestamp']),
            accuracy: (event['accuracy'] as num).toDouble(),
            altitude: (event['altitude'] as num).toDouble(),
            heading: (event['heading'] as num).toDouble(),
            speed: (event['speed'] as num).toDouble(),
            speedAccuracy: (event['speed_accuracy'] as num).toDouble(),
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        });
      }
    });
  }

  void _checkServiceStatus() async {
    bool isRunning = await service.isRunning();
    if (mounted) {
      setState(() {
        _isTracking = isRunning;
      });
    }
  }

  Future<void> _startTracking() async {
    setState(() => _isLoading = true);

    final permission = await Permission.location.status;
    if (permission.isDenied) {
      final result = await Permission.location.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please grant location permission to use this feature',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please turn on location service on your device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    await service.startService();
    service.invoke('startService', {'userName': widget.userName});

    if (mounted) {
      setState(() {
        _isTracking = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Started tracking location in the background'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _stopTracking() {
    service.invoke('stopService');
    if (mounted) {
      setState(() {
        _isTracking = false;
        _currentPosition = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stopped tracking location'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Location'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                (_isTracking && _currentPosition != null)
                    ? const EdgeInsets.all(20)
                    : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isTracking && _currentPosition != null) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Current location:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(2)}m',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isTracking) ...[
                      const Icon(
                        Icons.location_searching,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Press the button below to start tracking location',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Currently tracking your location',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : (_isTracking ? _stopTracking : _startTracking),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                _isTracking ? 'Stop Tracking' : 'Send Alert',
                                style: const TextStyle(fontSize: 18),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
