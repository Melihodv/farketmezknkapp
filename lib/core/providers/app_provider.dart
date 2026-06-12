import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../services/places_service.dart';
import '../services/memory_service.dart';
import '../services/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/audio_service.dart';
import '../utils/logger.dart';

enum AppState { idle, loading, success, error }

class AppProvider extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();
  final MemoryService _memoryService = MemoryService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  String _currentAddress = 'Konum alınıyor...';
  String get currentAddress => _currentAddress;

  int _selectedGroupIndex = 2; // default: Arkadaşlar
  int get selectedGroupIndex => _selectedGroupIndex;
  Map<String, dynamic> get selectedGroupType => AppConstants.groupTypes[_selectedGroupIndex];
  String get selectedGroupId => selectedGroupType['id'] as String;
  String get selectedGroupLabel => selectedGroupType['label'] as String;

  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  String get selectedCategoryId => AppConstants.categories[_selectedCategoryIndex]['id'];
  String get selectedCategoryLabel => AppConstants.categories[_selectedCategoryIndex]['label'];
  String get selectedCategoryEmoji => AppConstants.categories[_selectedCategoryIndex]['emoji'];

  int _selectedRadiusIndex = 1;
  int get selectedRadiusIndex => _selectedRadiusIndex;
  int get selectedRadius => AppConstants.radiusOptions[_selectedRadiusIndex];
  String get selectedRadiusLabel => AppConstants.radiusLabels[_selectedRadiusIndex];

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  AppState _recommendationState = AppState.idle;
  AppState get recommendationState => _recommendationState;
  PlaceModel? _currentRecommendation;
  PlaceModel? get currentRecommendation => _currentRecommendation;
  Map<String, dynamic>? _distanceInfo;
  Map<String, dynamic>? get distanceInfo => _distanceInfo;
  VisitModel? _currentVisitRecord;
  VisitModel? get currentVisitRecord => _currentVisitRecord;

  List<VisitModel> _recentVisits = [];
  List<VisitModel> get recentVisits => _recentVisits;

  List<VisitModel> _allVisits = [];
  List<VisitModel> get allVisits => _allVisits;
  String? _memoryFilter;
  String? get memoryFilter => _memoryFilter;

  bool _feedbackPending = false;
  bool get feedbackPending => _feedbackPending;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadPreferences();
    await _loadUser();
    await _loadLocation();
    await _loadRecentVisits();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRadiusIndex = prefs.getInt(AppConstants.prefSelectedRadius) ?? 1;
    _selectedGroupIndex = prefs.getInt(AppConstants.prefSelectedGroup) ?? 0;
    _selectedCategoryIndex = prefs.getInt(AppConstants.prefSelectedCategory) ?? 0;
    _isSoundEnabled = prefs.getBool(AppConstants.prefSoundEnabled) ?? true;
    AudioService().setSoundEnabled(_isSoundEnabled);
    notifyListeners();
  }

  Future<void> _loadUser() async {
    try { _currentUser = await _authService.loadUser(); } catch (e, stack) { AppLogger.error('_loadUser failed', e, stack); }
    notifyListeners();
  }

  Future<void> _loadLocation() async {
    final position = await _placesService.getCurrentLocation();
    if (position != null) {
      _currentPosition = position;
      _currentAddress = await _placesService.getAddressFromCoordinates(
        position.latitude, position.longitude,
      );
      notifyListeners();
    }
  }

  Future<void> _loadRecentVisits() async {
    try {
      _recentVisits = await _memoryService.getAllVisits();
      _recentVisits = _recentVisits.take(3).toList();
    } catch (e, stack) {
      AppLogger.error('_loadRecentVisits failed', e, stack);
    }
    notifyListeners();
  }

  void setGroupIndex(int index) {
    if (_selectedGroupIndex != index) {
      _selectedGroupIndex = index;
      AudioService().playPop();
      _savePreferences();
      notifyListeners();
    }
  }

  void setCategoryIndex(int index) {
    if (_selectedCategoryIndex != index) {
      _selectedCategoryIndex = index;
      AudioService().playPop();
      _savePreferences();
      notifyListeners();
    }
  }

  void setRadiusIndex(int index) {
    if (_selectedRadiusIndex != index) {
      _selectedRadiusIndex = index;
      AudioService().playPop();
      _savePreferences();
      notifyListeners();
    }
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    AudioService().setSoundEnabled(_isSoundEnabled);
    _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefSelectedRadius, _selectedRadiusIndex);
    await prefs.setInt(AppConstants.prefSelectedGroup, _selectedGroupIndex);
    await prefs.setInt(AppConstants.prefSelectedCategory, _selectedCategoryIndex);
    await prefs.setBool(AppConstants.prefSoundEnabled, _isSoundEnabled);
  }

  Future<PlaceModel?> getRecommendation() async {
    if (_currentPosition == null) {
      await _loadLocation();
      if (_currentPosition == null) return null;
    }

    _recommendationState = AppState.loading;
    _currentRecommendation = null;
    _distanceInfo = null;
    notifyListeners();

    try {
      List<String> blockedIds = [];
      List<String> visitedIds = [];
      try {
        blockedIds = await _memoryService.getBlockedPlaceIds();
        visitedIds = _recentVisits.map((v) => v.placeId).toList();
      } catch (e, stack) {
        AppLogger.error('Failed to get blocked or visited IDs', e, stack);
      }
      final excludeIds = {...blockedIds, ...visitedIds}.toList();

      final places = await _placesService.getNearbyPlaces(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: selectedRadius,
        categoryId: selectedCategoryId,
        excludePlaceIds: excludeIds,
        groupType: selectedGroupType,
        isVegetarian: _currentUser?.isVegetarian ?? false,
        likesSpicy: _currentUser?.likesSpicy ?? false,
        budgetLevel: _currentUser?.budgetLevel ?? 'fark_etmez',
      );

      final recommendation = _placesService.selectSmartRecommendation(places, []);
      if (recommendation == null) {
        _recommendationState = AppState.error;
        notifyListeners();
        return null;
      }

      _currentRecommendation = recommendation;

      try {
        _currentVisitRecord = await _memoryService.getVisitRecord(recommendation.placeId);
      } catch (e, stack) {
        AppLogger.error('Failed to get visit record', e, stack);
      }

      _distanceInfo = await _placesService.getDistanceAndDuration(
        fromLat: _currentPosition!.latitude,
        fromLng: _currentPosition!.longitude,
        toLat: recommendation.latitude,
        toLng: recommendation.longitude,
      );

      _recommendationState = AppState.success;
      notifyListeners();
      return recommendation;
    } catch (e, stack) {
      AppLogger.error('getRecommendation failed', e, stack);
      _recommendationState = AppState.error;
      notifyListeners();
      return null;
    }
  }

  Future<PlaceModel?> getAnotherRecommendation() async => getRecommendation();

  Future<void> confirmGoingToPlace() async {
    if (_currentRecommendation == null) return;
    try { await _memoryService.recordVisit(_currentRecommendation!); } catch (e, stack) { AppLogger.error('recordVisit failed', e, stack); }
    _feedbackPending = true;
    await _loadRecentVisits();
    notifyListeners();
  }

  Future<void> saveFeedback(int feedback, {String? note}) async {
    if (_currentRecommendation == null) return;
    try {
      await _memoryService.saveFeedback(
        placeId: _currentRecommendation!.placeId,
        feedback: feedback,
        note: note,
      );
    } catch (e, stack) {
      AppLogger.error('saveFeedback failed', e, stack);
    }
    _feedbackPending = false;
    await _loadRecentVisits();
    notifyListeners();
  }

  Future<void> loadAllVisits({String? categoryFilter}) async {
    _memoryFilter = categoryFilter;
    try { _allVisits = await _memoryService.getAllVisits(categoryFilter: categoryFilter); } catch (e, stack) { AppLogger.error('getAllVisits failed', e, stack); }
    notifyListeners();
  }

  Future<void> resetPlaceToPool(String placeId) async {
    try { await _memoryService.resetPlaceToPool(placeId); } catch (e, stack) { AppLogger.error('resetPlaceToPool failed', e, stack); }
    await loadAllVisits(categoryFilter: _memoryFilter);
    notifyListeners();
  }

  Future<void> refreshLocation() async => _loadLocation();

  Future<UserModel?> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e, stack) { AppLogger.error('signInWithGoogle failed', e, stack); return null; }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final user = await _authService.signInWithApple();
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e, stack) { AppLogger.error('signInWithApple failed', e, stack); return null; }
  }

  Future<UserModel?> signInAsGuest() async {
    try {
      final user = await _authService.signInAsGuest();
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e, stack) { AppLogger.error('signInAsGuest failed', e, stack); return null; }
  }

  Future<void> signOut() async {
    try { await _authService.signOut(); } catch (e, stack) { AppLogger.error('signOut failed', e, stack); }
    _currentUser = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    try { await _authService.deleteAccount(); } catch (e, stack) { AppLogger.error('deleteAccount failed', e, stack); }
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updatePreferences(Map<String, dynamic> data) async {
    try {
      await _memoryService.updateUserPreferences(data);
      await _loadUser();
    } catch (e, stack) {
      AppLogger.error('updatePreferences failed', e, stack);
    }
    notifyListeners();
  }
}
