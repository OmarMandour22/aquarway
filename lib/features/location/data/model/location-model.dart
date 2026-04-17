
import 'package:geolocator/geolocator.dart';

class LocationModel {
  final Position position;
  final String address;

  const LocationModel({
    required this.position,
    required this.address,
  });
}