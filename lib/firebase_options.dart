// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDsbYgupAMcxWrAqfUxPMzir6Jc8oMqmOc',
    appId: '1:246221080937:web:6ce75c18f67968025a55f8',
    messagingSenderId: '246221080937',
    projectId: 'fitquest-c4745',
    authDomain: 'fitquest-c4745.firebaseapp.com',
    storageBucket: 'fitquest-c4745.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUmu5U0DIfOnpNH6UC4FTDlAcJO84cBJE',
    appId: '1:246221080937:android:36b9b6f083d08abd5a55f8',
    messagingSenderId: '246221080937',
    projectId: 'fitquest-c4745',
    storageBucket: 'fitquest-c4745.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzwoVBCel9ikvUZpWFgjwEHk3ns8IwIAA',
    appId: '1:246221080937:ios:bb8ac65da6e6d3d85a55f8',
    messagingSenderId: '246221080937',
    projectId: 'fitquest-c4745',
    storageBucket: 'fitquest-c4745.firebasestorage.app',
    iosBundleId: 'com.example.fitquest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBzwoVBCel9ikvUZpWFgjwEHk3ns8IwIAA',
    appId: '1:246221080937:ios:bb8ac65da6e6d3d85a55f8',
    messagingSenderId: '246221080937',
    projectId: 'fitquest-c4745',
    storageBucket: 'fitquest-c4745.firebasestorage.app',
    iosBundleId: 'com.example.fitquest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDsbYgupAMcxWrAqfUxPMzir6Jc8oMqmOc',
    appId: '1:246221080937:web:596d364a2df98cc75a55f8',
    messagingSenderId: '246221080937',
    projectId: 'fitquest-c4745',
    authDomain: 'fitquest-c4745.firebaseapp.com',
    storageBucket: 'fitquest-c4745.firebasestorage.app',
  );
}