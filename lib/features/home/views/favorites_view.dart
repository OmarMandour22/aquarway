import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Property/cubit/Property_cubit.dart';
import '../../Property/data/model/Property_model.dart';
import '../../Property/data/repo/Property_repo.dart';
import '../../../core/widgets/property_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (_) => PropertyCubit(PropertyRepo()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Favorites"),
        ),
        body: StreamBuilder<List<PropertyModel>>(
          stream: PropertyRepo().getProperties(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final list = snapshot.data!
                .where(
                  (e) =>
              e.favorites != null &&
                  e.favorites!.contains(uid),
            )
                .toList();

            if (list.isEmpty) {
              return const Center(
                child: Text("No favorites yet"),
              );
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                return PropertyCard(
                  model: list[i],
                );
              },
            );
          },
        ),
      ),
    );
  }
}