import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/profile_cubit/profile_cubit.dart';
import '../cubit/profile_cubit/profile_state.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = ProfileCubit.get(context); // استخدم الـ Cubit الحالي

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var user = cubit.userModel;

        var usernameController = TextEditingController(text: user?.username);
        var phoneController = TextEditingController(text: user?.phone);
        var bioController = TextEditingController(text: user?.bio);
        var addressController = TextEditingController(text: user?.address);

        return Scaffold(
          appBar: AppBar(title: const Text("Edit Profile")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                GestureDetector(
                  onTap: () async {
                    final picked =
                    await ImagePicker().pickImage(source: ImageSource.gallery);

                    if (picked != null) {
                      cubit.updateProfileImage(File(picked.path));
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: cubit.userModel?.image != null
                        ? NetworkImage(cubit.userModel!.image!)
                        : null,
                    child: cubit.userModel?.image == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),

                const SizedBox(height: 20),


                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    cubit.updateProfile(
                      username: usernameController.text,
                      phone: phoneController.text,
                      bio: bioController.text,
                      address: addressController.text,
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}