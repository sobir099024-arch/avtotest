import {
  GoogleAuthProvider,
  onAuthStateChanged,
  signInWithPopup,
  signOut as firebaseSignOut,
  type User,
} from "firebase/auth";
import { collection, doc, getDocs, setDoc } from "firebase/firestore";
import { auth, db, firebaseEnabled } from "./firebase";
import { allAttempts, allAttemptKeys, mergeAttempts, setAttemptListener } from "./storage";

async function pullFromCloud(uid: string) {
  if (!db) return;
  const snap = await getDocs(collection(db, "users", uid, "attempts"));
  snap.forEach((d) => {
    const list = (d.data().list as import("./types").AttemptRecord[]) ?? [];
    mergeAttempts(d.id, list);
  });
}

async function pushKeyToCloud(uid: string, key: string) {
  if (!db) return;
  await setDoc(doc(db, "users", uid, "attempts", key), { list: allAttempts(key) });
}

async function pushAllLocalToCloud(uid: string) {
  for (const key of allAttemptKeys()) {
    await pushKeyToCloud(uid, key);
  }
}

/**
 * Wires Firebase Auth state to local storage: on login, pulls cloud
 * progress down (merging with whatever is already local), pushes any
 * purely-local progress up, then mirrors every new attempt to Firestore
 * as it's recorded. On logout, stops mirroring (local storage keeps
 * working exactly as before, offline).
 */
export function initCloudSync(onUserChange: (user: User | null) => void) {
  if (!firebaseEnabled || !auth) {
    onUserChange(null);
    return () => {};
  }
  return onAuthStateChanged(auth, async (user) => {
    onUserChange(user);
    if (user) {
      await pullFromCloud(user.uid);
      await pushAllLocalToCloud(user.uid);
      setAttemptListener((key) => {
        pushKeyToCloud(user.uid, key).catch(() => {
          // best-effort; local storage is still the source of truth
        });
      });
    } else {
      setAttemptListener(null);
    }
  });
}

export function signInWithGoogle() {
  if (!auth) return Promise.reject(new Error("Firebase is not configured"));
  return signInWithPopup(auth, new GoogleAuthProvider());
}

export function signOutUser() {
  if (!auth) return Promise.resolve();
  return firebaseSignOut(auth);
}
