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
    apiKey: 'AIzaSyA05DY0j18pD13Xk0oznJqETujWu-GAbps',
    appId: '1:78949537577:web:49d58289091e0b543a4938',
    messagingSenderId: '78949537577',
    projectId: 'slash-j0b',
    authDomain: 'slash-j0b.firebaseapp.com',
    storageBucket: 'slash-j0b.appspot.com',
    measurementId: 'G-QJRMLEFSDQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_PJM0O-BaOvKupBeVgZJfNqH01OULc2s',
    appId: '1:78949537577:android:fcfe19615c6f63be3a4938',
    messagingSenderId: '78949537577',
    projectId: 'slash-j0b',
    storageBucket: 'slash-j0b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIs5Bv22FfTuODunZVZTYv-X4yXt3lfSM',
    appId: '1:78949537577:ios:c5609ada269ca7e23a4938',
    messagingSenderId: '78949537577',
    projectId: 'slash-j0b',
    storageBucket: 'slash-j0b.appspot.com',
    iosBundleId: 'com.example.slashjob',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIs5Bv22FfTuODunZVZTYv-X4yXt3lfSM',
    appId: '1:78949537577:ios:c5609ada269ca7e23a4938',
    messagingSenderId: '78949537577',
    projectId: 'slash-j0b',
    storageBucket: 'slash-j0b.appspot.com',
    iosBundleId: 'com.example.slashjob',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA05DY0j18pD13Xk0oznJqETujWu-GAbps',
    appId: '1:78949537577:web:0e5fa79fb899c06d3a4938',
    messagingSenderId: '78949537577',
    projectId: 'slash-j0b',
    authDomain: 'slash-j0b.firebaseapp.com',
    storageBucket: 'slash-j0b.appspot.com',
    measurementId: 'G-EJ6C27505F',
  );

}