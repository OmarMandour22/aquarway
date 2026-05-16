import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/model/user_model.dart';
import '../../../auth/data/repo/auth_repo.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserModel? userModel;
  bool isFollowing = false;

  List<UserModel> searchResults = [];

  static ProfileCubit get(context) => BlocProvider.of(context);

  /// ================= CURRENT USER (زي ما هو) =================
  Future<void> getUserData() async {
    emit(ProfileLoading());
    AuthRepo repo = AuthRepo();

    var response = await repo.getCurrentUserData();

    response.fold(
          (error) => emit(ProfileError(error)),
          (user) {
        userModel = user;
        emit(ProfileLoaded());
      },
    );
  }

  /// ================= 🔥 USER BY ID (اللي كان ناقص عندك) =================
  Future<void> getUserById(String uid) async {
    emit(ProfileLoading());

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        emit(ProfileError("User not found"));
        return;
      }

      userModel = UserModel.fromJson(doc.data()!);
      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// ================= REFRESH =================
  Future<void> refreshProfile() async {
    if (userModel != null) {
      await getUserData();
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    String? username,
    String? phone,
    String? bio,
    String? address,
  }) async {
    emit(ProfileLoading());

    AuthRepo repo = AuthRepo();

    var response = await repo.updateUserProfile(
      username: username,
      phone: phone,
      bio: bio,
      address: address,
    );

    response.fold(
          (error) => emit(ProfileError(error)),
          (user) {
        userModel = user;
        emit(ProfileLoaded());
      },
    );
  }

  /// ================= IMAGE =================
  Future<void> updateProfileImage(File image) async {
    emit(ProfileLoading());

    var response = await AuthRepo().updateProfileImage(image);

    response.fold(
          (error) => emit(ProfileError(error)),
          (imageUrl) {
        if (userModel != null) {
          userModel!.image = imageUrl;
        }
        emit(ProfileLoaded());
      },
    );
  }

  /// ================= FOLLOW =================
  Future<void> followUser(String uid) async {
    await AuthRepo().followUser(uid);
    isFollowing = true;
    emit(ProfileLoaded());
  }

  Future<void> unfollow(String uid) async {
    await AuthRepo().unfollowUser(uid);
    isFollowing = false;
    emit(ProfileLoaded());
  }

  Future<void> checkIfFollowing(String uid) async {
    bool result = await AuthRepo().checkIfFollowing(uid);
    isFollowing = result;
    emit(ProfileLoaded());
  }

  /// ================= SEARCH =================
  Future<void> searchByUsername(String text) async {
    if (text.isEmpty) {
      searchResults = [];
      emit(ProfileLoaded());
      return;
    }

    emit(ProfileLoading());

    try {
      final result = await AuthRepo().searchUsers(text);
      searchResults = result;

      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await AuthRepo().logout();
  }
}