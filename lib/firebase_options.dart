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
    apiKey: 'AIzaSyBO1AP3JZ6PswQxxIoGCBUde93myb3aPig',
    appId: '1:940386399769:web:77bff7182ba6f89923dc88',
    messagingSenderId: '940386399769',
    projectId: 'flutter-chat-cd40a',
    authDomain: 'flutter-chat-cd40a.firebaseapp.com',
    storageBucket: 'flutter-chat-cd40a.appspot.com',
    measurementId: 'G-6E0DWK5G3H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkK_EwExKS1Dook-eKzrRI_rvQflTUCHY',
    appId: '1:940386399769:android:97a09ee7d257f77f23dc88',
    messagingSenderId: '940386399769',
    projectId: 'flutter-chat-cd40a',
    storageBucket: 'flutter-chat-cd40a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATeh58jybaEW2vtIJmqAm4TRf_aSJUCdc',
    appId: '1:940386399769:ios:07b7e04eae21f7b823dc88',
    messagingSenderId: '940386399769',
    projectId: 'flutter-chat-cd40a',
    storageBucket: 'flutter-chat-cd40a.appspot.com',
    iosBundleId: 'com.sirmaur.citybuddy',
  );
}
