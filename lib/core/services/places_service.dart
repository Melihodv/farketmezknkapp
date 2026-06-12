import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import '../models/place_model.dart';
import '../utils/logger.dart';

class PlacesService {
  // Google Maps yerine kendi Cloud Functions backend'imizi çağırıyoruz
  static const String _baseUrl = 'https://us-central1-farketmezknk-257ca.cloudfunctions.net';
  
  // API Key artık uygulamanın içinde güvenlik riski yaratmıyor, 
  // backend'de saklanıyor. Fakat parametre uyumluluğu için hala tutabiliriz.
  final String apiKey;

  PlacesService({String? key}) : apiKey = key ?? AppConstants.googleMapsApiKey;

  Uri _buildUrl(String path, Map<String, String> params) {
    // Cloud function'a parametreleri aynen geçiriyoruz
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return Uri.parse('$_baseUrl$path?$query');
  }

  dynamic _parseResponse(http.Response response) {
    return jsonDecode(response.body);
  }

  /// Konuma yakın mekanları getirir
  Future<List<PlaceModel>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required int radius,
    required String categoryId,
    List<String> excludePlaceIds = const [],
    Map<String, dynamic>? groupType,
    bool isVegetarian = false,
    bool likesSpicy = false,
    String budgetLevel = 'fark_etmez',
  }) async {
    final category = AppConstants.categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => AppConstants.categories.first,
    );

    final types = category['types'] as List<String>;
    List<PlaceModel> allPlaces = [];

    // groupType'tan keyword ve minRating çek
    String finalKeyword = groupType?['keyword'] as String? ?? '';
    if (isVegetarian) finalKeyword += ' vegetarian';
    if (likesSpicy) finalKeyword += ' spicy';
    finalKeyword = finalKeyword.trim();

    final minRating = (groupType?['minRating'] as double?) ?? 3.5;

    await Future.wait(types.map((type) async {
      try {
        final params = <String, String>{
          'location': '$latitude,$longitude',
          'radius': '$radius',
          'type': type,
          'language': 'tr',
        };
        
        if (finalKeyword.isNotEmpty) params['keyword'] = finalKeyword;
        if (budgetLevel == 'ekonomik') params['maxprice'] = '1';
        else if (budgetLevel == 'orta') params['maxprice'] = '2';

        final url = _buildUrl('/getNearbyPlaces', params);
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = _parseResponse(response);
          if (data['status'] == 'OK') {
            final results = data['results'] as List<dynamic>;
            final places = results
                .map((r) => PlaceModel.fromGoogleMaps(r))
                .where((p) => !excludePlaceIds.contains(p.placeId))
                .where((p) => p.rating >= minRating) // grup tipine göre rating filtresi
                .toList();
            allPlaces.addAll(places);
          }
        }
      } catch (e, stack) {
        AppLogger.error('getNearbyPlaces failed for type: $type', e, stack);
      }
    }));

    // Grup tipine göre type bazlı filtre (excludeTypes)
    final excludeTypes = (groupType?['excludeTypes'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    if (excludeTypes.isNotEmpty) {
      allPlaces = allPlaces.where((p) =>
        !p.types.any((t) => excludeTypes.contains(t))
      ).toList();
    }

    // ── Strict radius filter (Haversine + yol düzeltme katsayısı) ──
    // Haversine düz hat mesafesi verir; şehir içi yol mesafesi ~1.45x daha uzun.
    // 0.68 katsayısıyla filtreleriz → Maps'te gösterilen mesafe seçilen değere yakın çıkar.
    const roadCorrectionFactor = 0.85;
    allPlaces = allPlaces.where((p) {
      final dist = _haversineMeters(
        latitude, longitude, p.latitude, p.longitude,
      );
      return dist <= radius * roadCorrectionFactor;
    }).toList();

    // Duplicate'leri temizle
    final seen = <String>{};
    allPlaces = allPlaces.where((p) => seen.add(p.placeId)).toList();

    return allPlaces;
  }

  /// Haversine mesafesi (metre)
  double _haversineMeters(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const r = 6371000.0; // Earth radius in metres
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180;

  /// Puanlı öneri seçimi (sponsored önce)
  PlaceModel? selectSmartRecommendation(
    List<PlaceModel> places,
    List<PlaceModel> sponsoredPlaces,
  ) {
    if (places.isEmpty) return null;

    // %20 ihtimalle sponsored göster
    if (sponsoredPlaces.isNotEmpty && math.Random().nextDouble() < 0.20) {
      sponsoredPlaces.shuffle();
      return sponsoredPlaces.first;
    }

    // Rating'e göre ağırlıklı rastgele seçim
    final sorted = [...places]..sort((a, b) => b.rating.compareTo(a.rating));
    final topPlaces = sorted.take(math.min(10, sorted.length)).toList();
    topPlaces.shuffle();
    return topPlaces.first;
  }

  /// Mekan detayını getirir
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = _buildUrl('/getPlaceDetails', {
        'place_id': placeId,
        'fields': 'name,formatted_address,formatted_phone_number,website,opening_hours,photos,rating,user_ratings_total,price_level',
        'language': 'tr',
      });
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = _parseResponse(response);
        if (data['status'] == 'OK') return data['result'];
      }
    } catch (e, stack) {
      AppLogger.error('getPlaceDetails failed for placeId: $placeId', e, stack);
    }
    return null;
  }

  /// Mesafe ve süre hesaplar
  Future<Map<String, String>?> getDistanceAndDuration({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final url = _buildUrl('/getDistanceMatrix', {
        'origins': '$fromLat,$fromLng',
        'destinations': '$toLat,$toLng',
        'mode': 'walking',
        'language': 'tr',
      });
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = _parseResponse(response) as Map<String, dynamic>?;
        if (data == null) return null;
        if (data['status'] != 'OK') return null;
        final rows = data['rows'] as List<dynamic>?;
        if (rows == null || rows.isEmpty) return null;
        final elements = rows[0]['elements'] as List<dynamic>?;
        if (elements == null || elements.isEmpty) return null;
        final element = elements[0] as Map<String, dynamic>?;
        if (element == null || element['status'] != 'OK') return null;
        final distMap = element['distance'] as Map<String, dynamic>?;
        final durMap = element['duration'] as Map<String, dynamic>?;
        return {
          'distance': (distMap?['text'] as String?) ?? '',
          'duration': (durMap?['text'] as String?) ?? '',
        };
      }
    } catch (e, stack) {
      AppLogger.error('getDistanceAndDuration failed', e, stack);
    }
    return null;
  }

  /// Kullanıcı konumunu al
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e, stack) {
      AppLogger.error('getCurrentLocation failed', e, stack);
      return null;
    }
  }

  /// Koordinattan adres al
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = _buildUrl('/getGeocode', {'latlng': '$lat,$lng', 'language': 'tr'});
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = _parseResponse(response);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final components = data['results'][0]['address_components'] as List;
          String neighborhood = '', district = '', city = '';
          for (final c in components) {
            final types = c['types'] as List;
            if (types.contains('neighborhood') || types.contains('sublocality_level_1')) neighborhood = c['long_name'];
            else if (types.contains('administrative_area_level_2')) district = c['long_name'];
            else if (types.contains('administrative_area_level_1')) city = c['long_name'];
          }
          if (neighborhood.isNotEmpty) return '$neighborhood, $city';
          if (district.isNotEmpty) return '$district, $city';
          return city;
        }
      }
    } catch (e, stack) {
      AppLogger.error('getAddressFromCoordinates failed', e, stack);
    }
    return 'Konum bilinmiyor';
  }

  /// Fotoğraf URL'si
  String getPhotoUrl(String photoReference, {int maxWidth = 800}) {
    return '$_baseUrl/getPhoto?maxwidth=$maxWidth&photo_reference=$photoReference';
  }
}
