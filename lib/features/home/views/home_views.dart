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

import '../../profile/views/profile_views.dart';
import '../../chat/views/conversations_view.dart'; // ✔️ ADD THIS
import 'app_drawer_views.dart';

class HomeViews extends StatelessWidget {
  final UserModel userModel;

  const HomeViews({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PropertyCubit(PropertyRepo())),
        BlocProvider(create: (_) => HomeCubit()),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = HomeCubit.get(context);

          return Scaffold(
            key: scaffoldKey,

            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text("AQUARWAY"),
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

            /// ================= BODY FIXED =================
            body: cubit.currentIndex == 0
                ? Column(
              children: [
                /// CATEGORY
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip(context, "All", "all", cubit),
                      _chip(context, "Villas", "villa", cubit),
                      _chip(context, "Apartments", "apartment", cubit),
                      _chip(context, "Land", "land", cubit),
                      _chip(context, "Hotels", "hotel", cubit),
                      _chip(context, "Shops", "shop", cubit),
                      _chip(context, "Training", "training", cubit),
                      _chip(context, "Expat", "expat", cubit),
                    ],
                  ),
                ),

                /// LIST
                Expanded(
                  child: BlocBuilder<PropertyCubit, dynamic>(
                    builder: (context, state) {
                      final propertyCubit =
                      context.read<PropertyCubit>();

                      final stream =
                      propertyCubit.repo.getProperties();

                      return StreamBuilder<List<PropertyModel>>(
                        stream: stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          var list = snapshot.data!;

                          if (cubit.selectedCategory != "all") {
                            list = list
                                .where((e) =>
                            e.type ==
                                cubit.selectedCategory)
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

            /// 💬 CHAT SCREEN (NEW TAB)
                : cubit.currentIndex == 1
                ? ConversationsView(myUser: userModel)

            /// 👤 PROFILE SCREEN
                : ProfileView(uid: userModel.id ?? ""),

            /// ➕ ADD PROPERTY
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.grenblak,
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
              child: const Icon(Icons.add, color: Colors.white),
            ),

            floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,

            /// 🔥 BOTTOM NAV UPDATED
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: cubit.currentIndex == 0
                          ? AppColors.grenblak
                          : Colors.grey,
                    ),
                    onPressed: () => cubit.changeIndex(0),
                  ),

                  /// 💬 CHAT ICON ADDED
                  IconButton(
                    icon: Icon(
                      Icons.chat,
                      color: cubit.currentIndex == 1
                          ? AppColors.grenblak
                          : Colors.grey,
                    ),
                    onPressed: () => cubit.changeIndex(1),
                  ),

                  const SizedBox(width: 40),

                  /// 👤 PROFILE
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color: cubit.currentIndex == 2
                          ? AppColors.grenblak
                          : Colors.grey,
                    ),
                    onPressed: () => cubit.changeIndex(2),
                  ),

                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      scaffoldKey.currentState!.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(
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
        onSelected: (_) => cubit.changeCategory(value),
      ),
    );
  }
}