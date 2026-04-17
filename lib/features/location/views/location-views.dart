import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cubit/location-cubit/location-cubit.dart';
import '../cubit/location-cubit/location-state.dart';
import '../data/repo/location-repo.dart';

class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationCubit(LocationRepo())..getLocation(),
      child: const _LocationBody(),
    );
  }
}

class _LocationBody extends StatelessWidget {
  const _LocationBody();

  @override
  Widget build(BuildContext context) {
    final cubit = LocationCubit.get(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationError) {
            return Center(child: Text(state.message));
          }

          if (state is LocationSuccess) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    state.address,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: state.latLng,
                      zoom: 14,
                    ),
                    markers: state.markers,
                    myLocationEnabled: true,
                    onTap: cubit.changeLocation,
                    onMapCreated: (controller) {
                      if (!cubit.controller.isCompleted) {
                        cubit.controller.complete(controller);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        {
                          "lat": state.latLng.latitude,
                          "lng": state.latLng.longitude,
                          "address": state.address,
                        },
                      );
                    },
                    child: const Text("تأكيد العنوان"),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}