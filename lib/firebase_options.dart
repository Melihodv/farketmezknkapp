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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDagKKoLYNhAz3DB3akgtWSsVdCNSrc6d4',
    appId: '1:768393681101:web:0386c868884c4d0076b184',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    authDomain: 'farketmezknk-257ca.firebaseapp.com',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
  );
  // Web

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6kbeJyzoQ_Ym1SmM9R4dEmLBzZSVbgWs',
    appId: '1:768393681101:android:40b6fcdb41d78ba576b184',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
  );
  // Android — com.farketmezknk.farketmez_knk

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKDB7N3DnBSyKV9FtS_izn-RJzKNgT6ro',
    appId: '1:768393681101:ios:a193e618e0858d7976b184',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
    androidClientId: '768393681101-0m9tufh57bak9iap716d57u8gdcq4vc2.apps.googleusercontent.com',
    iosClientId: '768393681101-gtaqbalbuo3q3r1l9j62l4kh7dlf7tfo.apps.googleusercontent.com',
    iosBundleId: 'com.farketmezknk.farketmezKnk',
  );
  // iOS — com.farketmezknk (Bundle ID)
}
