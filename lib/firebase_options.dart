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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9YsYdMQzK-xMAJtieymGxIP5huk8E33g',
    authDomain: 'turfly-321cf.firebaseapp.com',
    appId: '1:780600415180:android:0e5996dfd9ed2cf7f28369',
    messagingSenderId: '780600415180',
    projectId: 'turfly-321cf',
    storageBucket: 'turfly-321cf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9YsYdMQzK-xMAJtieymGxIP5huk8E33g',
    authDomain: 'turfly-321cf.firebaseapp.com',
    appId: '1:780600415180:android:0e5996dfd9ed2cf7f28369',
    messagingSenderId: '780600415180',
    projectId: 'turfly-321cf',
    storageBucket: 'turfly-321cf.firebasestorage.app',
    iosBundleId: 'com.example.turfly',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9YsYdMQzK-xMAJtieymGxIP5huk8E33g',
    authDomain: 'turfly-321cf.firebaseapp.com',
    appId: '1:780600415180:web:placeholder',
    messagingSenderId: '780600415180',
    projectId: 'turfly-321cf',
    storageBucket: 'turfly-321cf.firebasestorage.app',
  );
}
