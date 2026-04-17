import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Property/data/repo/Property_repo.dart';

class CommentsView extends StatelessWidget {
  final String propertyId;

  const CommentsView({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('properties')
                  .doc(propertyId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) return const SizedBox();

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    var data = docs[i];
                    return ListTile(
                      title: Text(data['text']),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  PropertyRepo().addComment(
                    propertyId,
                    controller.text,
                    FirebaseAuth.instance.currentUser!.uid,
                  );
                  controller.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}