import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for iOS.');
      case TargetPlatform.macOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for macOS.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwakGeYzKUyfdE5XHzVkarSQcyBNRGO1k',
    appId: '1:559017672881:web:a00b3a33f18c6d274b2290',
    messagingSenderId: '559017672881',
    projectId: 'recipedia-app-6e87c',
    authDomain: 'recipedia-app-6e87c.firebaseapp.com',
    storageBucket: 'recipedia-app-6e87c.firebasestorage.app',
    measurementId: 'G-5KRJXCYVGY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPR3T-VqhcPY2K11b-ORMEJVahxWxQhqU',
    appId: '1:559017672881:android:32864a86ffdffbdd4b2290',
    messagingSenderId: '559017672881',
    projectId: 'recipedia-app-6e87c',
    storageBucket: 'recipedia-app-6e87c.firebasestorage.app',
  );

}