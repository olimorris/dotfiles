// A list's motion and a fold's arrow, as T3's Sidebar.motion.ts. scripts/sync.sh copies this to the mods that use it.
import { div, svg } from "gpui-kit";

export const MOTION = { duration: 150, easing: "ease-out" };

// T3 turns its arrow. Herdr can't animate a turn, so the two directions cross-fade in one slot. No `id` (a ghost): it just shows.
export function foldArrow(mod, id, open, size, color) {
  const glyph = (name) => svg(`mods/${mod}/icons/chevron-${name}.svg`).size(size).flex_none().text_color(color);
  if (!id) return glyph(open ? "down" : "right");
  const way = (name, on) => div().id(`${id}-${name}`).absolute().top(0).left(0).opacity(on ? 1 : 0).transition("opacity", MOTION).child(glyph(name));
  return div().relative().size(size).flex_none().child(way("down", open)).child(way("right", !open));
}

// `entries`: the list's rows in order, each { key, h, y?, ghost? }: `y` where they don't just stack, ghost() to draw a row's leaving
// without handlers or ids the list uses (none: it just goes).
// When the rows change, one that moved slides from where it was, a new one fades in riding the kept row above it, and one
// that left fades out riding the same way. Over 40 coming and going, they just show. `freeze` records the rows without playing
// anything (a drag draws its own); `from` lands a dropped row from where it was let go: { key, y }.
// Herdr eases only later changes to an element: a row that moves gets a new id, first drawn where it was, then let go.
export function planMotion(view, entries, cx, { freeze, from } = {}) {
  let y = 0;
  const at = new Map(entries.map((e) => { const top = e.y ?? y; y = top + e.h; return [e.key, { ...e, y: top }]; }));
  const sig = [...at.keys()].join("\n"), m = view.motion;
  if (!m || sig === m.sig || freeze) {
    view.motion = { gen: {}, fly: {}, exits: [], step: 0, leaving: false, ...m, sig, at };
    return;
  }
  const exits = [...m.at.values()].filter((v) => !at.has(v.key));
  const fresh = [...at.keys()].filter((k) => !m.at.has(k));
  const step = m.step + 1;
  if (fresh.length + exits.length > 40) {
    view.motion = { ...m, sig, at, fly: {}, exits: [], step, leaving: false };
    return;
  }
  const fly = {}, gen = m.gen;
  let riding;
  for (const [k, v] of at) {
    const was = from?.key === k ? from.y : m.at.get(k)?.y;
    if (was === undefined) {
      gen[k] = (gen[k] ?? 0) + 1;
      fly[k] = { top: riding ?? -Math.min(v.h, 40), fade: true };
      continue;
    }
    riding = was - v.y;
    if (riding === 0) continue;
    gen[k] = (gen[k] ?? 0) + 1;
    fly[k] = { top: riding };
  }
  const old = [...m.at.keys()];
  for (const x of exits) {
    const above = old.slice(0, old.indexOf(x.key)).reverse().find((k) => at.has(k));
    x.travel = above === undefined ? Math.min(x.h, 40) : -(fly[above]?.top ?? 0);
  }
  view.motion = { sig, at, gen, fly, exits, step, leaving: false };
  // A frame drawn where they were, then let go.
  cx.timer.after(16, (cx) => { if (view.motion.step !== step) return; view.motion.fly = {}; view.motion.leaving = true; cx.notify(); });
  cx.timer.after(MOTION.duration + 50, (cx) => { if (view.motion.step !== step) return; view.motion.exits = []; cx.notify(); });
}

// A row in its wrapper, which flies.
export function flying(view, key, child) {
  const f = view.motion.fly[key];
  return div().id(`fly-${key}-${view.motion.gen[key] ?? 0}`).flex_none().relative()
    .top(f?.top ?? 0).opacity(f?.fade ? 0 : 1).transition("top", MOTION).transition("opacity", MOTION)
    .child(child);
}

// The rows that left, for a relative() parent the rows fill: inert where they were, fading out. A row gone with too much of its state just goes.
export function leavingRows(view) {
  const away = view.motion.leaving;
  return view.motion.exits.filter((x) => x.ghost).flatMap((x) => {
    try {
      return [div().id(`leaving-${x.key}-${view.motion.step}`).absolute().left(0).right(0).top(x.y + (away ? x.travel : 0))
        .opacity(away ? 0 : 1).transition("top", MOTION).transition("opacity", MOTION).child(x.ghost())];
    } catch { return []; }
  });
}
