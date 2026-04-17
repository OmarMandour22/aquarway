import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/model/user_model.dart';
import '../../../auth/data/repo/auth_repo.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserModel? userModel;
  bool isFollowing = false;

  /// 🔥 نتائج البحث عن المستخدمين
  List<UserModel> searchResults = [];

  static ProfileCubit get(context) => BlocProvider.of(context);

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

  /// 🔄 Refresh
  Future<void> refreshProfile() async {
    if (userModel != null) {
      await getUserData();
    }
  }

  /// ✏️ Update Profile
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

  /// 🖼️ Update Image
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

  /// ❤️ Follow
  Future<void> followUser(String uid) async {
    await AuthRepo().followUser(uid);
    isFollowing = true;
    getUserData();
  }

  /// 💔 Unfollow
  Future<void> unfollow(String uid) async {
    await AuthRepo().unfollowUser(uid);
    isFollowing = false;
    emit(ProfileLoaded());
  }

  /// 👀 Check Follow
  Future<void> checkIfFollowing(String uid) async {
    bool result = await AuthRepo().checkIfFollowing(uid);
    isFollowing = result;
    emit(ProfileLoaded());
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await AuthRepo().logout();
  }

  // ===========================
  // 🔥🔥🔥 NEW: SEARCH USERS
  // ===========================

  Future<void> searchByUsername(String text) async {
    if (text.isEmpty) {
      searchResults = [];
      emit(ProfileLoaded());
      return;
    }

    emit(ProfileLoading());

    try {
      final repo = AuthRepo();

      final result = await repo.searchUsers(text);

      searchResults = result;

      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}