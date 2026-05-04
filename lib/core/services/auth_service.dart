import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google ile giriş (Android/iOS)
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      return await _createOrUpdateUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isGuest: false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Misafir olarak devam et
  Future<UserModel?> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user!;
      return await _createOrUpdateUser(
        uid: user.uid,
        displayName: 'Misafir',
        isGuest: true,
      );
    } catch (e) {
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
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}
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
    } catch (_) {}
    return null;
  }
}
