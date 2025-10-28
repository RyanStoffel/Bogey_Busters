import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class LocationService {
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<Position> getCurrentPosition() async {
    bool hasPermission = await hasLocationPermission();

    if (!hasPermission) {
      hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    // Using Haversine formula to calculate distance in meters
    const earthRadius = 6371000; // meters

    final dLat = _degreesToRadians(endLatitude - startLatitude);
    final dLon = _degreesToRadians(endLongitude - startLongitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  String formatDistanceYards(double meters) {
    final yards = meters * 1.09361;
    if (yards < 1000) {
      return '${yards.toStringAsFixed(0)} yds';
    } else {
      return '${(yards / 1000).toStringAsFixed(2)} k yds';
    }
  }
}
