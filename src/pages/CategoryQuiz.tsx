import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { loadQuestions } from "../data";
import Quiz from "./Quiz";

const PRACTICE_COUNT = 20;

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export default function CategoryQuiz() {
  const { code } = useParams();
  const [questionIds, setQuestionIds] = useState<number[] | null>(null);

  useEffect(() => {
    loadQuestions().then((all) => {
      const ids = all.reduce<number[]>((acc, q, i) => {
        if (q.category === code) acc.push(i);
        return acc;
      }, []);
      setQuestionIds(shuffle(ids).slice(0, PRACTICE_COUNT));
    });
  }, [code]);

  if (!questionIds) return <div className="text-slate-500">...</div>;

  return (
    <Quiz
      key={code}
      config={{
        title: code ?? "",
        questionIds,
        resultKey: `category:${code}`,
        revealImmediately: true,
      }}
    />
  );
}
