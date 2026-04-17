import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/user_model.dart';

class AuthRepo {
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) return Left('User data not found in Firestore');

      final userData = doc.data()!;
      final user = UserModel(
        id: credential.user!.uid,
        email: userData['email'] ?? '',
        username: userData['username'] ?? '',
        image: userData['image'] ?? '',
      );

      return Right(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Left('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return Left('Wrong password provided for that user.');
      } else {
        return Left('Login failed: ${e.code}');
      }
    } catch (e) {
      return Left('Login failed: ${e.toString()}');
    }
  }

  /// REGISTER
  Future<Either<String, UserModel>> register({
    String? username,
    required String email,
    required String password,
    File? image,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? imageUrl;

      if (image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${credential.user!.uid}/profile.jpg');
        await storageRef.putFile(image);
        imageUrl = await storageRef.getDownloadURL();
      }

      final user = UserModel(
        id: credential.user!.uid,
        username: username,
        email: email,
        image: imageUrl,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toJson());

      return Right(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Left('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return Left('The account already exists for that email.');
      } else {
        return Left('Registration failed: ${e.code}');
      }
    } catch (e) {
      return Left('Registration failed: ${e.toString()}');
    }
  }

  Future<Either<String, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return Left("No user logged in");

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      return const Right(true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return Left('Current password is wrong');
      } else if (e.code == 'weak-password') {
        return Left('New password is weak');
      } else {
        return Left(e.message ?? 'Error');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> getCurrentUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return Left("User data not found");
      }

      return Right(UserModel.fromJson(doc.data()!));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<String?> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "No user logged in";

      await FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/profile.jpg')
          .delete()
          .catchError((_) {});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Either<String, UserModel>> updateUserProfile({
    String? username,
    String? phone,
    String? bio,
    String? address,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Left("No user logged in");

      Map<String, dynamic> data = {};

      if (username != null) data['username'] = username;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (address != null) data['address'] = address;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(data);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return Right(UserModel.fromJson(doc.data()!));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> updateProfileImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return Left("No user logged in");
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/profile.jpg');

      await storageRef.putFile(image);

      String imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'image': imageUrl,
      });

      return Right(imageUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> followUser(String uid) async {
    String myId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(myId)
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .collection('following')
        .doc(uid)
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'followersCount': FieldValue.increment(1),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({
      'followingCount': FieldValue.increment(1),
    });
  }

  Future<void> unfollowUser(String uid) async {
    String myId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(myId)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .collection('following')
        .doc(uid)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'followersCount': FieldValue.increment(-1),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({
      'followingCount': FieldValue.increment(-1),
    });
  }

  Future<bool> checkIfFollowing(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .get();

    return doc.exists;
  }

  Future<List<UserModel>> searchUsersCombined(String query) async {
    final keywordResults = await searchUsers(query);

    if (keywordResults.isNotEmpty) return keywordResults;

    return await searchUsersSmart(query);
  }

  /// =========================
  /// 🔥 SMART SEARCH FIX (NEW)
  /// =========================
  Future<List<UserModel>> searchUsersSmart(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final q = query.toLowerCase().trim();

      // fallback search by username prefix
      final result = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('username')
          .startAt([q])
          .endAt([q + '\uf8ff'])
          .limit(20)
          .get();

      return result.docs
          .map((e) => UserModel.fromJson(e.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final String searchKey = query.toLowerCase().trim();

      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('searchKeywords', arrayContains: searchKey)
          .limit(20)
          .get();

      return result.docs
          .map((e) => UserModel.fromJson(e.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}