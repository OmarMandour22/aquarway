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

    /// 🔥 GlobalKey
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
                key: scaffoldKey, // 👈 مهم

                appBar: AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Home",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

                /// 👇 BODY
                body: cubit.currentIndex == 0
                    ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          context.read<PropertyCubit>().searchText = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Search properties...",
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
                    Expanded(
                      child: BlocBuilder<PropertyCubit, dynamic>(
                        builder: (context, state) {
                          final propertyCubit = context.read<PropertyCubit>();

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

                              final list = snapshot.data!;

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

                /// 🔥 زر الإضافة
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

                /// 🔥 Bottom Bar
                bottomNavigationBar: BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          cubit.changeIndex(0);
                        },
                        icon: Icon(
                          Icons.home,
                          color: cubit.currentIndex == 0
                              ? AppColors.grenblak
                              : Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          cubit.changeIndex(1);
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: cubit.currentIndex == 1
                              ? AppColors.grenblak
                              : Colors.grey,
                        ),
                      ),

                      const SizedBox(width: 40),

                      IconButton(
                        onPressed: () {
                          cubit.changeIndex(2);
                        },
                        icon: Icon(
                          Icons.person,
                          color: cubit.currentIndex == 2
                              ? AppColors.grenblak
                              : Colors.grey,
                        ),
                      ),

                      /// 🔥 فتح الدروور من تحت
                      IconButton(
                        onPressed: () {
                          scaffoldKey.currentState!.openEndDrawer();
                        },
                        icon: Icon(
                          Icons.menu,
                          color: cubit.currentIndex == 3
                              ? Colors.deepPurple
                              : Colors.grey,
                        ),
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
}