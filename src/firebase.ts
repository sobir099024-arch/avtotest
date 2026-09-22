import { initializeApp, type FirebaseOptions } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const config: FirebaseOptions = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

// Firebase is optional: without VITE_FIREBASE_* env vars the app still
// works fully offline/local (see README "Firebase sozlash"), just without
// login and cross-device sync.
export const firebaseEnabled = Boolean(config.apiKey && config.projectId);

const app = firebaseEnabled ? initializeApp(config) : null;

export const auth = app ? getAuth(app) : null;
export const db = app ? getFirestore(app) : null;
