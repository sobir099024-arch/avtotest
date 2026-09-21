import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { loadCategories } from "../data";
import type { Category } from "../types";
import { useLocale } from "../LocaleContext";
import { t, tl } from "../i18n";
import { bestAttempt } from "../storage";
import { colorForIndex } from "../theme";

export default function Categories() {
  const { locale } = useLocale();
  const [categories, setCategories] = useState<Category[] | null>(null);

  useEffect(() => {
    loadCategories().then(setCategories);
  }, []);

  if (!categories) return <div className="text-slate-500">...</div>;

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">{t("categories", locale)}</h1>
      <div className="space-y-2">
        {categories.map((c, i) => {
          const best = bestAttempt(`category:${c.code}`);
          const color = colorForIndex(i);
          const ratio = best ? best.correct / best.total : null;
          return (
            <Link
              key={c.code}
              to={`/categories/${c.code}`}
              className="flex items-center gap-3 bg-white border border-slate-200 rounded-2xl px-4 py-3 hover:border-blue-300 hover:shadow-md transition"
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 font-bold text-sm"
                style={{ backgroundColor: `${color}1f`, color }}
              >
                {tl(c.names, locale).charAt(0).toUpperCase()}
              </div>
              <div className="flex-1 min-w-0">
                <div className="font-medium text-sm truncate">{tl(c.names, locale)}</div>
                <div className="text-xs text-slate-400 mt-0.5">
                  {c.count} {t("questionsCount", locale)}
                </div>
                {ratio !== null && (
                  <div className="h-1.5 rounded-full bg-slate-100 mt-1.5 overflow-hidden">
                    <div
                      className="h-full rounded-full"
                      style={{ width: `${ratio * 100}%`, backgroundColor: color }}
                    />
                  </div>
                )}
              </div>
              {best ? (
                <div className="text-sm font-bold shrink-0" style={{ color }}>
                  {best.correct}/{best.total}
                </div>
              ) : (
                <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-slate-300 shrink-0">
                  <path d="M9 6l6 6-6 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              )}
            </Link>
          );
        })}
      </div>
    </div>
  );
}
