class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isGuest;
  final bool isVegetarian;
  final bool likesSpicy;
  final String budgetLevel; // 'ekonomik', 'orta', 'fark_etmez'
  final List<String> visitedPlaceIds;
  final int totalDiscoveries;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isGuest = false,
    this.isVegetarian = false,
    this.likesSpicy = false,
    this.budgetLevel = 'fark_etmez',
    this.visitedPlaceIds = const [],
    this.totalDiscoveries = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      displayName: json['displayName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      isGuest: json['isGuest'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      likesSpicy: json['likesSpicy'] ?? false,
      budgetLevel: json['budgetLevel'] ?? 'fark_etmez',
      visitedPlaceIds: List<String>.from(json['visitedPlaceIds'] ?? []),
      totalDiscoveries: json['totalDiscoveries'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'isVegetarian': isVegetarian,
      'likesSpicy': likesSpicy,
      'budgetLevel': budgetLevel,
      'visitedPlaceIds': visitedPlaceIds,
      'totalDiscoveries': totalDiscoveries,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    bool? isVegetarian,
    bool? likesSpicy,
    String? budgetLevel,
    List<String>? visitedPlaceIds,
    int? totalDiscoveries,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      likesSpicy: likesSpicy ?? this.likesSpicy,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      visitedPlaceIds: visitedPlaceIds ?? this.visitedPlaceIds,
      totalDiscoveries: totalDiscoveries ?? this.totalDiscoveries,
      createdAt: createdAt,
    );
  }
}

class VisitModel {
  final String id;
  final String userId;
  final String placeId;
  final String placeName;
  final String placeCategory;
  final DateTime visitedAt;
  final int? feedback; // 1: like, -1: dislike
  final String? note;
  final int visitCount;
  final int positiveCount;
  final int negativeCount;
  final double? latitude;
  final double? longitude;

  VisitModel({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeName,
    required this.placeCategory,
    required this.visitedAt,
    this.feedback,
    this.note,
    this.visitCount = 1,
    this.positiveCount = 0,
    this.negativeCount = 0,
    this.latitude,
    this.longitude,
  });

  factory VisitModel.fromFirestore(Map<String, dynamic> json, String id) {
    return VisitModel(
      id: id,
      userId: json['userId'] ?? '',
      placeId: json['placeId'] ?? '',
      placeName: json['placeName'] ?? '',
      placeCategory: json['placeCategory'] ?? 'food',
      visitedAt: json['visitedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['visitedAt'])
          : DateTime.now(),
      feedback: json['feedback'],
      note: json['note'],
      visitCount: json['visitCount'] ?? 1,
      positiveCount: json['positiveCount'] ?? 0,
      negativeCount: json['negativeCount'] ?? 0,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'placeId': placeId,
      'placeName': placeName,
      'placeCategory': placeCategory,
      'visitedAt': visitedAt.millisecondsSinceEpoch,
      'feedback': feedback,
      'note': note,
      'visitCount': visitCount,
      'positiveCount': positiveCount,
      'negativeCount': negativeCount,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get isBlocked => negativeCount >= 3;

  VisitModel copyWith({
    int? feedback,
    String? note,
    int? visitCount,
    int? positiveCount,
    int? negativeCount,
  }) {
    return VisitModel(
      id: id,
      userId: userId,
      placeId: placeId,
      placeName: placeName,
      placeCategory: placeCategory,
      visitedAt: visitedAt,
      feedback: feedback ?? this.feedback,
      note: note ?? this.note,
      visitCount: visitCount ?? this.visitCount,
      positiveCount: positiveCount ?? this.positiveCount,
      negativeCount: negativeCount ?? this.negativeCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
