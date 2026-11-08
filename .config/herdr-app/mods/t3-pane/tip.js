// A hover label as T3's (its ui/tooltip.tsx): small and dark, the label with its key, and under it a dim hint if there is one.
// `.tooltip()` takes only a string, in the shell's own style, hence this. scripts/sync.sh copies this to the mods that use it.
import { div } from "gpui-kit";
import { v_flex, Popup } from "gpui-base";
import { keys, window } from "herdr";

// An action's key as the new menu writes it: ⇧⌘O. Read from the bindings, so a rebound key says so.
export function keyOf(action) {
  const k = keys().find(b => b.action === action);
  if (!k?.keys.trim()) return "";
  const mac = window()?.platform === "macos";
  const names = mac ? { ctrl: "⌃", alt: "⌥", shift: "⇧", cmd: "⌘", fn: "fn" } : { ctrl: "Ctrl", alt: "Alt", shift: "Shift", cmd: "Super", fn: "Fn" };
  const alias = { secondary: mac ? "cmd" : "ctrl", super: "cmd", win: "cmd" };
  return k.keys.trim().split(/\s+/).map(stroke => {
    const parts = stroke.split("-");
    let key = parts.pop();
    if (key === "") { key = "-"; parts.pop(); }
    const held = new Set(parts.map(m => alias[m.toLowerCase()] ?? m.toLowerCase()));
    if (/^[A-Z]$/.test(key)) held.add("shift");
    const label = key.length === 1 ? key.toUpperCase() : key[0].toUpperCase() + key.slice(1).toLowerCase();
    return [...Object.keys(names).filter(m => held.has(m)).map(m => names[m]), label].join(mac ? "" : "+");
  }).join(" ");
}

// Herdr drops a leave while the pointer's last known place is in the element's last box (should_dispatch_hover), and GPUI has by then marked it left,
// so none comes after: the pointer leaving the window, a key press or a press dragged out strand a hover. So what shows on hover also watches where the
// pointer is. No box yet, as for what slid under a still pointer: its moving from `from`, where it was then, means off, as a move still on it would have
// reported a box first; with no `from`, no word either way. macOS sends a window, active or not, no moves once the pointer is out, and its last place
// stays put: one whose last step, twice over, crosses the window's edge has left. shortcut: a pointer stopped dead just short of an edge after a fast
// step counts as gone; drop all this if Herdr's filter goes. shortcut: a window coming up over an inactive Herdr crosses no edge, so a hover under it
// stays until the pointer's next move here; nothing a mod hears can say more.
export const POINTER_WATCH = 100;
export const pointerAt = () => globalThis.window.mouse_position?.();
const track = { at: null, step: { x: 0, y: 0 } };
export function pointerMoved(p) {
  if (!p) return;
  if (track.at) track.step = { x: p.x - track.at.x, y: p.y - track.at.y };
  track.at = p;
}
export function pointerGone(box, from) {
  const p = pointerAt(), size = globalThis.window.viewport_size?.();
  if (p && size && track.at?.x === p.x && track.at.y === p.y) {
    const x = p.x + 2 * track.step.x, y = p.y + 2 * track.step.y;
    if (x < 0 || y < 0 || x >= size.width || y >= size.height) return true;
  }
  if (!box) return Boolean(p && from) && (p.x !== from.x || p.y !== from.y);
  return Boolean(p) && !(p.x >= box.x && p.x < box.x + box.width && p.y >= box.y && p.y < box.y + box.height);
}

// A drag has a release to wait for, and one out of an inactive window's sight never comes.
export const dragGone = (box) => window()?.active === false || pointerGone(box);

// The label fades and slides 4px off its control, in and out: T3's also scales, which Herdr can't. A transition adopts the first value it sees,
// so it draws clear until laid out. A new id per opening: a size reports only the first time an id is laid out.
// A Popup, as a HoverCard stays open under the pointer and a popup blocks what it covers even when clear: one fading out would leave a dead patch.
const tips = new Map(), FADE = { duration: 150, easing: "ease-out" };
let opened = 0;

function dropTip(id, s) {
  s.timer?.cancel();
  s.watch?.cancel();
  if (tips.get(id) === s) tips.delete(id);
}

function leaveTip(id, s, cx) {
  s.timer?.cancel();
  s.watch?.cancel();
  if (!s.open) return dropTip(id, s);
  s.closing = true;
  s.timer = cx.timer.after(FADE.duration, (cx) => { dropTip(id, s); cx.notify(); });
}

// Above, as T3's. `below` for what has no room up there: a Popup doesn't flip as T3's does, it is pushed back over its trigger.
// `off`: not lit whatever the pointer's on, as under the control's own menu.
export function tip(view, t, id, label, trigger, { action, hint, below, delay = 150, off } = {}) {
  const key = action ? keyOf(action) : "", hot = off ? null : view.hot, s = tips.get(id), shown = hot === id && s?.drawn;
  const watch = (s, cx) => {
    s.watch = cx.timer.every(POINTER_WATCH, (cx) => {
      if (!pointerGone(s.box, s.from)) return;
      if (view.hot === id) view.hot = null;
      leaveTip(id, s, cx);
      cx.notify();
    });
  };
  const hover = (on, cx) => {
    const was = tips.get(id);
    if (!on) return was && leaveTip(id, was, cx);
    if (was?.closing) {
      was.timer.cancel();
      was.closing = false;
      return watch(was, cx);
    }
    if (was) dropTip(id, was);
    const next = { n: ++opened, from: pointerAt() };
    tips.set(id, next);
    next.timer = cx.timer.after(delay, (cx) => { next.open = true; cx.notify(); });
    watch(next, cx);
  };
  return Popup.new(`tip-${id}`, div().id(`tip-over-${id}`).on_hover(hover).on_mouse_move((e) => { pointerMoved(e.position); const at = tips.get(id); if (at) at.box = e.bounds; }).child(trigger)).anchor(below ? "top_center" : "bottom_center")
    // While lit or leaving: a dialog opened from the button covers it, nothing reports the leaving until the pointer moves, and the label would stay up over it.
    .when(Boolean(s?.open && (hot === id || s.closing)), pop => pop.content(v_flex().id(`tip-body-${id}-${s.n}`)
      .opacity(shown ? 1 : 0).top(shown ? 0 : below ? -4 : 4).transition("opacity", FADE).transition("top", FADE)
      .on_size_change((_size, cx) => { if (tips.get(id) !== s || s.drawn) return; s.drawn = true; cx.notify(); }).when(below, el => el.mt(4)).when(!below, el => el.mb(4)).max_w(320).px(8).py(4).gap(2).rounded(6).border(1).border_color(t.border).bg(t.chrome).shadow_md().text_size(12).line_height(1.375).text_color(t.foreground)
      .child(div().child(key ? `${label} (${key})` : label))
      .when(Boolean(hint), el => el.child(div().text_color(t.muted).child(hint)))));
}

// A button's icon and text brighten together: a hover style reaches the text but not the svg, so it's state.
export const glow = (view, id) => (on, cx) => {
  if (on) view.hot = id;
  else if (view.hot === id) view.hot = null;
  cx.notify();
};

// A hover kept in view[key], for what has no label or card to go with the pointer: it goes even when its leave never comes.
export function hoverKept(view, key, id, el) {
  return el.on_hover((on, cx) => {
    if (on) {
      view[key] = id;
      view.keptBox = null;
      view.keptWatch?.cancel();
      const from = pointerAt();
      view.keptWatch = cx.timer.every(POINTER_WATCH, (cx) => {
        if (view[key] === id && !pointerGone(view.keptBox, from)) return;
        view.keptWatch.cancel();
        if (view[key] === id) { view[key] = null; cx.notify(); }
      });
    } else if (view[key] === id) view[key] = null;
    cx.notify();
  }).on_mouse_move((e) => { pointerMoved(e.position); if (view[key] === id) view.keptBox = e.bounds; });
}

// A mark with no words of its own (a status, a machine) says what it is on hover too, lit only to show its label.
export function tipMark(view, t, id, label, mark, options) {
  if (!label) return mark;
  const lit = div().id(id).flex_none().on_hover(glow(view, id)).child(mark);
  return tip(view, t, id, label, lit, options);
}
