import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';

import '../model/Property_model.dart';

class PropertyRepo {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// =========================
  /// ADD OR UPDATE PROPERTY
  /// =========================
  Future<Either<String, PropertyModel>> addOrUpdateProperty({
    required PropertyModel model,
    List<File>? images,
    List<File>? videos,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Left("No user logged in");

      String id =
          model.id ?? _firestore.collection('properties').doc().id;

      /// =====================
      /// IMAGES UPLOAD
      /// =====================
      List<String> imageUrls = model.images ?? [];

      if (images != null && images.isNotEmpty) {
        final uploadTasks = images.map((img) async {
          final ref = _storage.ref().child(
            "properties/$id/images/${DateTime.now().millisecondsSinceEpoch}.jpg",
          );
          await ref.putFile(img);
          return await ref.getDownloadURL();
        }).toList();

        imageUrls.addAll(await Future.wait(uploadTasks));
      }

      /// =====================
      /// VIDEOS UPLOAD
      /// =====================
      List<String> videoUrls = model.videos ?? [];

      if (videos != null && videos.isNotEmpty) {
        final uploadTasks = videos.map((vid) async {
          final ref = _storage.ref().child(
            "properties/$id/videos/${DateTime.now().millisecondsSinceEpoch}.mp4",
          );
          await ref.putFile(vid);
          return await ref.getDownloadURL();
        }).toList();

        videoUrls.addAll(await Future.wait(uploadTasks));
      }

      /// =====================
      /// BUILD MODEL
      /// =====================
      model.id = id;
      model.ownerId ??= user.uid;
      model.images = imageUrls;
      model.videos = videoUrls;

      /// 🔥 SEARCH (safe + lowercase)
      List<String> keywords = [];

      String fullText =
      "${model.title ?? ''} ${model.location ?? ''} ${model.type ?? ''}"
          .toLowerCase()
          .trim();

      List<String> words = fullText.split(" ");

      for (var word in words) {
        for (int i = 1; i <= word.length; i++) {
          keywords.add(word.substring(0, i));
        }
      }

      model.searchKeywords = keywords;

      /// =====================
      /// SAVE FIRESTORE
      /// =====================
      await _firestore.collection('properties').doc(id).set(
        model.toJson(),
      );

      return Right(model);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// =========================
  /// DELETE PROPERTY
  /// =========================
  Future<Either<String, bool>> deleteProperty(
      String id,
      List<String>? images,
      List<String>? videos,
      ) async {
    try {
      if (images != null) {
        for (var url in images) {
          try {
            await _storage.refFromURL(url).delete();
          } catch (_) {}
        }
      }

      if (videos != null) {
        for (var url in videos) {
          try {
            await _storage.refFromURL(url).delete();
          } catch (_) {}
        }
      }

      await _firestore.collection('properties').doc(id).delete();

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// =========================
  /// LIKE
  /// =========================
  Future<void> likeProperty(String id, String uid) async {
    await _firestore.collection('properties').doc(id).update({
      'likes': FieldValue.arrayUnion([uid]),
      'likesCount': FieldValue.increment(1),
    });
  }

  /// =========================
  /// UNLIKE
  /// =========================
  Future<void> unlikeProperty(String id, String uid) async {
    await _firestore.collection('properties').doc(id).update({
      'likes': FieldValue.arrayRemove([uid]),
      'likesCount': FieldValue.increment(-1),
    });
  }

  /// =========================
  /// COMMENTS
  /// =========================
  Future<void> addComment(
      String propertyId,
      String text,
      String uid,
      ) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    await _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('comments')
        .add({
      'text': text,
      'userId': uid,
      'username': userDoc.data()?['username'] ?? '',
      'userImage': userDoc.data()?['image'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('properties')
        .doc(propertyId)
        .update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  /// =========================
  /// ALL PROPERTIES
  /// =========================
  Stream<List<PropertyModel>> getProperties() {
    return _firestore
        .collection('properties')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        data['createdAt'] = data['createdAt'] ?? Timestamp.now();

        return PropertyModel.fromJson(data);
      }).toList();
    });
  }

  /// =========================
  /// MY PROPERTIES
  /// =========================
  Stream<List<PropertyModel>> getMyProperties(String uid) {
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        data['createdAt'] = data['createdAt'] ?? Timestamp.now();

        return PropertyModel.fromJson(data);
      }).toList();
    });
  }

  /// =========================
  /// SEARCH
  /// =========================
  Stream<List<PropertyModel>> searchProperties(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      return getProperties();
    }

    return _firestore
        .collection('properties')
        .where('searchKeywords', arrayContains: q)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        data['createdAt'] = data['createdAt'] ?? Timestamp.now();

        return PropertyModel.fromJson(data);
      }).toList();
    });
  }


  /// =========================
  /// UPDATE ROOMS / BEDS
  /// =========================
  Future<void> updateRoomsBeds({
    required String propertyId,
    int? rooms,
    int? beds,
  }) async {
    await _firestore.collection('properties').doc(propertyId).update({
      'rooms': rooms,
      'beds': beds,
    });
  }

  /// =========================
  /// FAVORITE TOGGLE
  /// =========================
  Future<void> toggleFavorite(
      String id,
      String uid,
      bool isFav,
      ) async {
    await _firestore.collection('properties').doc(id).update({
      'favorites': isFav
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
      'favoritesCount': FieldValue.increment(isFav ? -1 : 1),
    });
  }
}