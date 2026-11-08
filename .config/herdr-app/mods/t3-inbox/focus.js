// Keyboard focus as T3's focus-visible: Tab walks the controls, and what it's on wears a 2px inset ring. The kit has neither a
// focus_visible builder nor a way to read the input modality, so this keeps both. scripts/sync.sh copies this to the mods that use it.
// A control tracking a handle takes the keyboard from the terminal when pressed, and the kit can't prevent that, so outside
// an overlay the window's controls are tab stops only in keyboard mode: pane.go onto a sidebar mod ("focus") starts it, the
// keyboard leaving every stop ends it. A terminal keeps Tab, so nothing else starts it, and with the mode off nothing here listens.
import { div } from "gpui-kit";
import { shared, setShared } from "herdr";

const MODE = "t3-focus";
// A handle can't be made in render (the kit throws), and rows appear there.
const POOL = 64;
// Tab is the shell's action: a mod hears only its release, and only where it landed. Leaving by anything else, nobody tells it.
const TICK = 150;
// Long enough for the mod Tab landed in to take over before the one it left gives up the mode.
const LOST_TICKS = 3;

// kind: "modal" for an overlay's copy, whose stops are always up: nothing's behind it to press.
export function stopsInit(view, cx, kind) {
  view.fs = { handles: new Map(), free: Array.from({ length: POOL }, () => cx.focus_handle()), modal: kind === "modal", me: String(Math.random()), keyboard: false, watch: null, last: null, hold: null };
  // Mods share one JS context, so the run's first copy knows nothing can be live yet: what's in shared state is a crash's.
  if (!globalThis.t3FocusRun) { globalThis.t3FocusRun = true; if (shared(MODE)) setShared(MODE, null); }
}

// For every copy's close: its watch goes with it (a pane's ×, another layout, a quit), and nothing else ends the mode.
export function stopsEnd(view) {
  if (view.fs && shared(MODE) === view.fs.me) setShared(MODE, null);
}

function handleOf(s, id) {
  let h = s.handles.get(id);
  if (!h && s.free.length) { h = s.free.pop(); s.handles.set(id, h); }
  return h;
}

// The stop holding the keyboard, while the keyboard's walking.
export function onStop(view) {
  const s = view.fs;
  if (!s?.keyboard) return null;
  for (const [id, h] of s.handles) if (h.is_focused()) return id;
  return null;
}

// T3's group-focus-within: what a row shows hovered it shows with the keyboard on it or inside it.
export const within = (view, ids) => ids.includes(onStop(view));

function watch(view, cx) {
  const s = view.fs;
  if (s.watch) return;
  let lost = 0, seen = onStop(view);
  s.watch = cx.timer.every(TICK, (cx) => {
    const id = onStop(view);
    if (id !== seen) { seen = id; cx.notify(); }
    if (id || s.hold?.()) { lost = 0; s.last = id ?? s.last; return; }
    if (++lost < LOST_TICKS) return;
    s.watch.cancel();
    s.watch = null;
    s.keyboard = false;
    if (shared(MODE) === s.me) setShared(MODE, null);
    cx.notify();
  });
}

// pane.go landed here: onto the stop it left, else `first`, which is always drawn. Once only: a stop gone from the list loses
// the keyboard, and Herdr would hand it back here for another try.
export function enter(view, cx, first) {
  const s = view.fs, h = handleOf(s, s.last ?? first);
  s.last = null;
  s.keyboard = true;
  setShared(MODE, s.me);
  h?.focus();
  watch(view, cx);
  cx.notify();
}

// A popup's button toggles it. The press that brings the click is a press outside it too, which already closed it, so the click
// mustn't reopen it. The button calls pressed on its press and justClosed on its click, naming the shared key the popup's close()
// stamps. 50 ms, for a close reported just before the press. No press (the keyboard, assistive tech), nothing to tell.
export const pressed = (view) => { view.pressAt = Date.now(); };
export function justClosed(view, key) {
  const closing = view.pressAt != null && (shared(key) ?? 0) >= view.pressAt - 50;
  view.pressAt = null;
  return closing;
}

// The mod's root: hears Tab land here and a press end the ring, and takes back the handles when the mode ends.
export function focusRoot(view, el) {
  const s = view.fs;
  if (!s.modal && !shared(MODE)) {
    s.free.push(...s.handles.values());
    s.handles.clear();
    return el;
  }
  return el
    .on_key_up((e, cx) => {
      if (e.key !== "tab") return;
      s.keyboard = true;
      const id = onStop(view);
      if (!id) { s.keyboard = false; return; }
      s.last = id;
      while (s.free.length < POOL / 4) s.free.push(cx.focus_handle());
      if (!s.modal) setShared(MODE, s.me);
      watch(view, cx);
      cx.notify();
    })
    .on_mouse_down("left", (_e, cx) => { s.keyboard = false; cx.notify(); });
}

// Makes `el` a tab stop with T3's ring (focus-visible:ring-2 ring-inset ring-ring: its ring is the primary, here `accent`), drawn
// over it so nothing moves. As T3's rows, every stop is in the Tab order: no roving. Call it last: the ring goes over the children.
// Enter and Space click what has on_click; `enter` is for a row that goes by its mouse-up. `handle`: a stop that has its own.
export function stop(view, t, id, el, radius = 6, { enter: act, handle } = {}) {
  const s = view.fs;
  if (!s.modal && !shared(MODE)) return el;
  if (handle) s.handles.set(id, handle);
  // shortcut: past the pool a new row isn't a stop until Tab lands in this mod and tops it up, enough for any list seen so far.
  const h = handleOf(s, id);
  if (!h) return el;
  return el.track_focus(h).tab_index(0)
    // Runs before the press takes the keyboard. No walk in this copy: the mode's another's or left over, and a press ends it, as
    // focus-visible's does. Next frame this isn't a stop, and Herdr hands the keyboard back.
    .when(!s.modal, (e) => e.on_mouse_down("left", () => { if (!s.watch) setShared(MODE, null); }))
    .when(Boolean(act), (e) => e.on_key_down((k, cx) => {
      // A control inside it shares its focus path: that's the control's key.
      if ((k.keystroke !== "enter" && k.keystroke !== "space") || !h.is_focused()) return;
      cx.stop_propagation();
      act();
      cx.notify();
    }))
    .when(s.keyboard && h.is_focused(), (e) => e.relative().child(div().absolute().inset_0().rounded(radius).border(2).border_color(t.accent)));
}
