import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { loadVariants } from "../data";
import type { Variant } from "../types";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";
import { bestAttempt } from "../storage";

export default function Tickets() {
  const { locale } = useLocale();
  const [variants, setVariants] = useState<Variant[] | null>(null);

  useEffect(() => {
    loadVariants().then(setVariants);
  }, []);

  if (!variants) return <div className="text-slate-500">...</div>;

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">{t("tickets", locale)}</h1>
      <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
        {variants.map((v) => {
          const best = bestAttempt(`variant:${v.number}`);
          return (
            <Link
              key={v.number}
              to={`/tickets/${v.number}`}
              className="bg-white border border-slate-200 rounded-xl p-3 text-center hover:border-blue-400 hover:shadow"
            >
              <div className="text-lg font-bold">
                {t("ticket", locale)} {v.number}
              </div>
              <div className="text-xs text-slate-400">
                {v.questions.length} {t("questionsCount", locale)}
              </div>
              {best && (
                <div className="text-xs text-blue-600 mt-1">
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
