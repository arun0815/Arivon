import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('This platform is not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcsvhrPeBdFwS45Sdiq0NKgUyTfJ0iOpc',
    appId: '1:185245724953:android:5cff05df3ab27c4f8d9588',
    messagingSenderId: '185245724953',
    projectId: 'arivon-92f66',
    storageBucket: 'arivon-92f66.firebasestorage.app',
  );
}
