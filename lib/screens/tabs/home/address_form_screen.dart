import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../../helper/api.dart';
import '../../../providers/location_provider.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  Future<void> getCoordinates() async {
    if (_selectedCity != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        List<Location> locations = await locationFromAddress(
            "$_selectedCity, $_selectedState, $_selectedCountry");
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
        Provider.of<LocationProvider>(context, listen: false).setLocation(
          country: _selectedCountry!,
          state: _selectedState!,
          city: _selectedCity!,
          latitude: _latitude!,
          longitude: _longitude!,
        );
      } catch (e) {
        print("Error getting coordinates: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text(
          'Address Form',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SelectState(
              onCountryChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _selectedState = null;
                  _selectedCity = null;
                  _latitude = null;
                  _longitude = null;
                });
              },
              onStateChanged: (value) {
                setState(() {
                  _selectedState = value;
                  _selectedCity = null;
                  _latitude = null;
                  _longitude = null;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  _selectedCity = value;
                  _latitude = null;
                  _longitude = null;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Selected Address: $_selectedCountry, $_selectedState, $_selectedCity",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: getCoordinates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Get Latitude & Longitude"),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(
                  child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent)),
            if (_latitude != null && _longitude != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Latitude: ",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      "$_latitude",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Longitude: ",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      "$_longitude",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => APIs.openGoogleMap(_latitude!, _longitude!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text("Google Map"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
