import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'models.dart';
import 'storage.dart';

/// Becomes true only if Firebase.initializeApp() succeeds with real
/// credentials (see firebase_options.dart). When false the app keeps
/// working fully offline — this just means no login/cloud sync UI.
bool firebaseEnabled = false;

Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseEnabled = true;
  } catch (e) {
    debugPrint('Firebase not configured, running fully offline: $e');
    firebaseEnabled = false;
  }
}

class CloudSync {
  CloudSync._();
  static final CloudSync instance = CloudSync._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  FirebaseAuth? get _auth => firebaseEnabled ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _db => firebaseEnabled ? FirebaseFirestore.instance : null;

  Stream<User?> get userChanges => _auth?.authStateChanges() ?? const Stream.empty();
  User? get currentUser => _auth?.currentUser;

  Future<void> onUserChanged(User? user) async {
    if (user == null) {
      Storage.instance.setAttemptListener(null);
      return;
    }
    await _pullFromCloud(user.uid);
    await _pushAllLocalToCloud(user.uid);
    Storage.instance.setAttemptListener((key, list) {
      _pushKeyToCloud(user.uid, key).catchError((_) {
        // best-effort; local storage stays the source of truth
      });
    });
  }

  Future<void> _pullFromCloud(String uid) async {
    final db = _db;
    if (db == null) return;
    final snap = await db.collection('users').doc(uid).collection('attempts').get();
    for (final d in snap.docs) {
      final list = (d.data()['list'] as List<dynamic>? ?? [])
          .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      await Storage.instance.mergeAttempts(d.id, list);
    }
  }

  Future<void> _pushKeyToCloud(String uid, String key) async {
    final db = _db;
    if (db == null) return;
    final list = await Storage.instance.allAttempts(key);
    await db.collection('users').doc(uid).collection('attempts').doc(key).set({
      'list': list.map((a) => a.toJson()).toList(),
    });
  }

  Future<void> _pushAllLocalToCloud(String uid) async {
    for (final key in await Storage.instance.allAttemptKeys()) {
      await _pushKeyToCloud(uid, key);
    }
  }

  Future<void> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) throw StateError('Firebase is not configured');
    if (kIsWeb) {
      await auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // user cancelled
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth?.signOut();
    if (!kIsWeb) await _googleSignIn.signOut();
  }
}
