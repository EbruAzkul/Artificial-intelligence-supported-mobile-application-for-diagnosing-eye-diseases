import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationInfo {
  final double latitude;
  final double longitude;
  final String city;
  final String district;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.city = '',
    this.district = '',
  });

  @override
  String toString() {
    return 'Latitude: $latitude, Longitude: $longitude, City: $city, District: $district';
  }
}

class LocationService {
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Konum servisleri kapalı.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Konum izinleri reddedildi.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Konum izinleri kalıcı olarak reddedildi.');
      return false;
    }

    return true;
  }

  Future<LocationInfo?> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'tr_TR',
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        debugPrint('Geocoding sonuçları:');
        debugPrint('administrativeArea: ${place.administrativeArea}');
        debugPrint('subAdministrativeArea: ${place.subAdministrativeArea}');
        debugPrint('locality: ${place.locality}');
        debugPrint('subLocality: ${place.subLocality}');
        debugPrint('country: ${place.country}');

        String city = place.administrativeArea ?? '';
        if (city.isEmpty) {
          city = place.locality ?? '';
        }

        String district = place.subAdministrativeArea ?? '';
        if (district.isEmpty) {
          district = place.subLocality ?? '';
        }

        return LocationInfo(
          latitude: latitude,
          longitude: longitude,
          city: city,
          district: district,
        );
      }
    } catch (e) {
      debugPrint('Geocoding hatası: $e');
    }

    return LocationInfo(
      latitude: latitude,
      longitude: longitude,
      city: '',
      district: '',
    );
  }

  Future<LocationInfo?> getCurrentLocationDetails() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        return null;
      }

      debugPrint('Konum alınıyor...');
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      debugPrint('Konum alındı: ${position.latitude}, ${position.longitude}');

      final LocationInfo? locationInfo = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (locationInfo != null) {
        debugPrint('Final Konum: ${locationInfo.toString()}');
        return locationInfo;
      } else {
        return LocationInfo(
          latitude: position.latitude,
          longitude: position.longitude,
          city: '',
          district: '',
        );
      }
    } catch (e) {
      debugPrint('Konum alınırken hata: $e');
      return null;
    }
  }

  Future<LocationInfo?> enrichLocationInfo(LocationInfo locationInfo) async {
    if (locationInfo.city.isNotEmpty) {
      return locationInfo;
    }

    try {
      return await _getAddressFromCoordinates(
        locationInfo.latitude,
        locationInfo.longitude,
      );
    } catch (e) {
      debugPrint('❌ Konum zenginleştirme hatası: $e');
      return locationInfo;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});