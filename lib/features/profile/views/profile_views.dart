import 'package:aquarway/core/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Property/cubit/Property_cubit.dart';
import '../../Property/data/model/Property_model.dart';
import '../../Property/data/repo/Property_repo.dart';
import '../../Property/views/add_Property_views.dart';
import '../cubit/profile_cubit/profile_cubit.dart';
import '../cubit/profile_cubit/profile_state.dart';
import 'EditProfileView.dart';
import 'followers_view.dart';
import 'following_view.dart';
import '../../../core/widgets/property_card.dart';

class ProfileView extends StatelessWidget {
  final String? uid;

  const ProfileView({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    final currentUid = uid ?? FirebaseAuth.instance.currentUser!.uid;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileCubit()
            ..getUserById(currentUid)
            ..checkIfFollowing(currentUid),
        ),
        BlocProvider(
          create: (_) =>
          PropertyCubit(PropertyRepo())..getMyProperties(currentUid),
        ),
      ],
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = ProfileCubit.get(context);
          var user = cubit.userModel;

          bool isMyProfile =
              FirebaseAuth.instance.currentUser?.uid == currentUid;

          if (user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final propertyCubit = context.read<PropertyCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text("Profile")),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ================= HEADER =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username ?? "No Name",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 15),

                            /// POSTS / FOLLOWERS / FOLLOWING
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final data = snapshot.data?.data()
                                as Map<String, dynamic>?;

                                final posts = data?['postsCount'] ?? 0;

                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text("$posts"),
                                        const Text("Posts"),
                                      ],
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                FollowersView(uid: currentUid),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Text("${user.followersCount ?? 0}"),
                                          const Text("Followers"),
                                        ],
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                FollowingView(uid: currentUid),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Text("${user.followingCount ?? 0}"),
                                          const Text("Following"),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            Text(
                              user.email ?? "",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 10),

                            Text(user.phone ?? "Phone not added"),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.image != null
                            ? NetworkImage(user.image!)
                            : null,
                        child: user.image == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ================= BIO =================
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text("Description"),
                      subtitle: Text(user.bio ?? "No description"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ================= ADDRESS =================
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text("Address"),
                      subtitle: Text(user.address ?? "No address"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= BUTTON =================
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 160,
                      height: 40,
                      child: isMyProfile
                          ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grenblak,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: const EditProfileView(),
                              ),
                            ),
                          );
                        },
                        child: const Text("Edit Profile"),
                      )
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grenblak,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (cubit.isFollowing) {
                            cubit.unfollow(user.id!);
                          } else {
                            cubit.followUser(user.id!);
                          }
                        },
                        child: Text(
                          cubit.isFollowing ? "Unfollow" : "Follow",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ================= ADD PROPERTY =================
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 160,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grenblak,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: propertyCubit,
                                child: AddPropertyView(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Property"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ================= PROPERTIES =================
                  Text(
                    "My Properties",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grenblak,
                    ),
                  ),

                  const SizedBox(height: 10),

                  StreamBuilder<List<PropertyModel>>(
                    stream: propertyCubit.myPropertiesStream(currentUid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final list = snapshot.data!;
                      if (list.isEmpty) {
                        return const Text("No properties yet");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (_, i) =>
                            PropertyCard(model: list[i]),
                      );
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
}