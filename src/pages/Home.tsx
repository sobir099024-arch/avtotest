import { Link } from "react-router-dom";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";

const CARDS = [
  { to: "/tickets", titleKey: "tickets" as const, descKey: "ticketsDesc" as const, emoji: "🎫" },
  { to: "/categories", titleKey: "categories" as const, descKey: "categoriesDesc" as const, emoji: "📚" },
  { to: "/exam", titleKey: "exam" as const, descKey: "examDesc" as const, emoji: "⏱️" },
];

export default function Home() {
  const { locale } = useLocale();

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">{t("appTitle", locale)}</h1>
      <div className="grid gap-4 sm:grid-cols-1">
        {CARDS.map((c) => (
          <Link
            key={c.to}
            to={c.to}
            className="block bg-white rounded-2xl border border-slate-200 p-5 hover:border-blue-400 hover:shadow-md transition"
          >
            <div className="text-3xl mb-2">{c.emoji}</div>
            <div className="text-lg font-semibold">{t(c.titleKey, locale)}</div>
            <div className="text-sm text-slate-500 mt-1">{t(c.descKey, locale)}</div>
          </Link>
        ))}
      </div>
      <p className="text-xs text-slate-400 pt-4">{t("dataSource", locale)}</p>
    </div>
  );
}
