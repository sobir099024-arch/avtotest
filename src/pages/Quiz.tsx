import { useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { useNavigate } from "react-router-dom";
import type { Question } from "../types";
import { loadQuestions } from "../data";
import { useLocale } from "../LocaleContext";
import { t, tl } from "../i18n";
import { recordAttempt } from "../storage";
import { RingBadge } from "../components/RingBadge";

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

const LETTERS = ["A", "B", "C", "D", "E"];

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
    const ratio = questions.length ? correctCount / questions.length : 0;
    const color = passed ? "#16A34A" : "#DC2626";
    return (
      <div className="space-y-6">
        <div className="bg-white border border-slate-200 rounded-2xl p-6 text-center">
          <div className="flex justify-center">
            <RingBadge
              ratio={ratio}
              color={color}
              size={148}
              strokeWidth={10}
              label={`${correctCount}/${questions.length}`}
            />
          </div>
          {finished === "too_many_errors" && (
            <div className="text-red-600 font-medium mt-3">{t("stoppedTooManyErrors", locale)}</div>
          )}
          {finished === "time_up" && (
            <div className="text-amber-600 font-medium mt-3">{t("stoppedTimeUp", locale)}</div>
          )}
          <div
            className="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full font-semibold mt-4"
            style={{ backgroundColor: `${color}1f`, color }}
          >
            {passed ? (
              <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
                <path d="M20 6L9 17l-5-5" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            ) : (
              <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
                <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            )}
            {passed ? t("passed", locale) : t("failed", locale)}
          </div>
          <div className="flex gap-3 justify-center pt-6">
            <button
              onClick={() => window.location.reload()}
              className="px-5 py-2.5 rounded-xl bg-blue-600 text-white font-medium hover:bg-blue-700 transition"
            >
              {t("tryAgain", locale)}
            </button>
            <button
              onClick={() => navigate("/")}
              className="px-5 py-2.5 rounded-xl bg-slate-100 text-slate-700 font-medium hover:bg-slate-200 transition"
            >
              {t("backHome", locale)}
            </button>
          </div>
        </div>

        <div className="space-y-3">
          <h3 className="font-semibold text-sm text-slate-500 px-1">{t("reviewAnswers", locale)}</h3>
          {questions.map((q, qi) => {
            const ans = selected[qi];
            const correctIdx = q.answers.findIndex((a) => a.correct);
            const isCorrect = ans !== undefined && q.answers[ans]?.correct;
            const statusColor = ans === undefined ? "#94A3B8" : isCorrect ? "#16A34A" : "#DC2626";
            return (
              <div key={q.id} className="bg-white border border-slate-200 rounded-xl p-3.5">
                <div className="text-sm font-medium mb-2 flex gap-2">
                  <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4 mt-0.5 shrink-0" style={{ color: statusColor }}>
                    {ans === undefined ? (
                      <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.8" />
                    ) : isCorrect ? (
                      <path d="M20 6L9 17l-5-5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    ) : (
                      <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    )}
                  </svg>
                  <span>
                    {qi + 1}. {tl(q.texts, locale)}
                  </span>
                </div>
                <div className="text-sm pl-6">
                  <span className="text-slate-500">{t("yourAnswer", locale)}: </span>
                  <span style={{ color: statusColor }} className="font-medium">
                    {ans === undefined ? t("noAnswer", locale) : tl(q.answers[ans].texts, locale)}
                  </span>
                </div>
                {ans !== undefined && !isCorrect && (
                  <div className="text-sm pl-6">
                    <span className="text-slate-500">{t("correct", locale)}: </span>
                    <span className="text-green-700 font-medium">{tl(q.answers[correctIdx]?.texts, locale)}</span>
                  </div>
                )}
              </div>
            );
          })}
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
  const progress = ((index + (chosen !== undefined ? 1 : 0)) / questions.length) * 100;

  return (
    <div>
      <div className="h-1.5 rounded-full bg-blue-100 mb-3 overflow-hidden">
        <div className="h-full bg-blue-600 rounded-full transition-all" style={{ width: `${progress}%` }} />
      </div>
      <div className="flex items-center justify-between mb-3 text-sm text-slate-500">
        <div className="font-medium">
          {t("question", locale)} {index + 1}/{questions.length}
        </div>
        {config.timeLimitSec ? (
          <div
            className="flex items-center gap-1.5 font-mono font-semibold px-2.5 py-1 rounded-full"
            style={{
              backgroundColor: timeLeft < 60 ? "#DC26261a" : "#2563EB1a",
              color: timeLeft < 60 ? "#DC2626" : "#2563EB",
            }}
          >
            <svg viewBox="0 0 24 24" fill="none" className="w-3.5 h-3.5">
              <circle cx="12" cy="13" r="8" stroke="currentColor" strokeWidth="1.8" />
              <path d="M12 9v4l3 2" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            </svg>
            {formatTime(timeLeft)}
          </div>
        ) : null}
      </div>
      <div className="bg-white border border-slate-200 rounded-2xl p-5">
        <div className="text-base font-medium mb-3">{tl(q.texts, locale)}</div>
        {q.hasImage && q.image && (
          <img
            src={`${import.meta.env.BASE_URL}${q.image}`}
            alt=""
            className="mb-3 w-full max-h-72 object-contain rounded-xl border border-slate-200 bg-slate-50"
          />
        )}
        {q.hasImage && !q.image && (
          <div className="mb-3 text-xs text-slate-400 bg-slate-100 rounded-xl p-4 text-center border border-slate-200">
            {t("imageMissing", locale)}
          </div>
        )}
        <div className="space-y-2">
          {q.answers.map((a, ai) => {
            let border = "border-slate-200";
            let bg = "bg-white hover:border-blue-300";
            let badgeBg = "bg-slate-100 text-slate-500";
            let trailing: ReactNode = null;
            if (chosen !== undefined && config.revealImmediately) {
              if (ai === correctIdx) {
                border = "border-green-500";
                bg = "bg-green-50";
                badgeBg = "bg-green-600 text-white";
                trailing = (
                  <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-green-600 shrink-0">
                    <path d="M20 6L9 17l-5-5" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                );
              } else if (ai === chosen) {
                border = "border-red-500";
                bg = "bg-red-50";
                badgeBg = "bg-red-600 text-white";
                trailing = (
                  <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-red-600 shrink-0">
                    <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                );
              }
            } else if (chosen === ai) {
              border = "border-blue-500";
              bg = "bg-blue-50";
              badgeBg = "bg-blue-600 text-white";
            }
            return (
              <button
                key={ai}
                onClick={() => choose(ai)}
                disabled={chosen !== undefined}
                className={`w-full flex items-center gap-3 text-left border rounded-xl px-3.5 py-3 transition ${border} ${bg}`}
              >
                <span className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0 ${badgeBg}`}>
                  {LETTERS[ai] ?? ai + 1}
                </span>
                <span className="flex-1">{tl(a.texts, locale)}</span>
                {trailing}
              </button>
            );
          })}
        </div>
        {config.revealImmediately && chosen !== undefined && q.explanation?.[locale] && (
          <div className="mt-3 text-sm text-slate-600 bg-blue-50/60 border border-blue-100 rounded-xl p-3.5">
            <div className="font-semibold mb-1 text-blue-700 flex items-center gap-1.5">
              <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
                <path
                  d="M9 18h6M10 21h4M12 3a6 6 0 0 0-3.6 10.8c.5.4.8 1 .8 1.7V16h5.6v-.5c0-.7.3-1.3.8-1.7A6 6 0 0 0 12 3Z"
                  stroke="currentColor"
                  strokeWidth="1.6"
                  strokeLinejoin="round"
                />
              </svg>
              {t("explanation", locale)}
            </div>
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
            className="px-5 py-2.5 rounded-xl bg-blue-600 text-white font-medium disabled:bg-slate-200 disabled:text-slate-400 hover:bg-blue-700 transition flex items-center gap-1.5"
          >
            {isLast ? t("finish", locale) : t("next", locale)}
            <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
              <path d="M9 6l6 6-6 6" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
