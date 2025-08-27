export function parseBoolean(value: any): boolean | undefined {
  const lower = value.toLowerCase();
  if (lower === "true") return true;
  if (lower === "false") return false;
  return undefined;
}
