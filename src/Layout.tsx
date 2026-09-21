import { Link, Outlet } from "react-router-dom";
import { useLocale } from "./LocaleContext";
import { LOCALES } from "./types";
import { t } from "./i18n";

export default function Layout() {
  const { locale, setLocale } = useLocale();

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <header className="bg-white border-b border-slate-200 sticky top-0 z-10">
        <div className="max-w-3xl mx-auto px-4 py-3 flex items-center justify-between gap-3">
          <Link to="/" className="text-lg font-bold text-blue-700">
            {t("appTitle", locale)}
          </Link>
          <select
            className="border border-slate-300 rounded-lg px-2 py-1 text-sm bg-white"
            value={locale}
            onChange={(e) => setLocale(e.target.value as typeof locale)}
          >
            {LOCALES.map((l) => (
              <option key={l.code} value={l.code}>
                {l.label}
              </option>
            ))}
          </select>
        </div>
      </header>
      <main className="max-w-3xl mx-auto px-4 py-6">
        <Outlet />
      </main>
    </div>
  );
}
