import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google ile giriş (Android/iOS)
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Önceki oturumu temizle — hesap seçiciyi her zaman göster
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Firestore kaydını dene; başarısız olsa bile Firebase user var
      final userModel = await _createOrUpdateUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isGuest: false,
      );

      // Firestore başarısız olsa da Firebase girişi tamamlandı
      return userModel ?? UserModel(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isGuest: false,
        createdAt: DateTime.now(),
      );
    } catch (e, stack) {
      AppLogger.error('signInWithGoogle failed', e, stack);
      return null;
    }
  }

  /// Apple ile giriş (iOS/Android)
  Future<UserModel?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user!;

      String? displayName = user.displayName;
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
      }

      final userModel = await _createOrUpdateUser(
        uid: user.uid,
        displayName: displayName ?? 'Kullanıcı',
        email: user.email,
        photoUrl: user.photoURL,
        isGuest: false,
      );

      return userModel ?? UserModel(
        uid: user.uid,
        displayName: displayName ?? 'Kullanıcı',
        email: user.email,
        photoUrl: user.photoURL,
        isGuest: false,
        createdAt: DateTime.now(),
      );
    } catch (e, stack) {
      AppLogger.error('signInWithApple failed', e, stack);
      return null;
    }
  }

  /// Misafir olarak devam et
  Future<UserModel?> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user!;
      
      final userModel = await _createOrUpdateUser(
        uid: user.uid,
        displayName: 'Misafir',
        isGuest: true,
      );

      return userModel ?? UserModel(
        uid: user.uid,
        displayName: 'Misafir',
        isGuest: true,
        createdAt: DateTime.now(),
      );
    } catch (e, stack) {
      AppLogger.error('signInAsGuest failed', e, stack);
      return null;
    }
  }

  Future<UserModel?> _createOrUpdateUser({
    required String uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool isGuest = false,
  }) async {
    try {
      final docRef = _firestore.collection(AppConstants.usersCollection).doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        final userModel = UserModel(
          uid: uid,
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          isGuest: isGuest,
          createdAt: DateTime.now(),
        );
        await docRef.set(userModel.toFirestore());
        return userModel;
      }
      return UserModel.fromFirestore(doc.data()!, uid);
    } catch (e, stack) {
      AppLogger.error('_createOrUpdateUser failed', e, stack);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e, stack) {
      AppLogger.error('signOut failed', e, stack);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Remove from Firestore
        await _firestore.collection(AppConstants.usersCollection).doc(user.uid).delete();
        // Disconnect & Delete from Auth providers
        await _googleSignIn.disconnect().catchError((_) => null);
        await user.delete();
      }
    } catch (e, stack) {
      AppLogger.error('deleteAccount failed', e, stack);
      // Re-authentication might be required, but we try our best.
      throw Exception('Hesap silinirken bir hata oluştu. Lütfen tekrar giriş yapıp deneyin.');
    }
  }

  Future<UserModel?> loadUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (doc.exists) return UserModel.fromFirestore(doc.data()!, doc.id);
    } catch (e, stack) {
      AppLogger.error('loadUser failed', e, stack);
    }
    return null;
  }
}
