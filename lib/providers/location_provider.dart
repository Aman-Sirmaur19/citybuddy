import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String? _country;
  String? _state;
  String? _city;
  double? _latitude;
  double? _longitude;

  String? get country => _country;
  String? get state => _state;
  String? get city => _city;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void setLocation({
    required String country,
    required String state,
    required String city,
    required double latitude,
    required double longitude,
  }) {
    _country = country;
    _state = state;
    _city = city;
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }
}
