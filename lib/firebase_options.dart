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
    apiKey: 'AIzaSyCg8Os-rjupxOkCXAeHwHoYZHhdraAJNQQ',
    appId: '1:768393681101:ios:7ebd235e90ab2dfe76b184',
    messagingSenderId: '768393681101',
    projectId: 'farketmezknk-257ca',
    storageBucket: 'farketmezknk-257ca.firebasestorage.app',
    androidClientId: '768393681101-0m9tufh57bak9iap716d57u8gdcq4vc2.apps.googleusercontent.com',
    iosClientId: '768393681101-vfdfe1gosblic1s0ikp9fs7uqec6gug3.apps.googleusercontent.com',
    iosBundleId: 'com.ottovate.farketmezknk',
  );
  // iOS — com.ottovate.farketmezknk (Bundle ID)
}
