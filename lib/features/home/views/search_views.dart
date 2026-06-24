import 'package:aquarway/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Property/cubit/Property_cubit.dart';
import '../../Property/data/model/Property_model.dart';
import '../../../core/widgets/property_card.dart';
import '../../auth/data/model/user_model.dart';
import '../../auth/data/repo/auth_repo.dart';
import '../../profile/views/profile_views.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchController = TextEditingController();
  List<UserModel> searchedUsers = [];

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PropertyCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Column(
        children: [

          /// 🔍 SEARCH FIELD (UNCHANGED UI)
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) async {
                cubit.searchText = value;

                searchedUsers =
                await AuthRepo().searchUsersCombined(value);

                setState(() {});
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

          /// 🎯 FILTERS (UNCHANGED UI)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [

                TextField(
                  onChanged: (value) {
                    cubit.locationFilter = value;
                    setState(() {});
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
                        value: cubit.selectedType,
                        items: const [
                          "شقق",
                          "فنادق",
                          "فيلات",
                          "محلات",
                          "اراضي",
                          "مراكز تدريب",
                          "شقق للمغتربين",
                        ]
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (v) {
                          cubit.changeType(v ?? "");
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        hint: const Text("Status"),
                        value: cubit.selectedStatus,
                        items: const [
                          "للبيع",
                          "للإيجار",
                        ]
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (v) {
                          cubit.changeStatus(v ?? "");
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                RangeSlider(
                  values: RangeValues(
                    (cubit.minPrice ?? 0).toDouble(),
                    (cubit.maxPrice ?? 1000000).toDouble(),
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



          if (searchedUsers.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchedUsers.length,
                itemBuilder: (_, i) {
                  final user = searchedUsers[i];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        user.image != null && user.image!.isNotEmpty
                            ? NetworkImage(user.image!)
                            : null,
                        child: user.image == null ||
                            user.image!.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user.username ?? "Unknown User"),
                      subtitle: Text(user.email ?? ""),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileView(
                              uid: user.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),


          /// 🏠 RESULTS (FIXED STREAM WITHOUT REPO ISSUE)
          Expanded(
            child: StreamBuilder<List<PropertyModel>>(
              stream: cubit.repo.getProperties(), // ✅ FIX HERE
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<PropertyModel> list = snapshot.data!;

                final query = cubit.searchText.toLowerCase();

                list = list.where((e) {
                  final matchSearch = query.isEmpty ||
                      (e.title ?? "")
                          .toLowerCase()
                          .contains(query);

                  final matchType = cubit.selectedType == null ||
                      cubit.selectedType == "" ||
                      e.type == cubit.selectedType;

                  final matchStatus = cubit.selectedStatus == null ||
                      cubit.selectedStatus == "" ||
                      e.status == cubit.selectedStatus;

                  final matchLocation = cubit.locationFilter == null ||
                      cubit.locationFilter!.isEmpty ||
                      (e.location ?? "")
                          .toLowerCase()
                          .contains(cubit.locationFilter!.toLowerCase());

                  final price = double.tryParse(e.price ?? "0") ?? 0;

                  final matchMin = cubit.minPrice == null || price >= cubit.minPrice!;
                  final matchMax = cubit.maxPrice == null || price <= cubit.maxPrice!;

                  return matchSearch &&
                      matchType &&
                      matchStatus &&
                      matchLocation &&
                      matchMin &&
                      matchMax;
                }).toList();

                if (list.isEmpty) {
                  return const Center(child: Text("No results found"));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    return PropertyCard(model: list[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}