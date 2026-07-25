import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjazDrSc0LgTiD7a3uHdH0QUh5sAGOAW4',
    appId: '1:335695394633:android:a6bf24135243e6e510cc98',
    messagingSenderId: '335695394633',
    projectId: 'listapro-prod',
    storageBucket: 'listapro-prod.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDrPX0wZjsUMOw272lndPT3Xa9a6zqemSc',
    appId: '1:335695394633:web:c29973770af32db110cc98',
    messagingSenderId: '335695394633',
    projectId: 'listapro-prod',
    authDomain: 'listapro-prod.firebaseapp.com',
    storageBucket: 'listapro-prod.firebasestorage.app',
  );
}
