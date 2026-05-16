import 'package:aquarway/features/profile/views/profile_views.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingView extends StatelessWidget {
  final String uid;

  const FollowingView({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Following")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('following')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Not following anyone"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final followingId = docs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(followingId)
                    .get(),

                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final data =
                  userSnap.data!.data() as Map<String, dynamic>?;

                  if (data == null) return const SizedBox();

                  final image = data['image'] ?? "";
                  final username = data['username'] ?? "User";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      image.isNotEmpty ? NetworkImage(image) : null,
                      child: image.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),

                    title: Text(username),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileView(
                            uid: followingId, // ✔ FIXED
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}