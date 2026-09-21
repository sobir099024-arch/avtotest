import type { Category, Question, Variant } from "./types";

let questionsPromise: Promise<Question[]> | null = null;
let categoriesPromise: Promise<Category[]> | null = null;
let variantsPromise: Promise<Variant[]> | null = null;

const base = import.meta.env.BASE_URL;

export function loadQuestions(): Promise<Question[]> {
  if (!questionsPromise) {
    questionsPromise = fetch(`${base}data/questions.json`).then((r) => r.json());
  }
  return questionsPromise;
}

export function loadCategories(): Promise<Category[]> {
  if (!categoriesPromise) {
    categoriesPromise = fetch(`${base}data/categories.json`).then((r) => r.json());
  }
  return categoriesPromise;
}

export function loadVariants(): Promise<Variant[]> {
  if (!variantsPromise) {
    variantsPromise = fetch(`${base}data/variants.json`).then((r) => r.json());
  }
  return variantsPromise;
}
