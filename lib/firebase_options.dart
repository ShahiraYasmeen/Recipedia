import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for Android.');
      case TargetPlatform.iOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for iOS.');
      case TargetPlatform.macOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for macOS.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCwakGeYzKUyfdE5XHzVkarSQcyBNRGO1k",
    authDomain: "recipedia-app-6e87c.firebaseapp.com",
    projectId: "recipedia-app-6e87c",
    storageBucket: "recipedia-app-6e87c.appspot.com", // ✅ Fixed: correct domain
    messagingSenderId: "559017672881",
    appId: "1:559017672881:web:a00b3a33f18c6d274b2290",
    measurementId: "G-5KRJXCYVGY",
  );
}
