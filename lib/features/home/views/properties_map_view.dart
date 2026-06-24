import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../Property/data/model/Property_model.dart';
import '../../Property/data/repo/Property_repo.dart';


class PropertiesMapView extends StatefulWidget {
  const PropertiesMapView({super.key});

  @override
  State<PropertiesMapView> createState() => _PropertiesMapViewState();
}

class _PropertiesMapViewState extends State<PropertiesMapView> {
  final repo = PropertyRepo();

  GoogleMapController? mapController;

  String typeFilter = "all";
  String statusFilter = "all";

  LatLng? userLocation;

  List<PropertyModel> nearbyProperties = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// ================= USER LOCATION =================
  Future<void> _getUserLocation() async {
    Position pos = await Geolocator.getCurrentPosition();

    setState(() {
      userLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  /// ================= DISTANCE =================
  double _distance(LatLng a, LatLng b) {
    const R = 6371;

    double dLat = _deg(b.latitude - a.latitude);
    double dLng = _deg(b.longitude - a.longitude);

    double x =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_deg(a.latitude)) *
                cos(_deg(b.latitude)) *
                sin(dLng / 2) *
                sin(dLng / 2);

    return R * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  double _deg(double v) => v * (pi / 180);

  /// ================= MARKER COLOR =================
  BitmapDescriptor _markerColor(String? type) {
    switch (type) {
      case "villa":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case "apartment":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case "land":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  /// ================= ZOOM TO PROPERTY =================
  void _goTo(LatLng pos) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PropertyModel>>(
      stream: repo.getProperties(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        final filtered = data.where((p) {
          if (p.lat == null || p.lng == null) return false;

          if (typeFilter != "all" && p.type != typeFilter) return false;
          if (statusFilter != "all" && p.status != statusFilter) return false;

          return true;
        }).toList();

        /// ================= NEARBY LOGIC =================
        if (userLocation != null) {
          filtered.sort((a, b) {
            final distA = _distance(
              userLocation!,
              LatLng(a.lat!, a.lng!),
            );

            final distB = _distance(
              userLocation!,
              LatLng(b.lat!, b.lng!),
            );

            return distA.compareTo(distB);
          });

          nearbyProperties = filtered.take(5).toList();
        }

        /// ================= MARKERS =================
        Set<Marker> markers = filtered.map((p) {
          final pos = LatLng(p.lat!, p.lng!);

          final distance = userLocation == null
              ? null
              : _distance(userLocation!, pos);

          return Marker(
            markerId: MarkerId(p.id ?? ""),
            position: pos,
            icon: _markerColor(p.type),

            onTap: () {
              _showBottomSheet(p, distance);
            },
          );
        }).toSet();

        return Scaffold(
          appBar: AppBar(
            title: const Text("خريطة العقارات"),

            actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  if (userLocation != null) {
                    _goTo(userLocation!);
                  }
                },
              ),
            ],
          ),

          body: Stack(
            children: [
              /// ================= MAP =================
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(30.0444, 31.2357),
                  zoom: 10,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,

                onMapCreated: (c) => mapController = c,
              ),

              /// ================= FILTER =================
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: _filters(),
              ),

              /// ================= NEARBY PROPERTIES =================
              if (nearbyProperties.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: nearbyProperties.length,
                      itemBuilder: (context, i) {
                        final p = nearbyProperties[i];

                        final distance = userLocation == null
                            ? null
                            : _distance(
                          userLocation!,
                          LatLng(p.lat!, p.lng!),
                        );

                        return GestureDetector(
                          onTap: () {
                            _goTo(LatLng(p.lat!, p.lng!));
                            _showBottomSheet(p, distance);
                          },

                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 5,
                                  color: Colors.black12,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text("${p.price} جنيه"),

                                const Spacer(),

                                if (distance != null)
                                  Text(
                                    "📍 ${distance.toStringAsFixed(1)} كم",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// ================= FILTER UI =================
  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          DropdownButton<String>(
            value: typeFilter,
            items: const [
              DropdownMenuItem(value: "all", child: Text("الكل")),
              DropdownMenuItem(value: "villa", child: Text("فيلا")),
              DropdownMenuItem(value: "apartment", child: Text("شقة")),
              DropdownMenuItem(value: "land", child: Text("أرض")),
            ],
            onChanged: (v) => setState(() => typeFilter = v!),
          ),

          const SizedBox(width: 10),

          DropdownButton<String>(
            value: statusFilter,
            items: const [
              DropdownMenuItem(value: "all", child: Text("الكل")),
              DropdownMenuItem(value: "للبيع", child: Text("بيع")),
              DropdownMenuItem(value: "للإيجار", child: Text("إيجار")),
            ],
            onChanged: (v) => setState(() => statusFilter = v!),
          ),
        ],
      ),
    );
  }

  /// ================= BOTTOM SHEET =================
  void _showBottomSheet(PropertyModel p, double? distance) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text("💰 السعر: ${p.price} جنيه"),
              Text("🏷️ النوع: ${p.type}"),

              if (distance != null)
                Text(
                  "📍 يبعد عنك: ${distance.toStringAsFixed(1)} كم",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // هنا تفتح تفاصيل العقار
                  },
                  child: const Text("عرض التفاصيل"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}