export const PALETTE = [
  "#2563EB",
  "#16A34A",
  "#D97706",
  "#DB2777",
  "#7C3AED",
  "#0891B2",
  "#EA580C",
  "#4F46E5",
];

export function colorForIndex(i: number): string {
  return PALETTE[i % PALETTE.length];
}
