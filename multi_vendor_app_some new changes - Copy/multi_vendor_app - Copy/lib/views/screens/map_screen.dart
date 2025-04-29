import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:multi_vendor_app/views/screens/main_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController mapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late Position _currentPosition;
  Future<void> getUserCurrentLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 16);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            padding: EdgeInsets.only(bottom: 200),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

              mapController = controller;

              getUserCurrentLocation();
            },
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.offAll(MainScreen());
                      },
                      icon: Icon(CupertinoIcons.shopping_cart),
                      label: Text(
                        'SHOP NOW',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
