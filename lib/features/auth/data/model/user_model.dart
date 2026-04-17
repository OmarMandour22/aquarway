class UserModel {
  String? id;
  String? username;
  String? email;
  String? image;   // profile image url
  String? address; // العنوان الحالي
  String? phone;   // رقم الهاتف
  String? bio;     // وصف عن المستخدم

  int? followersCount;
  int? followingCount;
  int? postsCount;

  /// 🔥 NEW: search keywords
  List<String>? searchKeywords;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.image,
    this.address,
    this.phone,
    this.bio,
    this.followersCount,
    this.followingCount,
    this.postsCount,
    this.searchKeywords,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    username = json['username'] as String?;
    email = json['email'] as String?;
    image = json['image'] as String?;
    address = json['address'] as String?;
    phone = json['phone'] as String?;
    bio = json['bio'] as String?;

    followersCount = json['followersCount'] ?? 0;
    followingCount = json['followingCount'] ?? 0;
    postsCount = json['postsCount'] ?? 0;

    /// 🔥 NEW
    searchKeywords = List<String>.from(json['searchKeywords'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'image': image,
      'address': address,
      'phone': phone,
      'bio': bio,
      'followersCount': followersCount ?? 0,
      'followingCount': followingCount ?? 0,
      'postsCount': postsCount ?? 0,

      /// 🔥 NEW
      'searchKeywords': searchKeywords ?? [],
    };
  }
}