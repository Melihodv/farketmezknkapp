import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import '../models/place_model.dart';

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  final String apiKey;

  PlacesService({String? key}) : apiKey = key ?? AppConstants.googleMapsApiKey;

  Uri _buildUrl(String path, Map<String, String> params) {
    params['key'] = apiKey;
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
  }) async {
    final category = AppConstants.categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => AppConstants.categories.first,
    );

    final types = category['types'] as List<String>;
    List<PlaceModel> allPlaces = [];

    // groupType'tan keyword ve minRating çek
    final keyword = groupType?['keyword'] as String?;
    final minRating = (groupType?['minRating'] as double?) ?? 3.5;

    for (final type in [types.first]) {
      try {
        final params = <String, String>{
          'location': '$latitude,$longitude',
          'radius': '$radius',
          'type': type,
          'language': 'tr',
        };
        // keyword varsa ekle (romantic cozy, family friendly vs)
        if (keyword != null) params['keyword'] = keyword;

        final url = _buildUrl('/place/nearbysearch/json', params);
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
      } catch (e) {
        // Silent
      }
    }

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
    const roadCorrectionFactor = 0.68;
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
      final url = _buildUrl('/place/details/json', {
        'place_id': placeId,
        'fields': 'name,formatted_address,formatted_phone_number,website,opening_hours,photos,rating,user_ratings_total,price_level',
        'language': 'tr',
      });
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = _parseResponse(response);
        if (data['status'] == 'OK') return data['result'];
      }
    } catch (e) {}
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
      final url = _buildUrl('/distancematrix/json', {
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
    } catch (_) {}
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
    } catch (e) {
      return null;
    }
  }

  /// Koordinattan adres al
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = _buildUrl('/geocode/json', {'latlng': '$lat,$lng', 'language': 'tr'});
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
    } catch (e) {}
    return 'Konum bilinmiyor';
  }

  /// Fotoğraf URL'si
  String getPhotoUrl(String photoReference, {int maxWidth = 800}) {
    return '$_baseUrl/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }
}
