export type Locale = "uz-Latn" | "uz-Cyrl" | "ru";

export const LOCALES: { code: Locale; label: string }[] = [
  { code: "uz-Latn", label: "O'zbekcha (lotin)" },
  { code: "uz-Cyrl", label: "Ўзбекча (кирилл)" },
  { code: "ru", label: "Русский" },
];

export type LocalizedText = Partial<Record<Locale, string>>;

export interface Answer {
  correct: boolean;
  texts: LocalizedText;
}

export interface ExplanationBlock {
  text: string;
}

export interface Question {
  id: string;
  category: string;
  hasImage: boolean;
  image?: string;
  texts: LocalizedText;
  answers: Answer[];
  explanation?: Partial<Record<Locale, ExplanationBlock[]>>;
}

export interface Category {
  code: string;
  names: LocalizedText;
  count: number;
}

export interface Variant {
  number: number;
  questions: number[];
}

export interface AttemptRecord {
  correct: number;
  total: number;
  finishedAt: string;
}
