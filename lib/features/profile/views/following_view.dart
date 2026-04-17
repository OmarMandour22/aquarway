import 'package:aquarway/features/profile/views/profile_views.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowingView extends StatelessWidget {
  final String uid;

  const FollowingView({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Following")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('following')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              var followerId = docs[index].id;

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(followerId)
                    .get(),
                builder: (context, userSnap) {

                  if (!userSnap.hasData) {
                    return const SizedBox();
                  }

                  var data = userSnap.data!.data();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (data?['image'] != null &&
                          data!['image'] != "")
                          ? NetworkImage(data['image'])
                          : null,
                      child: (data?['image'] == null ||
                          data!['image'] == "")
                          ? const Icon(Icons.person)
                          : null,
                    ),

                    title: Text(data?['username'] ?? "User"),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileView(
                            userId: followerId,
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