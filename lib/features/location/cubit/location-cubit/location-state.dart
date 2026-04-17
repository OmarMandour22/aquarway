import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationSuccess extends LocationState {
  final LatLng latLng;
  final String address;
  final Set<Marker> markers;

  const LocationSuccess({
    required this.latLng,
    required this.address,
    required this.markers,
  });
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);
}