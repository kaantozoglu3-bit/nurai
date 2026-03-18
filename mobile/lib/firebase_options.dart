// Generated from google-services.json (Android) and GoogleService-Info.plist (iOS)

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
          'Bu platform desteklenmiyor: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDA0Kj5RLepZjvb9Ald33sojrEkrthQkNk',
    appId: '1:1007291157038:web:ab5764f1715e5c88d02dbf',
    messagingSenderId: '1007291157038',
    projectId: 'painrelief-ai',
    storageBucket: 'painrelief-ai.firebasestorage.app',
    authDomain: 'painrelief-ai.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDA0Kj5RLepZjvb9Ald33sojrEkrthQkNk',
    appId: '1:1007291157038:android:ab5764f1715e5c88d02dbf',
    messagingSenderId: '1007291157038',
    projectId: 'painrelief-ai',
    storageBucket: 'painrelief-ai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCdJM0qLoUy0WGK9WegrT8GDn63Rj8lR8',
    appId: '1:1007291157038:ios:93f2fb075f42d8d3d02dbf',
    messagingSenderId: '1007291157038',
    projectId: 'painrelief-ai',
    storageBucket: 'painrelief-ai.firebasestorage.app',
    iosBundleId: 'com.nurai.app',
  );
}
