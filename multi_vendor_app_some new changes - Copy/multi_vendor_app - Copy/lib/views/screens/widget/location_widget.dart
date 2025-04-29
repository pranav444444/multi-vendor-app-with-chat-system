import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String currentAddress = 'Fetching location...';
  final locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentAddress = 'Location permissions denied';
            locationController.text = currentAddress;
          });
          return;
        }
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,  // Changed to best accuracy
        timeLimit: const Duration(seconds: 15),  // Added timeout
      );

      // Convert coordinates to address with more details
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Create a more detailed address string
          currentAddress = [
            if (place.name?.isNotEmpty ?? false) place.name,
            if (place.subLocality?.isNotEmpty ?? false) place.subLocality,
            if (place.street?.isNotEmpty ?? false) place.street,
            if (place.locality?.isNotEmpty ?? false) place.locality,
            if (place.subAdministrativeArea?.isNotEmpty ?? false) 
              place.subAdministrativeArea,
            if (place.postalCode?.isNotEmpty ?? false) place.postalCode,
          ].where((element) => element != null && element.isNotEmpty)
              .join(', ');
          
          locationController.text = currentAddress;
          
          // Print detailed information for debugging
          print('Detailed Location Info:');
          print('Name: ${place.name}');
          print('Street: ${place.street}');
          print('SubLocality: ${place.subLocality}');
          print('Locality: ${place.locality}');
          print('SubAdministrativeArea: ${place.subAdministrativeArea}');
          print('PostalCode: ${place.postalCode}');
          print('Coordinates: ${position.latitude}, ${position.longitude}');
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = 'Error fetching location: $e';
        locationController.text = currentAddress;
        print('Location Error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Image.asset('assets/icons/store-1.png'),
          ),
          const SizedBox(width: 15),
          Image.asset('assets/icons/pickicon.png', width: 30),
          const SizedBox(width: 8),
          Flexible(
            child: SizedBox(
              width: 300,
              child: TextFormField(
                controller: locationController,
                readOnly: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Fetching location...',
                  labelText: 'Current Location',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.pink),
                    onPressed: _getCurrentLocation,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
