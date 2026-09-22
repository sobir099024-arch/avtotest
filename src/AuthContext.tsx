import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import type { User } from "firebase/auth";
import { firebaseEnabled } from "./firebase";
import { initCloudSync, signInWithGoogle, signOutUser } from "./cloudSync";

interface AuthContextValue {
  user: User | null;
  loading: boolean;
  enabled: boolean;
  signIn: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(firebaseEnabled);

  useEffect(() => {
    const unsubscribe = initCloudSync((u) => {
      setUser(u);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  async function signIn() {
    await signInWithGoogle();
  }

  async function signOut() {
    await signOutUser();
  }

  return (
    <AuthContext.Provider value={{ user, loading, enabled: firebaseEnabled, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
