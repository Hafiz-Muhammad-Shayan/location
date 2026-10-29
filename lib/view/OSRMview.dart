import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:osrmtutorial/components/customButton.dart';
import 'package:osrmtutorial/controller/osrmController.dart';

class OSRMView extends StatelessWidget {
  const OSRMView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller ko initialize karna
    final OSRMController controller = Get.put(OSRMController());
    MapController mapController = MapController() ;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Navigation App'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Control Panel (Distance, Time & Both Buttons)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.deepPurple.shade50,
            child: Column(
              children: [
                // Distance aur Duration Display (Obx ke sath reactive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Obx(() => Text(
                      "Distance: ${controller.distanceText.value.isEmpty ? '--' : controller.distanceText.value}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                    Obx(() => Text(
                      "Time: ${controller.durationText.value.isEmpty ? '--' : controller.durationText.value}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Dono Buttons (My Location & Get Route)
                Row(
                  children: [
                    // Button 1: Live Current Location fetch karne ke liye
                    Expanded(
                      child: CustomButton(
                        text: 'My Location',
                        onPressed: () {
                          controller.getCurrentLocation();
                          mapController.move(LatLng(controller.currentLat.value, controller.currentLng.value), 14.0) ;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Button 2: OSRM Route calculate karne ke liye
                    Expanded(
                      child: Obx(() => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                        text: 'Get Route',
                        onPressed: () async {
                           await controller.fetchRoute();

                          if (controller.routeCoordinates.isNotEmpty) {
                            final bounds = LatLngBounds.fromPoints([
                              LatLng(controller.currentLat.value, controller.currentLng.value) ,
                              LatLng(controller.tappedLat.value, controller.tappedLng.value) ,
                            ]
                            ) ;

                            mapController.fitCamera(
                              CameraFit.bounds(
                                bounds: bounds ,
                                padding: const EdgeInsets.all(50.0) ,
                              ) ,
                            ) ;

                          }
                        },
                      )),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: CustomButton(
                        text: 'Reset Route',
                        onPressed: () {
                          controller.clearRoute();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Map View (Jahan user tap karke destination chunega)
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(24.8607, 67.0011), // Default Karachi
                initialZoom: 14.0,
                onTap: (tapPosition, clickedLatLng) {
                  // Map par tap hone par destination set hogi
                  controller.onMapTapped(clickedLatLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.osrmtutorial', // <-- Apne app ki actual applicationId yahan likhein
                ),
                // poliline layer
                Obx(() => PolylineLayer(
                    polylines: [
                      if (controller.routeCoordinates.isNotEmpty)
                        Polyline(
                          points: controller.routeCoordinates,
                          strokeWidth: 4.0 ,
                          color: Colors.blueAccent ,
                        ),

                    ] ,
                ),
              ) ,


                // Markers Layer (Live Location aur Destination Pins ke liye)
                Obx(() => MarkerLayer(
                  markers: [
                    // Agar live current location aa chuki ho toh Blue Pin
                    if (controller.hasCurrentLocation.value)
                      Marker(
                        point: LatLng(controller.currentLat.value, controller.currentLng.value),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.blue, size: 35),
                      ),
                    // Agar map par tap karke destination select ki ho toh Red Flag/Pin
                    if (controller.hasDestination.value)
                      Marker(
                        point: LatLng(controller.tappedLat.value, controller.tappedLng.value),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.red, size: 35),
                      ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}