// File generated based on google-services.json and GoogleService-Info.plist
// Firebase project: farketmezknk-257ca

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions, ${defaultTargetPlatform.name} platformunda desteklenmiyor.',
        );
    }
  }

  // Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6kbeJyzoQ_Ym1SmM9R4dEmLBzZSVbgWs',
    appId: '1:768393681101:web:farketmezknk',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
    authDomain: 'farketmezknk-257ca.firebaseapp.com',
  );

  // Android — com.farketmezknk.farketmez_knk
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6kbeJyzoQ_Ym1SmM9R4dEmLBzZSVbgWs',
    appId: '1:768393681101:android:40b6fcdb41d78ba576b184',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
  );

  // iOS — com.farketmezknk (Bundle ID)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKDB7N3DnBSyKV9FtS_izn-RJzKNgT6ro',
    appId: '1:768393681101:ios:a1f60039d953dc4f76b184',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
    iosBundleId: 'com.farketmezknk',
  );
}
