// A thing's details as T3's thread card, with its timing: for Inbox rows and tabs. scripts/sync.sh copies this to the mods that use it.
import { div, image, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { POINTER_WATCH, pointerAt, pointerGone, pointerMoved } from "./tip.js";

// The program's icon from the app's table: a one-color glyph or a picture.
export function programIcon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

// As T3's tooltip group: while a card is up, or was under 400ms ago, the next opens at once.
export const detailsLive = (view) => Boolean(view.details) || Date.now() - (view.detailsClosed ?? 0) < 400;

function fadeOut(view, key, cx) {
  view.detailsFade?.cancel();
  view.detailsOut = key;
  view.detailsFade = cx.timer.after(150, (cx) => {
    view.detailsOut = null;
    cx.notify();
  });
}

// A row's box, from its on_mouse_move, for the watch below.
export const detailsAt = (view, key, e) => { pointerMoved(e.position); view.detailsBox = { key, box: e.bounds }; };

// What a row's hover shows goes with the pointer, even when its leave never comes: see pointerGone.
export function detailsWatch(view, key, cx) {
  view.detailsWatch?.cancel();
  const stop = () => { view.detailsWatch.cancel(); view.detailsWatch = null; };
  // What slid under a still pointer has no box until a move: see pointerGone.
  const from = pointerAt();
  view.detailsWatch = cx.timer.every(POINTER_WATCH, (cx) => {
    if (![view.hovered, view.overTab, view.details].includes(key) && !view.detailsWait) return stop();
    if (!pointerGone(view.detailsBox?.key === key ? view.detailsBox.box : null, from)) return;
    stop();
    if (view.hovered === key) view.hovered = null;
    if (view.overTab === key) view.overTab = null;
    view.hot = null; // A control in the row can't still be lit: a lit one hides the card and takes the row's clicks.
    detailsFor(view, null, cx);
    cx.notify();
  });
}

// 150ms to the first card, which fades in. What opens at once does so unfaded, as T3's, while what it replaces fades out.
// A transition adopts the first value it sees, so a card draws clear for a frame or two before its target changes.
export function detailsFor(view, key, cx) {
  if (!key) view.detailsHold = null;
  view.detailsWait?.cancel();
  view.detailsWait = null;
  if (key) detailsWatch(view, key, cx);
  // Already closed by a press, the pointer's leaving mustn't stop the card's fade, or it stays up unseen.
  if (!key && !view.details) return;
  if (!key) {
    view.detailsClosed = Date.now();
    fadeOut(view, view.details, cx);
    view.details = null;
    return;
  }
  const live = detailsLive(view);
  if (view.detailsOut === key) {
    view.detailsFade?.cancel();
    view.detailsOut = null;
  }
  if (live) {
    if (view.details && view.details !== key) fadeOut(view, view.details, cx);
    view.details = key;
    view.detailsIn = true;
    return;
  }
  view.detailsWait = cx.timer.after(150, (cx) => {
    view.details = key;
    view.detailsIn = false;
    cx.notify();
    view.detailsWait = cx.timer.after(34, (cx) => {
      view.detailsWait = null;
      view.detailsIn = true;
      cx.notify();
    });
  });
}

export const detailsLine = (t, mark, text) => h_flex().gap(8).min_w(0).items_center().child(mark).child(div().min_w(0).truncate().text_color(t.foreground + "bf").child(text));

// The title, then its lines. The caller hangs it from a Popup and gives it its gap from what it describes.
// `wrap`: the title runs on over lines, for one the row it describes can't show whole (a commit's subject). `hide`: fades out and stays up, to come back.
// `from`: where it slides from, 4px toward the row: T3's scales, which Herdr can't.
const detailsFade = { duration: 150, easing: "ease-out" };
export function detailsCard(view, t, key, title, lines, { wrap, hide, from = -4 } = {}) {
  const shown = view.details === key && view.detailsIn && !hide;
  return v_flex().id(`details-card-${key}`).max_w(320).p(12).gap(8).rounded(6).border(1).border_color(t.border)
    // Solid: T3's glass blurs what's behind it, which a mod can't, and a terminal's text would show through.
    .bg(t.chrome).shadow_xl().text_size(12).line_height("16px").opacity(shown ? 1 : 0).left(shown ? 0 : from).transition("opacity", detailsFade).transition("left", detailsFade)
    .child(div().min_w(0).when(!wrap, el => el.truncate()).line_height(1.25).font_medium().text_color(t.foreground).child(title))
    .child(v_flex().pl(2).gap(6).children(lines.filter(Boolean)));
}
