import { useState } from "react";
import { useAuth } from "../AuthContext";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";

export function UserMenu() {
  const { user, loading, enabled, signIn, signOut } = useAuth();
  const { locale } = useLocale();
  const [busy, setBusy] = useState(false);
  const [open, setOpen] = useState(false);

  if (!enabled || loading) return null;

  if (!user) {
    return (
      <button
        onClick={async () => {
          setBusy(true);
          try {
            await signIn();
          } catch {
            // user closed the popup, etc. — nothing to show
          } finally {
            setBusy(false);
          }
        }}
        disabled={busy}
        className="flex items-center gap-1.5 bg-blue-600 text-white text-xs font-semibold rounded-full pl-2.5 pr-3 py-1.5 hover:bg-blue-700 transition disabled:opacity-60"
      >
        <svg viewBox="0 0 24 24" className="w-3.5 h-3.5">
          <path
            fill="currentColor"
            d="M21.35 11.1h-9.17v2.73h6.51c-.33 3.14-2.9 4.48-5.5 4.48-3.34 0-6.25-2.69-6.25-6.31s2.91-6.31 6.25-6.31c1.9 0 3.16.8 3.9 1.5l2.2-2.13C17.85 3.4 15.53 2.4 13.19 2.4 8.13 2.4 4 6.53 4 11.59s4.13 9.19 9.19 9.19c5.29 0 8.8-3.72 8.8-8.96 0-.6-.06-1.06-.14-1.51z"
          />
        </svg>
        {t("signInGoogle", locale)}
      </button>
    );
  }

  return (
    <div className="relative">
      <button onClick={() => setOpen((v) => !v)} className="block">
        {user.photoURL ? (
          <img src={user.photoURL} alt="" className="w-8 h-8 rounded-full border border-slate-200" referrerPolicy="no-referrer" />
        ) : (
          <div className="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center text-xs font-bold">
            {(user.displayName ?? user.email ?? "?").charAt(0).toUpperCase()}
          </div>
        )}
      </button>
      {open && (
        <>
          <div className="fixed inset-0 z-10" onClick={() => setOpen(false)} />
          <div className="absolute right-0 top-10 z-20 bg-white border border-slate-200 rounded-xl shadow-lg py-2 w-52">
            <div className="px-3 py-1.5 text-xs text-slate-500 truncate border-b border-slate-100 mb-1">
              {user.displayName ?? user.email}
            </div>
            <button
              onClick={async () => {
                setOpen(false);
                await signOut();
              }}
              className="w-full text-left px-3 py-1.5 text-sm text-red-600 hover:bg-red-50"
            >
              {t("signOut", locale)}
            </button>
          </div>
        </>
      )}
    </div>
  );
}
