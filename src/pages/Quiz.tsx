import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import type { Question } from "../types";
import { loadQuestions } from "../data";
import { useLocale } from "../LocaleContext";
import { t, tl } from "../i18n";
import { recordAttempt } from "../storage";

export interface QuizConfig {
  title: string;
  questionIds: number[];
  resultKey: string;
  timeLimitSec?: number;
  stopOnErrors?: number;
  revealImmediately: boolean;
}

function formatTime(sec: number) {
  const m = Math.floor(sec / 60)
    .toString()
    .padStart(2, "0");
  const s = Math.floor(sec % 60)
    .toString()
    .padStart(2, "0");
  return `${m}:${s}`;
}

export default function Quiz({ config }: { config: QuizConfig }) {
  const { locale } = useLocale();
  const navigate = useNavigate();
  const [all, setAll] = useState<Question[] | null>(null);
  const [index, setIndex] = useState(0);
  const [selected, setSelected] = useState<Record<number, number>>({});
  const [finished, setFinished] = useState<null | "completed" | "too_many_errors" | "time_up">(null);
  const [timeLeft, setTimeLeft] = useState(config.timeLimitSec ?? 0);
  const savedRef = useRef(false);

  useEffect(() => {
    loadQuestions().then(setAll);
  }, []);

  const questions = useMemo(() => {
    if (!all) return [];
    return config.questionIds.map((id) => all[id]);
  }, [all, config.questionIds]);

  useEffect(() => {
    if (!config.timeLimitSec || finished) return;
    if (timeLeft <= 0) {
      setFinished("time_up");
      return;
    }
    const timer = setInterval(() => setTimeLeft((v) => v - 1), 1000);
    return () => clearInterval(timer);
  }, [timeLeft, finished, config.timeLimitSec]);

  const wrongCount = useMemo(() => {
    let n = 0;
    for (const [qi, ansIdx] of Object.entries(selected)) {
      const q = questions[Number(qi)];
      if (q && !q.answers[ansIdx]?.correct) n++;
    }
    return n;
  }, [selected, questions]);

  useEffect(() => {
    if (config.stopOnErrors && wrongCount >= config.stopOnErrors && !finished) {
      setFinished("too_many_errors");
    }
  }, [wrongCount, config.stopOnErrors, finished]);

  const correctCount = useMemo(() => {
    let n = 0;
    for (const [qi, ansIdx] of Object.entries(selected)) {
      const q = questions[Number(qi)];
      if (q && q.answers[ansIdx]?.correct) n++;
    }
    return n;
  }, [selected, questions]);

  useEffect(() => {
    if (finished && !savedRef.current) {
      savedRef.current = true;
      recordAttempt(config.resultKey, {
        correct: correctCount,
        total: questions.length,
        finishedAt: new Date().toISOString(),
      });
    }
  }, [finished, correctCount, questions.length, config.resultKey]);

  if (!all) return <div className="text-slate-500">...</div>;
  if (questions.length === 0) return <div className="text-slate-500">—</div>;

  if (finished) {
    const passed = questions.length > 0 && correctCount >= Math.ceil(questions.length * 0.9);
    return (
      <div className="bg-white border border-slate-200 rounded-2xl p-6 text-center space-y-4">
        <h2 className="text-xl font-bold">{t("yourResult", locale)}</h2>
        <div className="text-4xl font-extrabold text-blue-700">
          {correctCount}/{questions.length}
        </div>
        {finished === "too_many_errors" && (
          <div className="text-red-600 font-medium">{t("stoppedTooManyErrors", locale)}</div>
        )}
        {finished === "time_up" && <div className="text-amber-600 font-medium">{t("stoppedTimeUp", locale)}</div>}
        <div className={`inline-block px-4 py-1 rounded-full font-semibold ${passed ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}>
          {passed ? t("passed", locale) : t("failed", locale)}
        </div>
        <div className="pt-4 space-y-3 text-left">
          <h3 className="font-semibold text-sm text-slate-500">{t("reviewAnswers", locale)}</h3>
          {questions.map((q, qi) => {
            const ans = selected[qi];
            const correctIdx = q.answers.findIndex((a) => a.correct);
            return (
              <div key={q.id} className="border border-slate-200 rounded-xl p-3">
                <div className="text-sm font-medium mb-2">
                  {qi + 1}. {tl(q.texts, locale)}
                </div>
                <div className="text-sm">
                  <span className="text-slate-500">{t("yourAnswer", locale)}: </span>
                  <span className={ans === undefined ? "text-slate-400" : q.answers[ans]?.correct ? "text-green-700" : "text-red-700"}>
                    {ans === undefined ? t("noAnswer", locale) : tl(q.answers[ans].texts, locale)}
                  </span>
                </div>
                {ans !== undefined && !q.answers[ans]?.correct && (
                  <div className="text-sm">
                    <span className="text-slate-500">{t("correct", locale)}: </span>
                    <span className="text-green-700">{tl(q.answers[correctIdx]?.texts, locale)}</span>
                  </div>
                )}
              </div>
            );
          })}
        </div>
        <div className="flex gap-3 justify-center pt-2">
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700"
          >
            {t("tryAgain", locale)}
          </button>
          <button
            onClick={() => navigate("/")}
            className="px-4 py-2 rounded-lg bg-slate-100 text-slate-700 font-medium hover:bg-slate-200"
          >
            {t("backHome", locale)}
          </button>
        </div>
      </div>
    );
  }

  const q = questions[index];
  const chosen = selected[index];
  const isLast = index === questions.length - 1;

  function choose(ansIdx: number) {
    if (selected[index] !== undefined) return;
    setSelected((s) => ({ ...s, [index]: ansIdx }));
  }

  function goNext() {
    if (isLast) {
      setFinished("completed");
    } else {
      setIndex((i) => i + 1);
    }
  }

  const correctIdx = q.answers.findIndex((a) => a.correct);

  return (
    <div>
      <div className="flex items-center justify-between mb-3 text-sm text-slate-500">
        <div>
          {t("question", locale)} {index + 1}/{questions.length}
        </div>
        {config.timeLimitSec ? (
          <div className={`font-mono font-semibold ${timeLeft < 60 ? "text-red-600" : ""}`}>
            {t("timeLeft", locale)}: {formatTime(timeLeft)}
          </div>
        ) : null}
      </div>
      <div className="bg-white border border-slate-200 rounded-2xl p-5">
        <div className="text-base font-medium mb-3">{tl(q.texts, locale)}</div>
        {q.hasImage && (
          <div className="mb-3 text-xs text-slate-400 bg-slate-100 rounded-lg p-3 text-center">
            {t("imageMissing", locale)}
          </div>
        )}
        <div className="space-y-2">
          {q.answers.map((a, ai) => {
            let cls = "border-slate-200 hover:border-blue-300";
            if (chosen !== undefined && config.revealImmediately) {
              if (ai === correctIdx) cls = "border-green-500 bg-green-50";
              else if (ai === chosen) cls = "border-red-500 bg-red-50";
            } else if (chosen === ai) {
              cls = "border-blue-500 bg-blue-50";
            }
            return (
              <button
                key={ai}
                onClick={() => choose(ai)}
                disabled={chosen !== undefined}
                className={`w-full text-left border rounded-xl px-4 py-2 transition ${cls}`}
              >
                {tl(a.texts, locale)}
              </button>
            );
          })}
        </div>
        {config.revealImmediately && chosen !== undefined && q.explanation?.[locale] && (
          <div className="mt-3 text-sm text-slate-600 bg-slate-50 rounded-lg p-3">
            <div className="font-semibold mb-1">{t("explanation", locale)}</div>
            {q.explanation[locale]!.map((b, i) => (
              <p key={i} className="mb-1 last:mb-0 whitespace-pre-line">
                {b.text}
              </p>
            ))}
          </div>
        )}
        <div className="mt-4 flex justify-end">
          <button
            onClick={goNext}
            disabled={chosen === undefined}
            className="px-5 py-2 rounded-lg bg-blue-600 text-white font-medium disabled:bg-slate-200 disabled:text-slate-400 hover:bg-blue-700"
          >
            {isLast ? t("finish", locale) : t("next", locale)}
          </button>
        </div>
      </div>
    </div>
  );
}
