import type { AttemptRecord, Locale } from "./types";

const LOCALE_KEY = "avtotest:locale";
const ATTEMPTS_KEY = "avtotest:attempts";

export function getStoredLocale(): Locale {
  try {
    const v = localStorage.getItem(LOCALE_KEY);
    if (v === "uz-Latn" || v === "uz-Cyrl" || v === "ru") return v;
  } catch {
    // ignore
  }
  return "uz-Latn";
}

export function setStoredLocale(locale: Locale) {
  try {
    localStorage.setItem(LOCALE_KEY, locale);
  } catch {
    // ignore
  }
}

type AttemptsByKey = Record<string, AttemptRecord[]>;

function readAttempts(): AttemptsByKey {
  try {
    const raw = localStorage.getItem(ATTEMPTS_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function recordAttempt(key: string, attempt: AttemptRecord) {
  try {
    const all = readAttempts();
    const list = all[key] ?? [];
    list.push(attempt);
    all[key] = list.slice(-20);
    localStorage.setItem(ATTEMPTS_KEY, JSON.stringify(all));
  } catch {
    // ignore
  }
}

export function bestAttempt(key: string): AttemptRecord | null {
  const list = readAttempts()[key];
  if (!list || list.length === 0) return null;
  return list.reduce((best, a) => (a.correct > best.correct ? a : best), list[0]);
}

export function allAttempts(key: string): AttemptRecord[] {
  return readAttempts()[key] ?? [];
}
