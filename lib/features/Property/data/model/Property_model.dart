import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  String? id;
  String? ownerId;

  String? title;
  String? description;
  String? location;
  String? price;

  String? type;
  String? status;

  int? rooms;
  int? beds;

  List<String>? images;
  List<String>? videos;

  List<dynamic>? likes;
  int? likesCount;
  int? favoritesCount;
  int? commentsCount;

  Timestamp? createdAt;

  /// 🔥 search
  String? searchKey;
  List<String>? searchKeywords; // ✅ الجديد

  PropertyModel({
    this.id,
    this.ownerId,
    this.title,
    this.description,
    this.location,
    this.price,
    this.type,
    this.status,
    this.rooms,
    this.beds,
    this.images,
    this.videos,
    this.likes,
    this.likesCount,
    this.favoritesCount,
    this.commentsCount,
    this.createdAt,
    this.searchKey,
    this.searchKeywords, // ✅ الجديد
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      ownerId: json['ownerId'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: json['price'],
      type: json['type'],
      status: json['status'],
      rooms: json['rooms'],
      beds: json['beds'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      likes: json['likes'] ?? [],
      likesCount: json['likesCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: json['createdAt'] ?? Timestamp.now(),

      /// 🔥 search
      searchKey: json['searchKey'],
      searchKeywords: List<String>.from(json['searchKeywords'] ?? []), // ✅
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'type': type,
      'status': status,
      'rooms': rooms,
      'beds': beds,
      'images': images ?? [],
      'videos': videos ?? [],
      'likes': likes ?? [],
      'likesCount': likesCount ?? 0,
      'favoritesCount': favoritesCount ?? 0,
      'commentsCount': commentsCount ?? 0,
      'createdAt': FieldValue.serverTimestamp(),

      /// 🔥 search
      'searchKey': searchKey,
      'searchKeywords': searchKeywords ?? [], // ✅ مهم جداً
    };
  }
}