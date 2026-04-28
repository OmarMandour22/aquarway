import 'package:aquarway/core/utils/app_colors.dart';
import 'package:aquarway/features/Property/views/add_Property_views.dart';
import 'package:aquarway/features/home/views/search_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Property/cubit/Property_cubit.dart';
import '../../Property/data/model/Property_model.dart';
import '../../Property/data/repo/Property_repo.dart';
import '../../../core/widgets/property_card.dart';
import '../../auth/data/model/user_model.dart';
import '../cubit/home_cubit/home_cubit.dart';
import '../cubit/home_cubit/home_state.dart';
import 'app_drawer_views.dart';

class HomeViews extends StatelessWidget {
  final UserModel userModel;

  const HomeViews({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PropertyCubit(PropertyRepo())),
        BlocProvider(create: (_) => HomeCubit()),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final cubit = HomeCubit.get(context);

              return Scaffold(
                key: scaffoldKey,

                appBar: AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'AQUARWAY',
                        style: TextStyle(
                          color: AppColors.grenblak,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<PropertyCubit>(),
                              child: const SearchView(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                endDrawer: AppDrawer(userModel: userModel),

                body: cubit.currentIndex == 0
                    ? Column(
                  children: [

                    /// 🔥 CATEGORY BAR (FIXED)
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _categoryChip(context, "All", "all", cubit),
                          _categoryChip(context, "Villas", "villa", cubit),
                          _categoryChip(context, "Apartments", "apartment", cubit),
                          _categoryChip(context, "Land", "land", cubit),
                          _categoryChip(context, "Hotels", "hotel", cubit),
                          _categoryChip(context, "Shops", "shop", cubit),
                          _categoryChip(context, "Training", "training", cubit),
                          _categoryChip(context, "Expat", "expat", cubit),
                        ],
                      ),
                    ),

                    /// 📦 LIST
                    Expanded(
                      child: BlocBuilder<PropertyCubit, dynamic>(
                        builder: (context, state) {
                          final propertyCubit =
                          context.read<PropertyCubit>();

                          final Stream<List<PropertyModel>> stream =
                          (propertyCubit.searchText.isNotEmpty)
                              ? propertyCubit.search(propertyCubit.searchText)
                              : propertyCubit.repo.getProperties();

                          return StreamBuilder<List<PropertyModel>>(
                            stream: stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<PropertyModel> list = snapshot.data!;

                              /// 🔥 FILTER BY CATEGORY (FIXED)
                              if (cubit.selectedCategory != "all") {
                                list = list
                                    .where((e) =>
                                e.type == cubit.selectedCategory)
                                    .toList();
                              }

                              if (list.isEmpty) {
                                return const Center(
                                  child: Text("No properties found"),
                                );
                              }

                              return ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (_, i) =>
                                    PropertyCard(model: list[i]),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
                    : const Center(child: Text("Page")),

                /// ➕ ADD BUTTON
                floatingActionButton: SizedBox(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PropertyCubit>(),
                            child: AddPropertyView(),
                          ),
                        ),
                      );
                    },
                    backgroundColor: AppColors.grenblak,
                    child: const Icon(
                      Icons.add_home,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

                bottomNavigationBar: BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () => cubit.changeIndex(0),
                        icon: Icon(
                          Icons.home,
                          color: cubit.currentIndex == 0
                              ? AppColors.grenblak
                              : Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () => cubit.changeIndex(1),
                        icon: Icon(
                          Icons.favorite,
                          color: cubit.currentIndex == 1
                              ? AppColors.grenblak
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed: () => cubit.changeIndex(2),
                        icon: Icon(
                          Icons.person,
                          color: cubit.currentIndex == 2
                              ? AppColors.grenblak
                              : Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          scaffoldKey.currentState!.openEndDrawer();
                        },
                        icon: const Icon(Icons.menu),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _categoryChip(
      BuildContext context,
      String label,
      String value,
      HomeCubit cubit,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: cubit.selectedCategory == value,
        onSelected: (val) {
          cubit.changeCategory(value);
        },
      ),
    );
  }
}