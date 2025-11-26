import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_location_app/widgets/app_dialog.dart';
import 'package:tracking_location_app/widgets/app_logo.dart';
import 'package:tracking_location_app/widgets/constant.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String? _firstName;
  String? _groups;
  String? _email;
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isLoading = false;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkServiceStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final granted = await _requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please grant all the time location permissions to use this feature',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('userid');
      _groups = prefs.getString('groups');
      _email = prefs.getString('email');
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

  Future<bool> _requestPermissions() async {
    // 1. Request "When In Use"
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please grant when in use/all the time location permission to use this feature',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
    }

    // 2. Request "Always"
    var alwaysStatus = await Permission.locationAlways.status;
    if (alwaysStatus.isDenied) {
      alwaysStatus = await Permission.locationAlways.request();
    }

    if (alwaysStatus.isDenied || alwaysStatus.isPermanentlyDenied) {
      return false;
    }

    // 3. Check location service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    return true;
  }

  Future<void> _startTracking() async {
    setState(() => _isLoading = true);

    // STEP 1: When in use
    PermissionStatus whenInUse = await Permission.locationWhenInUse.status;
    if (whenInUse.isDenied || whenInUse.isPermanentlyDenied) {
      whenInUse = await Permission.locationWhenInUse.request();

      if (!whenInUse.isGranted) {
        await openAppSettings();
        setState(() => _isLoading = false);
        return;
      }
    }

    // STEP 2: Always allow
    PermissionStatus always = await Permission.locationAlways.status;

    if (!always.isGranted) {
      bool shouldRequest = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => buildRequestLocationDialog(context),
      );

      if (shouldRequest != true) {
        setState(() => _isLoading = false);
        return;
      }

      always = await Permission.locationAlways.request();
    }

    if (!always.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please allow "Always" location in Settings.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      await openAppSettings();
      setState(() => _isLoading = false);
      return;
    }

    // STEP 3: Location service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please turn on location service'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // STEP 4: Start background service
    await service.startService();
    service.invoke('startService', {
      'firstName': _firstName,
      'groups': _groups,
      'email': _email,
    });

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(myAppLogoSvgData, width: 160, height: 160),
                const SizedBox(height: 16),
                const Text(
                  'Safe Family Alerts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
                const SizedBox(height: 60),
                if (_firstName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        Text(
                          'Welcome, $_firstName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Group: $_groups',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : (_isTracking ? _stopTracking : _startTracking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? appRedColor : appColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              _isTracking ? 'STOP ALERTS' : 'START ALERTS',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stay safe. Alert in seconds.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
