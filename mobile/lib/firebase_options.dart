// PLACEHOLDER — replace this whole file by running `flutterfire configure`
// from the mobile/ directory once you've created a Firebase project (see
// README.md "Firebase sozlash"). That command regenerates this file with
// real values and wires up android/app/google-services.json automatically.
//
// Until then, these values are not real: Firebase.initializeApp() will
// fail at runtime, which lib/cloud_sync.dart catches — the app keeps
// working fully offline, just without login/cloud sync (see
// `firebaseEnabled` there).

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
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME.appspot.com',
  );
}
