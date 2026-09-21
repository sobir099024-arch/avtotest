import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { loadVariants } from "../data";
import type { Variant } from "../types";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";
import Quiz from "./Quiz";

export default function TicketQuiz() {
  const { number } = useParams();
  const { locale } = useLocale();
  const [variant, setVariant] = useState<Variant | null>(null);

  useEffect(() => {
    loadVariants().then((vs) => {
      setVariant(vs.find((v) => v.number === Number(number)) ?? null);
    });
  }, [number]);

  if (!variant) return <div className="text-slate-500">...</div>;

  return (
    <Quiz
      key={number}
      config={{
        title: `${t("ticket", locale)} ${variant.number}`,
        questionIds: variant.questions,
        resultKey: `variant:${variant.number}`,
        revealImmediately: true,
      }}
    />
  );
}
