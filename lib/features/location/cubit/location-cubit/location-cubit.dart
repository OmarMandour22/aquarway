import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/model/location-model.dart';
import '../../data/repo/location-repo.dart';
import 'location-state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this.repo) : super(const LocationInitial());

  static LocationCubit get(context) => BlocProvider.of(context);

  final LocationRepo repo;
  final Completer<GoogleMapController> controller = Completer();

  static const MarkerId _markerId = MarkerId("selected_location");

  Future<void> getLocation() async {
    emit(const LocationLoading());

    final response = await repo.getLocation();

    response.fold(
          (error) => emit(LocationError(error)),
          (data) => _emitLocation(data),
    );
  }

  Future<void> changeLocation(LatLng newLocation) async {
    emit(const LocationLoading());

    final result = await repo.getAddressFromLatLng(
      newLocation.latitude,
      newLocation.longitude,
    );

    result.fold(
          (error) => emit(LocationError(error)),
          (address) {
        final markers = {
          Marker(markerId: _markerId, position: newLocation)
        };

        emit(LocationSuccess(
          latLng: newLocation,
          address: address,
          markers: markers,
        ));

        _moveCamera(newLocation);
      },
    );
  }

  void _emitLocation(LocationModel data) {
    final latLng = LatLng(
      data.position.latitude,
      data.position.longitude,
    );

    final markers = {
      Marker(markerId: _markerId, position: latLng)
    };

    emit(LocationSuccess(
      latLng: latLng,
      address: data.address,
      markers: markers,
    ));

    _moveCamera(latLng);
  }

  Future<void> _moveCamera(LatLng target) async {
    if (controller.isCompleted) {
      final mapController = await controller.future;
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(target, 15),
      );
    }
  }
}