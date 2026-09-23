import { Link } from "react-router-dom";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";

const CARDS = [
  {
    to: "/tickets",
    titleKey: "tickets" as const,
    descKey: "ticketsDesc" as const,
    icon: (
      <svg viewBox="0 0 24 24" fill="none" className="w-6 h-6">
        <path
          d="M3 8a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v1.5a1.5 1.5 0 0 0 0 3V14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1.5a1.5 1.5 0 0 0 0-3V8Z"
          stroke="currentColor"
          strokeWidth="1.8"
        />
        <path d="M10 6v10" stroke="currentColor" strokeWidth="1.8" strokeDasharray="2 2" />
      </svg>
    ),
    color: "#2563EB",
  },
  {
    to: "/categories",
    titleKey: "categories" as const,
    descKey: "categoriesDesc" as const,
    icon: (
      <svg viewBox="0 0 24 24" fill="none" className="w-6 h-6">
        <path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H19v15.5a1 1 0 0 1-1 1H6.5A2.5 2.5 0 0 1 4 17V5.5Z" stroke="currentColor" strokeWidth="1.8" />
        <path d="M8 3v16" stroke="currentColor" strokeWidth="1.8" />
      </svg>
    ),
    color: "#16A34A",
  },
  {
    to: "/exam",
    titleKey: "exam" as const,
    descKey: "examDesc" as const,
    icon: (
      <svg viewBox="0 0 24 24" fill="none" className="w-6 h-6">
        <circle cx="12" cy="13" r="8" stroke="currentColor" strokeWidth="1.8" />
        <path d="M12 9v4l3 2" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
        <path d="M9 2h6M12 2v3" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      </svg>
    ),
    color: "#D97706",
  },
];

export default function Home() {
  const { locale } = useLocale();

  return (
    <div className="-mx-4 -mt-6 sm:mx-0 sm:mt-0">
      <div className="bg-gradient-to-br from-blue-600 to-indigo-600 text-white px-6 py-10 sm:rounded-3xl mb-6 flex items-center gap-4">
        <div className="w-14 h-14 rounded-2xl bg-white/15 flex items-center justify-center shrink-0">
          <svg viewBox="0 0 24 24" fill="none" className="w-8 h-8">
            <path
              d="M5 13l1.4-4.2A2 2 0 0 1 8.3 7.5h7.4a2 2 0 0 1 1.9 1.3L19 13M5 13v4a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-1h8v1a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-4M5 13h14"
              stroke="white"
              strokeWidth="1.6"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <circle cx="7.5" cy="16.5" r="0.9" fill="white" />
            <circle cx="16.5" cy="16.5" r="0.9" fill="white" />
          </svg>
        </div>
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold">{t("appTitle", locale)}</h1>
          <p className="text-blue-100 text-sm mt-1">{t("heroSubtitle", locale)}</p>
        </div>
      </div>

      <div className="px-4 sm:px-0 space-y-3">
        {CARDS.map((c) => (
          <Link
            key={c.to}
            to={c.to}
            className="flex items-center gap-4 bg-white rounded-2xl border border-slate-200 p-4 hover:border-blue-300 hover:shadow-md transition"
          >
            <div
              className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0"
              style={{ backgroundColor: `${c.color}1f`, color: c.color }}
            >
              {c.icon}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-base font-semibold">{t(c.titleKey, locale)}</div>
              <div className="text-sm text-slate-500 mt-0.5">{t(c.descKey, locale)}</div>
            </div>
            <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-slate-300 shrink-0">
              <path d="M9 6l6 6-6 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </Link>
        ))}
      </div>
    </div>
  );
}
