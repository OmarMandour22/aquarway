import 'package:aquarway/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADD THIS

import '../../Property/cubit/Property_cubit.dart';
import '../../Property/data/model/Property_model.dart';
import '../../../core/widgets/property_card.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<PropertyModel> properties = [];
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDoc;

  @override
  void initState() {
    super.initState();

    fetchData();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final cubit = context.read<PropertyCubit>();

    final result = await cubit.searchAdvanced(
      search: searchController.text,
      lastDoc: lastDoc,
    );

    if (result.isNotEmpty) {
      lastDoc = result.last.createdAt as DocumentSnapshot?; // ✅ FIX SAFE CAST
      properties.addAll(result);
    } else {
      hasMore = false;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PropertyCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Column(
        children: [

          /// 🔍 SEARCH FIELD
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                cubit.searchText = value;

                properties.clear();
                lastDoc = null;
                hasMore = true;
                fetchData();
              },
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🎯 FILTERS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [

                TextField(
                  onChanged: (value) {
                    cubit.locationFilter = value;
                  },
                  decoration: const InputDecoration(
                    hintText: "Location",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        hint: const Text("Type"),
                        items: const [
                          "شقق",
                          "فنادق",
                          "فيلات",
                          "محلات",
                          "اراضي",
                        ]
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (v) => cubit.selectedType = v,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        hint: const Text("Status"),
                        items: const [
                          "للبيع",
                          "للإيجار",
                        ]
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (v) => cubit.selectedStatus = v,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                RangeSlider(
                  values: RangeValues(
                    (cubit.minPrice ?? 0).toDouble(),       // ✅ FIX
                    (cubit.maxPrice ?? 1000000).toDouble(),  // ✅ FIX
                  ),
                  min: 0,
                  max: 1000000,
                  onChanged: (values) {
                    cubit.minPrice = values.start;
                    cubit.maxPrice = values.end;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 🏠 RESULTS
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: properties.length + 1,
              itemBuilder: (_, i) {
                if (i < properties.length) {
                  return PropertyCard(model: properties[i]);
                } else {
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}