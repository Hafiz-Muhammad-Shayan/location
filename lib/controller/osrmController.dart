import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart'; // <-- 1. Yeh import zaroori hai kIsWeb ke liye
import 'package:geolocator/geolocator.dart';

class OSRMController extends GetxController {
  final Dio dio = Dio();

  // 1. Start Point: Live Current Location
  var currentLat = 24.8607.obs;
  var currentLng = 67.0011.obs;
  var hasCurrentLocation = false.obs;

  // 2. End Point: Map Tapped Destination
  var tappedLat = 0.0.obs;
  var tappedLng = 0.0.obs;
  var hasDestination = false.obs;

  // 3. UI States
  var distanceText = "".obs;
  var durationText = "".obs;
  var isLoading = false.obs;

  var routeCoordinates = <LatLng>[].obs;

  // Real GPS Location Fetch Karne Ka Function
  Future<void> getCurrentLocation() async {
    // 🛑 2. WEB SAFETY CHECK: Agar app PC / Chrome browser par chal rahi hai,
    // toh Geolocator ko call mat karo warna woh internal Completer error dega!
    if (kIsWeb) {
      currentLat.value = 24.8607; // Default Karachi Center
      currentLng.value = 67.0011;
      hasCurrentLocation.value = true;

      Get.snackbar("Web Mode Notice", "Browser par GPS limitation ki wajah se default Karachi location set ki gayi hai.");
      print("Web Mode: Geolocator bypassed successfully, no crash!");
      return;
    }

    // --- MOBILE (Android / iOS) KE LIYE ASLI CODE ---
    bool serviceEnabled;
    LocationPermission permission;

    // A. Check karein ke phone ka GPS on hai ya nahi
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled. Please turn on GPS.");
      return;
    }

    // B. Location permissions check karein
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Location permissions are permanently denied.");
      return;
    }

    // C. Jab permissions mil jayein, toh asal live position uthayein!
    try {
      isLoading.value = true;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
      hasCurrentLocation.value = true;

      Get.snackbar("Success", "Live Current Location Fetched!");
      print("Live Location -> Lat: ${currentLat.value}, Lng: ${currentLng.value}");
    } catch (e) {
      Get.snackbar("Error", "Could not get live location: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Map Tap: Destination set karne ke liye
  void onMapTapped(LatLng clickedLatLng) {
    tappedLat.value = clickedLatLng.latitude;
    tappedLng.value = clickedLatLng.longitude;
    hasDestination.value = true;
    print("Destination Selected -> Lat: ${tappedLat.value}, Lng: ${tappedLng.value}");
  }

  // Route Fetch Karne Ka Function (Live Current Location -> Tapped Destination)
  Future<void> fetchRoute() async {
    if (!hasCurrentLocation.value) {
      Get.snackbar("Alert", "Pehle 'My Location' button daba kar apni current location fetch karein!");
      return;
    }
    if (!hasDestination.value) {
      Get.snackbar("Alert", "Pehle map par destination tap karein!");
      return;
    }

    isLoading.value = true;

    try {
      // OSRM Format: Longitude,Latitude
      String startCoord = "${currentLng.value},${currentLat.value}";
      String endCoord = "${tappedLng.value},${tappedLat.value}";

      final url = "https://router.project-osrm.org/route/v1/driving/$startCoord;$endCoord?overview=full&geometries=geojson";

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;

        double distanceInMeters = data['routes'][0]['distance'];
        double durationInSeconds = data['routes'][0]['duration'];

        final coords = data["routes"][0]["geometry"]["coordinates"] as List;

        routeCoordinates.clear() ;

        for (var coord in coords ) {
        double lng = coord[0] ;
        double lat = coord[1] ;
        routeCoordinates.add(LatLng(lat, lng)) ;

        print("route coordinates loading : ${routeCoordinates.length} points " ) ;
        }

        double distanceInKm = distanceInMeters / 1000;
        distanceText.value = "${distanceInKm.toStringAsFixed(2)} km";

        double durationInMins = durationInSeconds / 60;
        durationText.value = "${durationInMins.toStringAsFixed(0)} mins";

        print("Route Fetched: ${distanceText.value}");
      }
    } catch (e) {
      print("API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}