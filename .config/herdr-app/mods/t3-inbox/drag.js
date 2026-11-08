import { div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { focused, run, setShared, settings } from "herdr";
import { focusPane } from "./zoom.js";
import { dragGone, POINTER_WATCH, pointerMoved } from "./tip.js";
import { detailsAt, detailsFor } from "./details.js";
import { MOTION } from "./motion.js";
import { SLIM, CARD_GAP, LIST_TOP } from "./list-view.js";

export function inboxDrag(view, t, model, actions) {
  const { list, pins, pinned, put, out, busy, hidden, settledAt, working, newest, viewing, napUntil, wake, inView, busyRows, napRows } = model;
  const { settle, unsettle, repin, go } = actions;
  const zoom = Number(settings()?.zoom) || 1;
  // Dragging, as T3's sidebar does it (Sidebar.drag.ts, Sidebar.pointer.ts). Press a row and move 6px to lift it;
  // it follows the pointer up and down inside the list and says what letting go will do. While it's lifted, the
  // Pinned and Active labels open, and the list opens a gap the size of the destination's row where it will
  // land. Pinned keeps a hand-made order; Active and Settled keep their own, so the gap opens where that puts it.
  let d = view.drag;
  // A row that leaves the list (its agent ended, a filter) can't be dropped. Render can't run commands, so
  // `view.back` stays and the release (or Esc, or leaving) hands the keyboard back.
  if (d && !list.some((a) => a.address === d.from)) d = view.drag = null;
  const dragging = Boolean(d?.moved);
  const lifted = dragging ? list.find((a) => a.address === d.from) : null;
  const sectionOf = (a) => hidden(a) ? "snoozed" : pins.includes(a.address) ? "pinned" : settledAt(a) ? "settled" : working(a) ? "working" : "active";
  const from = lifted ? sectionOf(lifted) : null;
  const fromShelf = from === "settled" || from === "snoozed";
  const others = (xs) => xs.filter((x) => x.address !== d?.from);
  const pinTo = (before) => ({ section: "pinned", before: before ?? null });
  const pinOrder = (before) => {
    const kept = pins.filter((p) => p !== d.from), at = before ? kept.indexOf(before) : -1;
    kept.splice(at < 0 ? kept.length : at, 0, d.from);
    return kept;
  };
  // What letting go would do, and the gap that shows it: above a row (its address), after a section's last row
  // (`end-…`), right under an empty section's label (`head-…`), or none (a folded or busy destination).
  const plan = (() => {
    const to = lifted && d.target;
    if (!to || (to.section === from && from !== "pinned")) return null;
    if (to.section === "pinned") {
      const order = pinOrder(to.before);
      if (from === "pinned" && order.join("\n") === pins.join("\n")) return null;
      return { section: "pinned", order, gap: to.before ?? (others(pinned).length ? "end-pinned" : "head-pinned") };
    }
    // Busy work can't be settled (new work brings it straight back); out of Pinned it joins the Working shelf.
    if (busy(lifted)) return to.section === "settled" ? null : { section: "active", gap: null };
    if (to.section === "settled") return { section: "settled", gap: !view.open ? null : others(put)[0]?.address ?? "head-settled" };
    const rest = others(out), at = from === "settled" ? 0 : rest.filter((x) => newest(x, lifted) < 0).length;
    return { section: "active", gap: !rest.length ? "head-active" : rest[at]?.address ?? "end-active" };
  })();
  const target = dragging ? d.target?.section ?? null : null;
  // A section lights up as the target, as T3's labels and shelf header do.
  const hot = (s) => target === s && (Boolean(plan) || s === from);
  const verb = !plan ? null : plan.section === "pinned" ? (from === "pinned" ? null : "pin")
    : plan.section === "settled" ? "settle" : from === "pinned" ? "unpin" : from === "settled" ? "unsettle" : from === "snoozed" ? "wake" : null;
  const BADGE = { pin: ["mods/t3-inbox/icons/pin.svg", "Pin"], unpin: ["mods/t3-inbox/icons/pin-off.svg", "Unpin"],
    settle: ["mods/t3-inbox/icons/circle-check.svg", "Settle"], unsettle: ["mods/t3-inbox/icons/undo.svg", "Un-settle"], wake: ["mods/t3-inbox/icons/alarm-clock-off.svg", "Wake"] };
  const badge = (v) => h_flex().id(`badge-${v}`).h(20).px(6).gap(4).flex_none().items_center().rounded(4)
    .border(1).border_color(t.accent + "66").bg(t.accent + "1a").text_size(11).font_medium().text_color(t.accent)
    .child(svg(BADGE[v][0]).size(12).flex_none().text_color(t.accent)).child(BADGE[v][1]);

  // Settled shows one page; while a drag moves a row out of it the next row fills in, and one settled into
  // it pushes the page's last row out of sight.
  const fromPage = from === "settled" && put.indexOf(lifted) < view.limit;
  const size = view.limit + (fromPage && plan ? 1 : 0) - (plan?.section === "settled" && from !== "settled" ? 1 : 0);
  const page = view.open ? put.slice(0, size) : [];
  const rows = [...page, ...put.filter((a) => viewing(a) && !page.includes(a))];
  // What the next and previous keys walk (t3-chrome): the rows drawn, in order, and the one in view. Written only when
  // it changes: every write redraws every mod.
  const drawn = { order: [...pinned, ...out, ...busyRows, ...napRows, ...rows].map((a) => a.address), view: inView };

  const aim = (to, cx) => {
    if (!view.drag?.moved || JSON.stringify(view.drag.target ?? null) === JSON.stringify(to)) return;
    view.drag.target = to;
    cx.notify();
  };
  // Over a pin, the upper half drops above it and the lower half below.
  const pinNear = (a, upper) => {
    const xs = pinned.map((x) => x.address), i = xs.indexOf(a.address);
    return pinTo(xs.slice(upper && a.address !== d?.from ? i : i + 1).find((x) => x !== d?.from));
  };
  // The gap: a card and the list's spacing in Pinned and Active, a slim row in Settled.
  const cardH = lifted && !fromShelf ? d.height : view.cardH ?? 78;
  const gap = (key) => div().id(`gap-${key}`).flex_none().h(plan?.gap !== key ? 0 : plan.section === "settled" ? SLIM : cardH + CARD_GAP)
    .when(dragging, (el) => el.transition("height", MOTION));
  // Each droppable row sits in a lane: the gap that opens above it, the row (folding away once the lifted one is
  // headed elsewhere, holding its place until then) with the list's spacing, and after the last, the end gap.
  const lane = (section, xs, draw, spacing, fly) => xs.map((a, i) => v_flex().id(`lane-${a.address}`).flex_none()
    .child(gap(a.address))
    .child(v_flex().id(`hold-${a.address}`).flex_none()
      .when(dragging && d.from === a.address, (el) => el.overflow_hidden().opacity(0).h(plan ? 0 : d.height + spacing).transition("height", MOTION))
      .child(fly(a.address, section === "settled" || section === "snoozed" ? "slim" : "card", draw(a))).when(spacing > 0, (el) => el.child(div().h(spacing).flex_none())))
    .when(i === xs.length - 1, (el) => el.child(gap(`end-${section}`))));
  // T3's boundaries: Pinned and Active labels, shown only while dragging; the list opens room for them.
  const boundary = (id, text, section, to) => h_flex().id(id).flex_none().overflow_hidden().h(dragging ? 24 : 0)
    .transition("height", MOTION).px(10).gap(8).items_center().text_size(12).font_medium()
    .on_mouse_move((_e, cx) => aim(to, cx))
    .when(dragging, (el) => el.child(div().text_color(hot(section) ? t.accent : t.muted).child(text))
      .child(div().flex_1().h(1).bg(hot(section) ? t.accent + "80" : t.border)));
  // An empty section still takes a drop: T3's dashed placeholder, accent while it's the target.
  const placeholder = (section, text) => div().id(`${section}-placeholder`).h(36).mx(2).mb(CARD_GAP).flex_none().flex().items_center().justify_center()
    .rounded(6).border(1).border_dashed().text_size(12)
    .border_color(hot(section) ? t.accent + "66" : t.border).text_color(hot(section) ? t.accent : t.muted)
    .when(hot(section), (el) => el.bg(t.accent + "0d"))
    .on_mouse_move((_e, cx) => aim({ section }, cx))
    .child(text);
  // Picked up anywhere on a row that can move (not Working, not one whose change is still on its way). The clock's
  // Popover hears its own press, so the row just leaves it alone.
  const row = (el, a, details) => el.relative()
    // Up from the hover on: a Popup must have measured its anchor before the frame a card starts to fade in.
    .when([view.hovered, view.details, view.detailsOut].includes(a.address), (r) => r.child(details(a)))
    .on_mouse_down("left", (e) => {
      if (a.mod || sectionOf(a) === "working" || view.pending.settled[a.address] !== undefined || view.pending.snoozed[a.address] !== undefined || view.hot === `snooze-${a.address}`) return;
      view.drag = { from: a.address, at: e.position, grab: (e.local_position?.y ?? 0) / zoom, height: (e.bounds?.height ?? 0) / zoom, moved: false, target: null };
    })
    .on_mouse_move((e, cx) => {
      // Lifted, the root tracks the pointer: a second report of one place would read as having stopped.
      if (!view.drag?.moved && !view.sweep?.moved) detailsAt(view, a.address, e);
      if (view.sweep?.moved) return sweepTo(a, cx);
      const s = sectionOf(a);
      // Nothing lands in Snoozed: a drop can't say when it wakes, as T3's.
      aim(s === "pinned" ? pinNear(a, (e.local_position?.y ?? 0) < (e.bounds?.height ?? 0) / 2) : s === "working" || s === "snoozed" ? null : { section: s }, cx);
    });
  // A drag's or sweep's release doesn't also click the row or button it ends on.
  const justDropped = () => view.drag?.moved || view.sweep?.moved || Date.now() - (view.dropped ?? 0) < 250;
  const open = (a) => (_e, cx) => {
    if (justDropped() || view.hot === `snooze-${a.address}`) return;
    go(a);
    // As a T3 tooltip, a click takes its card down until the pointer comes back.
    detailsFor(view, null, cx);
    cx.notify();
  };
  // Says whether it moved on to another agent.
  const drop = (cx) => {
    if (!plan) return false;
    const a = lifted;
    if (plan.section === "settled") return settle([a], cx);
    if (plan.section === "pinned") setShared("agents.pins", plan.order);
    // Out of Snoozed it's a Wake, which keeps the pin.
    else if (pins.includes(a.address) && from !== "snoozed") {
      const before = [...pins];
      setShared("agents.pins", pins.filter((p) => p !== a.address));
      view.remember("Unpinned", 1, () => repin(before, [a.address]), cx);
    }
    if (settledAt(a)) unsettle(a, cx);
    if (napUntil(a)) wake(a, cx);
    return false;
  };

  // Sweep, T3's other drag: press a card's Settle (or a settled row's undo) and move across rows to take the
  // whole run along; letting go settles (or brings back) every row it marked.
  const sweepFrom = (action, a) => (e, cx) => {
    cx.stop_propagation();
    view.sweep = { action, origin: a.address, at: e.position, moved: false, keys: [a.address] };
  };
  // Within the section it started in, as T3's.
  const sweepList = () => view.sweep.action === "settle" ? (pins.includes(view.sweep.origin) ? pinned : out).filter((x) => !busy(x) && !x.mod) : view.sweep.action === "unsnooze" ? napRows : rows;
  const sweepTo = (a, cx) => {
    const xs = sweepList().map((x) => x.address), i = xs.indexOf(view.sweep.origin), j = xs.indexOf(a.address);
    if (i < 0 || j < 0) return;
    const keys = xs.slice(Math.min(i, j), Math.max(i, j) + 1);
    if (keys.join("\n") === view.sweep.keys.join("\n")) return;
    view.sweep.keys = keys;
    cx.notify();
  };
  const swept = (a) => Boolean(view.sweep?.moved && view.sweep.keys.includes(a.address));
  const finish = (cx) => {
    if (!view.drag && !view.sweep && !view.back) return;
    const moved = (dragging && drop(cx)) || (Boolean(view.sweep?.moved) && applySweep(cx));
    if (dragging) view.landed = { key: d.from, y: ghostTop() - TOP };
    if (dragging || view.sweep?.moved) view.dropped = Date.now();
    endDrag(!moved);
  };
  const applySweep = (cx) => {
    const xs = sweepList().filter((x) => view.sweep.keys.includes(x.address));
    if (view.sweep.action === "settle") return settle(xs, cx);
    for (const a of xs) view.sweep.action === "unsnooze" ? wake(a, cx) : unsettle(a, cx);
    return false;
  };

  const TOP = 48; // The top row above the list.
  const ghostTop = () => Math.max(TOP + LIST_TOP + 24, Math.min(d.y - d.grab, (view.height ?? Infinity) - d.height - 8));
  // Ends a drag or sweep, and hands the keyboard back to the pane that had it, unless the drop moved on to
  // another agent. Not FocusHandle.release(): that frees the handle, and the next drag would throw.
  // `view.back` is set only once something lifted.
  function endDrag(restore = true) {
    const back = restore ? view.back : null;
    view.drag = view.sweep = view.back = null;
    if (back?.pane) focusPane(back.pane);
    else if (back?.terminal) run("pane.focus", { terminal: back.terminal });
    return null;
  }

  // Its leave can get lost (see pointerGone), and the release out there is never reported: this says it left.
  function watchDrag(cx) {
    view.dragWatch?.cancel();
    view.dragWatch = cx.timer.every(POINTER_WATCH, (cx) => {
      if (!(view.drag || view.sweep || view.back)) view.dragWatch.cancel();
      else if (dragGone(view.dragBox)) view.leftSidebar(cx);
    });
  }

  // Herdr reports no release outside the sidebar, so leaving decides. Off the top or bottom edge (the Pinned
  // label or the Settled shelf sit there) it lands where the badge says, as T3 keeps the last target past the
  // list's ends; off a side it goes back.
  view.leftSidebar = (cx) => {
    if (!(view.drag || view.sweep || view.back)) return;
    const p = (view.drag ?? view.sweep)?.last, w = view.width ?? Infinity, h = view.height ?? Infinity;
    const side = !p || Math.min(p.x, w - p.x) < Math.min(p.y, h - p.y);
    if (side) endDrag(); else finish(cx);
    cx.notify();
  };

  const root = (el) => el
    // Esc puts a lifted row back (the sidebar holds the keyboard only while something is lifted).
    .track_focus(view.keys).on_key_down((e, cx) => {
      if (e.keystroke !== "escape" || !(view.drag || view.sweep || view.back)) return;
      endDrag();
      cx.notify();
    })
    .on_mouse_move((e, cx) => {
      const g = view.drag ?? view.sweep;
      if (!g || (!g.moved && Math.hypot(e.position.x - g.at.x, e.position.y - g.at.y) <= 6)) return;
      if (!g.moved) { view.back = focused(); view.keys.focus(); watchDrag(cx); }
      else pointerMoved(e.position);
      g.moved = true;
      view.dragBox = e.bounds;
      g.last = e.local_position ? { x: e.local_position.x / zoom, y: e.local_position.y / zoom } : g.last;
      if (view.drag) view.drag.y = g.last?.y ?? view.drag.y;
      cx.notify();
    })
    // Released anywhere in the sidebar, it lands where the gap shows.
    .on_mouse_up("left", (_e, cx) => { finish(cx); cx.notify(); })
    .on_hover((on, cx) => { if (!on) view.leftSidebar(cx); });

  // The lifted row moves only up and down, inside the list and below the Pinned label (T3's clamps).
  const ghost = (draw) => {
    return !lifted || d.y == null ? null : div().id("drag-ghost").absolute().left(8).right(8)
      .top(ghostTop())
      .rounded(6).bg(t.selected).shadow_lg()
      .child(fromShelf ? draw.slim(lifted, true) : draw.card(lifted, true));
  };

  return { d, dragging, lifted, plan, cardH, rows, drawn, hot, verb, badge, others, pinTo, aim, gap, lane, boundary, placeholder, row, open, justDropped, sweepFrom, swept, root, ghost };
}
