// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyADLnyunfPWW9bToOh_WNgtMYKcKvUm_Nk',
    appId: '1:356085052057:web:132cad23a30649d1d9fe08',
    messagingSenderId: '356085052057',
    projectId: 'talkback-869eb',
    authDomain: 'talkback-869eb.firebaseapp.com',
    databaseURL: 'https://talkback-869eb-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'talkback-869eb.appspot.com',
    measurementId: 'G-DPDHF5YTPW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApldads56HG-exzqMVeRW3CnodPnYRBWs',
    appId: '1:356085052057:android:090ef5c005f6641ed9fe08',
    messagingSenderId: '356085052057',
    projectId: 'talkback-869eb',
    databaseURL: 'https://talkback-869eb-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'talkback-869eb.appspot.com',
  );
}
