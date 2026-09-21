import { Link, Outlet } from "react-router-dom";
import { useLocale } from "./LocaleContext";
import { LOCALES } from "./types";

const SHORT: Record<string, string> = { "uz-Latn": "UZ", "uz-Cyrl": "ЎЗ", ru: "RU" };

export default function Layout() {
  const { locale, setLocale } = useLocale();

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <header className="bg-white/80 backdrop-blur border-b border-slate-200 sticky top-0 z-10">
        <div className="max-w-3xl mx-auto px-4 py-2.5 flex items-center justify-between gap-3">
          <Link to="/" className="flex items-center gap-2 text-blue-700 font-bold">
            <span className="w-7 h-7 rounded-lg bg-blue-600 text-white flex items-center justify-center text-xs">
              <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
                <path
                  d="M5 13l1.4-4.2A2 2 0 0 1 8.3 7.5h7.4a2 2 0 0 1 1.9 1.3L19 13M5 13v4a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-1h8v1a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-4M5 13h14"
                  stroke="white"
                  strokeWidth="1.6"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </span>
            AvtoTest
          </Link>
          <div className="relative">
            <select
              className="appearance-none border-0 bg-blue-50 text-blue-700 font-semibold rounded-full pl-3 pr-7 py-1.5 text-xs cursor-pointer"
              value={locale}
              onChange={(e) => setLocale(e.target.value as typeof locale)}
            >
              {LOCALES.map((l) => (
                <option key={l.code} value={l.code}>
                  {SHORT[l.code]}
                </option>
              ))}
            </select>
            <svg
              viewBox="0 0 24 24"
              fill="none"
              className="w-3 h-3 text-blue-700 absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none"
            >
              <path d="M6 9l6 6 6-6" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
        </div>
      </header>
      <main className="max-w-3xl mx-auto px-4 py-6">
        <Outlet />
      </main>
    </div>
  );
}
