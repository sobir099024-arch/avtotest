export function RingBadge({
  ratio,
  color,
  size = 46,
  strokeWidth = 3.5,
  label,
}: {
  ratio: number | null;
  color: string;
  size?: number;
  strokeWidth?: number;
  label: string;
}) {
  const r = (size - strokeWidth) / 2;
  const c = 2 * Math.PI * r;
  const value = ratio ?? 1;
  const offset = c * (1 - value);

  return (
    <div className="relative" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={`${color}1f`}
          strokeWidth={strokeWidth}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={ratio === null ? `${color}2e` : color}
          strokeWidth={strokeWidth}
          strokeDasharray={c}
          strokeDashoffset={offset}
          strokeLinecap="round"
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center text-sm font-extrabold" style={{ color }}>
        {label}
      </div>
    </div>
  );
}
