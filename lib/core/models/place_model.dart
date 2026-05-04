class PlaceModel {
  final String placeId;
  final String name;
  final String address;
  final String category;
  final double rating;
  final int userRatingsTotal;
  final double latitude;
  final double longitude;
  final String? photoReference;
  final bool isSponsored;
  final String? sponsoredNote;
  final List<String> types;
  final bool isOpen;
  final String? phoneNumber;
  final String? website;
  final Map<String, dynamic>? openingHours;
  final int priceLevel;

  PlaceModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.category,
    required this.rating,
    required this.userRatingsTotal,
    required this.latitude,
    required this.longitude,
    this.photoReference,
    this.isSponsored = false,
    this.sponsoredNote,
    this.types = const [],
    this.isOpen = true,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.priceLevel = 0,
  });

  factory PlaceModel.fromGoogleMaps(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final photos = json['photos'] as List<dynamic>?;

    return PlaceModel(
      placeId: (json['place_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'İsimsiz Mekan',
      address: (json['vicinity'] as String?) ?? (json['formatted_address'] as String?) ?? '',
      category: _extractCategory(List<String>.from(json['types'] ?? [])),
      rating: ((json['rating'] ?? 0.0) as num).toDouble(),
      userRatingsTotal: (json['user_ratings_total'] as int?) ?? 0,
      latitude: location != null ? ((location['lat'] ?? 0.0) as num).toDouble() : 0.0,
      longitude: location != null ? ((location['lng'] ?? 0.0) as num).toDouble() : 0.0,
      photoReference: photos != null && photos.isNotEmpty
          ? photos[0]['photo_reference'] as String?
          : null,
      types: List<String>.from(json['types'] ?? []),
      isOpen: (json['opening_hours']?['open_now'] as bool?) ?? true,
      priceLevel: (json['price_level'] as int?) ?? 0,
    );
  }

  factory PlaceModel.fromFirestore(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['placeId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      category: json['category'] ?? 'food',
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['userRatingsTotal'] ?? 0,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      photoReference: json['photoReference'],
      isSponsored: json['isSponsored'] ?? false,
      sponsoredNote: json['sponsoredNote'],
      types: List<String>.from(json['types'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'category': category,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'latitude': latitude,
      'longitude': longitude,
      'photoReference': photoReference,
      'isSponsored': isSponsored,
      'sponsoredNote': sponsoredNote,
      'types': types,
    };
  }

  static String _extractCategory(List<String> types) {
    if (types.contains('restaurant') || types.contains('food') || types.contains('meal_takeaway')) return 'food';
    if (types.contains('cafe') || types.contains('bakery')) return 'coffee';
    if (types.contains('bar') || types.contains('night_club') || types.contains('casino')) return 'entertainment';
    if (types.contains('movie_theater') || types.contains('bowling_alley') || types.contains('amusement_park')) return 'entertainment';
    if (types.contains('museum') || types.contains('art_gallery') || types.contains('tourist_attraction') || types.contains('library')) return 'culture';
    if (types.contains('park') || types.contains('natural_feature') || types.contains('campground')) return 'outdoor';
    return 'food';
  }

  String getPhotoUrl(String apiKey, {int maxWidth = 800}) {
    if (photoReference == null) return '';
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }

  PlaceModel copyWith({
    bool? isSponsored,
    String? sponsoredNote,
  }) {
    return PlaceModel(
      placeId: placeId,
      name: name,
      address: address,
      category: category,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      latitude: latitude,
      longitude: longitude,
      photoReference: photoReference,
      isSponsored: isSponsored ?? this.isSponsored,
      sponsoredNote: sponsoredNote ?? this.sponsoredNote,
      types: types,
      isOpen: isOpen,
      phoneNumber: phoneNumber,
      website: website,
      openingHours: openingHours,
      priceLevel: priceLevel,
    );
  }
}
