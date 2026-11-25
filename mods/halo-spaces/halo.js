// Halo helmets for agents (only in the "halo" layout). Each agent terminal gets one of ten colours at
// random, avoiding repeats while any is unused, and keeps it while the terminal lives.
// The same file is in halo-agents and halo-spaces; shared state keeps both showing the same face.
import { image } from "gpui-kit";
import { agents, shared, setShared } from "herdr";

const NAMES = ["verde", "rojo", "azul", "dorado", "naranja", "morado", "blanco", "negro", "cian", "rosa"];
const KEY = "halo.helmets";

// Call once per render; returns (terminal, size) => the helmet's picture, or null.
export function faces() {
  if (shared("layout") !== "halo") return () => null;
  const ids = agents().map((a) => a.address);
  const map = { ...(shared(KEY) ?? {}) };
  let changed = false;
  for (const id of ids) {
    if (NAMES[map[id]]) continue;
    const uses = NAMES.map((_, i) => ids.filter((other) => map[other] === i).length);
    const least = Math.min(...uses);
    const pool = NAMES.map((_, i) => i).filter((i) => uses[i] === least);
    map[id] = pool[Math.floor(Math.random() * pool.length)];
    changed = true;
  }
  if (changed) setShared(KEY, map);
  return (id, size) => (id && ids.includes(id)
    ? image(`icons/halo/casco-${NAMES[map[id]]}.png`).w(size).h(size).flex_none()
    : null);
}
