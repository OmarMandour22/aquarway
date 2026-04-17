import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../model/location-model.dart';

class LocationRepo {
  Future<Either<String, LocationModel>> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left('خدمة الموقع غير مفعلة');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return const Left('تم رفض إذن الموقع');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final address = await _getAddress(position.latitude, position.longitude);

      return Right(LocationModel(
        position: position,
        address: address,
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> getAddressFromLatLng(
      double lat,
      double lng,
      ) async {
    try {
      final address = await _getAddress(lat, lng);
      return Right(address);
    } catch (e) {
      return Left("فشل تحديد العنوان");
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isEmpty) return "Unknown location";

    final place = placemarks.first;

    return [
      place.street,
      place.locality,
      place.administrativeArea,
      place.country
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }
}