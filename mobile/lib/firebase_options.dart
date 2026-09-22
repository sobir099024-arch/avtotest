// Android values are real (from android/app/google-services.json, project
// "avto-test-e6978"). The `web` block is still a placeholder — fill it in
// (or run `flutterfire configure` for both platforms at once) if this app
// is ever run on Flutter web; see README.md "Firebase sozlash". Until then,
// Firebase.initializeApp() on web will fail at runtime, which
// lib/cloud_sync.dart catches gracefully (see `firebaseEnabled` there) — it
// does not affect Android.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (Platform.isAndroid) return android;
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME.firebaseapp.com',
    storageBucket: 'REPLACE_ME.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCterWbhGboLdNqM99GMSqSvMzjf1fvUb0',
    appId: '1:816933496481:android:ce2eb1ecf3e86bf9c7b2e0',
    messagingSenderId: '816933496481',
    projectId: 'avto-test-e6978',
    storageBucket: 'avto-test-e6978.firebasestorage.app',
  );
}
