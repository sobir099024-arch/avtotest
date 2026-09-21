import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { loadCategories } from "../data";
import type { Category } from "../types";
import { useLocale } from "../LocaleContext";
import { t, tl } from "../i18n";
import { bestAttempt } from "../storage";

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
        {categories.map((c) => {
          const best = bestAttempt(`category:${c.code}`);
          return (
            <Link
              key={c.code}
              to={`/categories/${c.code}`}
              className="flex items-center justify-between bg-white border border-slate-200 rounded-xl px-4 py-3 hover:border-blue-400 hover:shadow"
            >
              <div>
                <div className="font-medium">{tl(c.names, locale)}</div>
                <div className="text-xs text-slate-400">
                  {c.count} {t("questionsCount", locale)}
                </div>
              </div>
              {best && (
                <div className="text-sm text-blue-600 font-semibold">
                  {best.correct}/{best.total}
                </div>
              )}
            </Link>
          );
        })}
      </div>
    </div>
  );
}
