import { useState } from "react";
import { loadQuestions } from "../data";
import { useLocale } from "../LocaleContext";
import { t } from "../i18n";
import Quiz from "./Quiz";

const EXAM_COUNT = 20;
const EXAM_TIME_SEC = 25 * 60;
const EXAM_MAX_ERRORS = 3;

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export default function Exam() {
  const { locale } = useLocale();
  const [questionIds, setQuestionIds] = useState<number[] | null>(null);
  const [attemptKey, setAttemptKey] = useState(0);

  async function start() {
    const all = await loadQuestions();
    const ids = shuffle(all.map((_, i) => i)).slice(0, EXAM_COUNT);
    setQuestionIds(ids);
    setAttemptKey((k) => k + 1);
  }

  if (!questionIds) {
    return (
      <div className="bg-white border border-slate-200 rounded-2xl p-6 text-center space-y-4">
        <h1 className="text-xl font-bold">{t("exam", locale)}</h1>
        <p className="text-slate-500">{t("examDesc", locale)}</p>
        <button
          onClick={start}
          className="px-6 py-2 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700"
        >
          {t("start", locale)}
        </button>
      </div>
    );
  }

  return (
    <Quiz
      key={attemptKey}
      config={{
        title: t("exam", locale),
        questionIds,
        resultKey: "exam",
        timeLimitSec: EXAM_TIME_SEC,
        stopOnErrors: EXAM_MAX_ERRORS,
        revealImmediately: false,
      }}
    />
  );
}
