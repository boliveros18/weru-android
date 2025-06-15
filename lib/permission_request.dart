import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionRequest extends StatefulWidget {
  final Function(bool) onPermissionStatusChanged;

  const PermissionRequest({super.key, required this.onPermissionStatusChanged});

  @override
  State<PermissionRequest> createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.notification,
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.accessMediaLocation,
      Permission.manageExternalStorage,
      Permission.ignoreBatteryOptimizations,
      Permission.phone,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      await openAppSettings();
    }

    widget.onPermissionStatusChanged(allGranted);
  }

  Future<void> checkAndRequestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permissions are permanently denied. Cannot request permissions.');
    } else if (permission == LocationPermission.denied) {
      print('Permissions are denied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
