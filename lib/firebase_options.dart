// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
// Firebase configuration for project appfinanzas-ad4a2 (generated via firebase apps:sdkconfig).

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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCi-FLk_XJIJ5m-lEktlrq8wQjYrTUEIMA',
    appId: '1:643273677677:web:0d26d1a6125c8e87201864',
    messagingSenderId: '643273677677',
    projectId: 'appfinanzas-ad4a2',
    authDomain: 'appfinanzas-ad4a2.firebaseapp.com',
    storageBucket: 'appfinanzas-ad4a2.firebasestorage.app',
    measurementId: 'G-M7J5QC9Q3Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7ECcucGA5PQdgfxGdhK_jpDcPn_t5HpI',
    appId: '1:643273677677:android:3d20b39e1004b1ac201864',
    messagingSenderId: '643273677677',
    projectId: 'appfinanzas-ad4a2',
    storageBucket: 'appfinanzas-ad4a2.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCi-FLk_XJIJ5m-lEktlrq8wQjYrTUEIMA',
    appId: '1:643273677677:web:2386aa7d51096154201864',
    messagingSenderId: '643273677677',
    projectId: 'appfinanzas-ad4a2',
    authDomain: 'appfinanzas-ad4a2.firebaseapp.com',
    storageBucket: 'appfinanzas-ad4a2.firebasestorage.app',
    measurementId: 'G-Q7CP96B5DB',
  );

}