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

function writeAttempts(all: AttemptsByKey) {
  try {
    localStorage.setItem(ATTEMPTS_KEY, JSON.stringify(all));
  } catch {
    // ignore
  }
}

type AttemptListener = (key: string, list: AttemptRecord[]) => void;
let listener: AttemptListener | null = null;

/** Cloud sync registers here to learn about every new local attempt. */
export function setAttemptListener(fn: AttemptListener | null) {
  listener = fn;
}

export function recordAttempt(key: string, attempt: AttemptRecord) {
  const all = readAttempts();
  const list = all[key] ?? [];
  list.push(attempt);
  all[key] = list.slice(-20);
  writeAttempts(all);
  listener?.(key, all[key]);
}

/**
 * Merges a list pulled from the cloud into local storage (used right after
 * login, so progress made on another device isn't lost or clobbered).
 */
export function mergeAttempts(key: string, incoming: AttemptRecord[]) {
  const all = readAttempts();
  const local = all[key] ?? [];
  const byTime = new Map(local.map((a) => [a.finishedAt, a]));
  for (const a of incoming) byTime.set(a.finishedAt, a);
  const merged = [...byTime.values()].sort((a, b) => a.finishedAt.localeCompare(b.finishedAt)).slice(-20);
  all[key] = merged;
  writeAttempts(all);
}

export function bestAttempt(key: string): AttemptRecord | null {
  const list = readAttempts()[key];
  if (!list || list.length === 0) return null;
  return list.reduce((best, a) => (a.correct > best.correct ? a : best), list[0]);
}

export function allAttempts(key: string): AttemptRecord[] {
  return readAttempts()[key] ?? [];
}

export function allAttemptKeys(): string[] {
  return Object.keys(readAttempts());
}
