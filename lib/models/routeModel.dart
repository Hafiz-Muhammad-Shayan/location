
class RouteModel {
  final double distance; // Meters mein
  final double duration; // Seconds mein

  RouteModel({
    required this.distance,
    required this.duration,
  });

  // Factory constructor jo JSON data ko RouteModel mein convert karega
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    return RouteModel(
      distance: (route['distance'] as num).toDouble(),
      duration: (route['duration'] as num).toDouble(),
    );
  }
}