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

  /// 🔥 availability system
  int? totalRooms;
  int? availableRooms;

  int? totalBeds;
  int? availableBeds;

  /// 🗺️ LOCATION (NEW)
  double? lat;
  double? lng;
  String? address;

  List<String>? images;
  List<String>? videos;

  List<dynamic>? likes;
  List<dynamic>? favorites;

  int? likesCount;
  int? favoritesCount;
  int? commentsCount;

  Timestamp? createdAt;

  /// 🔥 search
  String? searchKey;
  List<String>? searchKeywords;

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
    this.totalRooms,
    this.availableRooms,
    this.totalBeds,
    this.availableBeds,

    /// 🗺️ NEW
    this.lat,
    this.lng,
    this.address,

    this.images,
    this.videos,

    this.likes,
    this.favorites,

    this.likesCount,
    this.favoritesCount,
    this.commentsCount,
    this.createdAt,
    this.searchKey,
    this.searchKeywords,
  });

  /// =========================
  /// FROM JSON
  /// =========================
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

      totalRooms: json['totalRooms'],
      availableRooms: json['availableRooms'],
      totalBeds: json['totalBeds'],
      availableBeds: json['availableBeds'],

      /// 🗺️ SAFE CAST
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      address: json['address'],

      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),

      likes: json['likes'] ?? [],
      favorites: json['favorites'] ?? [],

      likesCount: json['likesCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,

      createdAt: json['createdAt'] ?? Timestamp.now(),

      searchKey: json['searchKey'],
      searchKeywords: List<String>.from(json['searchKeywords'] ?? []),
    );
  }

  /// =========================
  /// TO JSON
  /// =========================
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

      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'totalBeds': totalBeds,
      'availableBeds': availableBeds,

      /// 🗺️ LOCATION
      'lat': lat,
      'lng': lng,
      'address': address,

      'images': images ?? [],
      'videos': videos ?? [],

      'likes': likes ?? [],
      'favorites': favorites ?? [],

      'likesCount': likesCount ?? 0,
      'favoritesCount': favoritesCount ?? 0,
      'commentsCount': commentsCount ?? 0,

      'createdAt': FieldValue.serverTimestamp(),

      'searchKey': searchKey,
      'searchKeywords': searchKeywords ?? [],
    };
  }
}