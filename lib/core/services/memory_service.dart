import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Kullanıcının bir mekanla ilgili visit kaydını getirir
  Future<VisitModel?> getVisitRecord(String placeId) async {
    if (_userId == null) return null;
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.visitsCollection)
          .doc(placeId)
          .get();

      if (doc.exists) {
        return VisitModel.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      // Silent
    }
    return null;
  }

  /// Mekan ziyaretini kaydeder veya günceller
  Future<void> recordVisit(PlaceModel place) async {
    if (_userId == null) return;
    try {
      final docRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.visitsCollection)
          .doc(place.placeId);

      final existing = await docRef.get();

      if (existing.exists) {
        await docRef.update({
          'visitCount': FieldValue.increment(1),
          'visitedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        final visit = VisitModel(
          id: place.placeId,
          userId: _userId!,
          placeId: place.placeId,
          placeName: place.name,
          placeCategory: place.category,
          visitedAt: DateTime.now(),
          latitude: place.latitude,
          longitude: place.longitude,
        );
        await docRef.set(visit.toFirestore());

        // User totalDiscoveries artır
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_userId)
            .set({'totalDiscoveries': FieldValue.increment(1)}, SetOptions(merge: true));
      }
    } catch (e) {
      // Silent
    }
  }

  /// Geri bildirim kaydet
  Future<void> saveFeedback({
    required String placeId,
    required int feedback, // 1 = 👍, -1 = 👎
    String? note,
  }) async {
    if (_userId == null) return;
    try {
      final docRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.visitsCollection)
          .doc(placeId);

      if (feedback == 1) {
        await docRef.update({
          'feedback': 1,
          'note': note,
          'positiveCount': FieldValue.increment(1),
        });
      } else {
        await docRef.update({
          'feedback': -1,
          'note': note,
          'negativeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      // Silent
    }
  }

  /// Bloklu mekan ID'lerini getirir (3+ 👎)
  Future<List<String>> getBlockedPlaceIds() async {
    if (_userId == null) return [];
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.visitsCollection)
          .where('negativeCount', isGreaterThanOrEqualTo: AppConstants.maxNegativeVotes)
          .get();

      return snapshot.docs.map((d) => d.id).toList();
    } catch (e) {
      return [];
    }
  }

  /// Tüm ziyaret geçmişini getirir
  Future<List<VisitModel>> getAllVisits({String? categoryFilter}) async {
    if (_userId == null) return [];
    try {
      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.visitsCollection)
          .orderBy('visitedAt', descending: true);

      if (categoryFilter != null) {
        query = query.where('placeCategory', isEqualTo: categoryFilter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((d) => VisitModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Mekanı tekrar öneri havuzuna ekler
  Future<void> resetPlaceToPool(String placeId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.visitsCollection)
          .doc(placeId)
          .update({
        'negativeCount': 0,
        'feedback': null,
      });
    } catch (e) {
      // Silent
    }
  }

  /// Kullanıcı verilerini Firestore'dan yükle
  Future<UserModel?> loadUserData() async {
    if (_userId == null) return null;
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      // Silent
    }
    return null;
  }

  /// Kullanıcı verilerini güncelle
  Future<void> updateUserPreferences(Map<String, dynamic> data) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .update(data);
    } catch (e) {
      // Silent
    }
  }
}
