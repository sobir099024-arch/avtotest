import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { loadVariants } from "../data";
import type { Variant } from "../types";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";
import { bestAttempt } from "../storage";
import { colorForIndex } from "../theme";
import { RingBadge } from "../components/RingBadge";

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
          const color = colorForIndex(v.number);
          const ratio = best ? best.correct / best.total : null;
          return (
            <Link
              key={v.number}
              to={`/tickets/${v.number}`}
              className="flex flex-col items-center gap-1.5 bg-white border border-slate-200 rounded-2xl p-3 text-center hover:border-blue-300 hover:shadow-md transition"
            >
              <RingBadge ratio={ratio} color={color} label={String(v.number)} />
              <div className="text-[11px] text-slate-400">
                {v.questions.length} {t("questionsCount", locale)}
              </div>
              {best && (
                <div className="text-xs font-semibold" style={{ color }}>
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
