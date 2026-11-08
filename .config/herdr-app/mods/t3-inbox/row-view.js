import { div, svg } from "gpui-kit";
import { v_flex, h_flex, Popup } from "gpui-base";
import { settings } from "herdr";
import { namer } from "./name.js";
import { projectMark } from "./project.js";
import { glow, tip, tipMark } from "./tip.js";
import { MOTION } from "./motion.js";
import { programIcon, detailsLive, detailsFor, detailsLine, detailsCard } from "./details.js";
import { stop, within } from "./focus.js";
import { snoozeButton } from "./snooze.js";
import { SLIM } from "./list-view.js";

const icon = programIcon;

// As T3's sidebar times: no "ago", nothing past days.
function ago(ms, now) {
  const m = Math.floor((now - ms) / 60000);
  if (m < 1) return "just now";
  if (m < 60) return `${m}m`;
  if (m < 1440) return `${Math.floor(m / 60)}h`;
  return `${Math.floor(m / 1440)}d`;
}

// How long it's been working, as T3's Working pill: 9s, 4m, 1h 5m.
function took(ms, now) {
  const s = Math.max(0, Math.floor((now - ms) / 1000)), m = Math.floor(s / 60);
  return s < 60 ? `${s}s` : m < 60 ? `${m}m` : `${Math.floor(m / 60)}h ${m % 60}m`;
}

// Time left on a snooze, rounded up as T3's: 10m, 3h, 2d.
function left(ms, now) {
  const m = Math.max(1, Math.ceil((ms - now) / 60000));
  return m < 60 ? `${m}m` : m < 1440 ? `${Math.ceil(m / 60)}h` : `${Math.ceil(m / 1440)}d`;
}

export function inboxRowView(view, t, model, actions, drag) {
  const { now, ps, sp, state, viewing, kids, running, woke, busy, pins, started, since, wake, hidden, napUntil, settledAt } = model;
  const { settle, unsettle, away, pick } = actions;
  const { dragging, plan, verb, badge, swept, row, open, sweepFrom, justDropped } = drag;
  const zoom = Number(settings()?.zoom) || 1;
  const title = namer();
  const hover = (a) => (on, cx) => {
    if (on) { view.hovered = a.address; detailsFor(view, a.address, cx); }
    else if (view.hovered === a.address) { view.hovered = null; detailsFor(view, null, cx); }
    cx.notify();
  };
  // A button's icon and text brighten together: a hover style reaches the text but not the svg, so it's state.
  const lit = (id, color) => (view.hot === id ? t.foreground : color);
  // A space's mark, as t3-spaces draws it.
  const avatar = (id, name, size) => projectMark(sp.find((s) => s.id === id) ?? { name: name ?? "" }, size, t, ps);
  // A control's label in a row belongs to the same group as the row's card, so it too opens at once.
  const delay = detailsLive(view) ? 0 : 150;
  const machineOf = (a) => a.address.includes("/") ? a.address.split("/")[0] : null;
  const branchOf = (a) => ps.find((p) => p.pane === a.pane)?.branch;
  // A row's details, as T3's thread card: on the row's right from its top. A 1px anchor just outside its top right corner, as
  // a Popup hangs from its trigger's bottom left; clamped at the window's bottom the card slides up and still clears the row.
  // A control lit in the row speaks for itself instead, as T3's group lets one tooltip up at a time: the card fades, up clear until the pointer goes.
  // The whole corner holds it, so the gap between two controls doesn't flash it.
  const details = (a) => {
    const machine = machineOf(a), branch = branchOf(a), pic = icon(a.program, 12, t.muted);
    const up = view.details === a.address || view.detailsOut === a.address;
    return Popup.new(`details-${a.address}`, div()).absolute().top(-1).right(-1).size(1)
      .when(up && !view.napMenu && !dragging && !view.sweep?.moved, (pop) => pop.content(detailsCard(view, t, a.address, title(a), [
        a.space_name && detailsLine(t, avatar(a.space, a.space_name, 12), a.space_name),
        machine && detailsLine(t, svg("mods/t3-inbox/icons/server.svg").size(12).flex_none().text_color(t.muted), machine),
        branch && detailsLine(t, svg("mods/t3-inbox/icons/git-branch.svg").size(12).flex_none().text_color(t.muted), branch),
        pic && detailsLine(t, div().flex_none().opacity(0.6).child(pic), a.program.name),
      ], { hide: Boolean(view.hot) || view.detailsHold === a.address }).ml(4)));
  };

  // `ghost`: the copy that follows the pointer, drawn without handlers or ids the list already uses.
  const card = (a, ghost) => {
    const st = state(a), on = viewing(a);
    const machine = machineOf(a), branch = branchOf(a);
    const going = (kids.get(a.address) ?? []).filter((s) => s === "working").length;
    const meta = [branch, going ? `${going} sub-agent${going > 1 ? "s" : ""} working` : null].filter(Boolean).join(" · ");
    const pic = icon(a.program, 14, t.muted);
    // Snooze is offered for anything not needing the person, working too, as T3's. A failed turn counts as needing them
    // here, and a mod pane has no terminal to hold the label.
    const canNap = !ghost && !a.mod && st !== "blocked", menu = canNap && view.napMenu === a.address;
    // The pointer or keys going into its menu leave the card, but it stays as it was: the menu hangs from the clock, and
    // Settle going would pull the clock, and the menu with it, out from under the pointer.
    const over = !dragging && !view.sweep?.moved && (menu || view.hovered === a.address || within(view, [`card-${a.address}`, `settle-${a.address}`, `snooze-${a.address}`, `woke-${a.address}`]));
    // As T3's rows: what you're on or what wants you leads; the rest recede until hovered, in color only so nothing reflows.
    const leads = on || ghost || st === "blocked" || st === "done" || woke(a);
    const marks = machine || pic ? h_flex().gap(4).flex_none().items_center()
      // Another machine's agent, as in T3: a server mark before its program, the machine named on hover.
      .when(Boolean(machine), (el) => {
        const server = div().when(!ghost, (m) => m.id(`machine-${a.address}`).on_hover(glow(view, `machine-${a.address}`)).accessibility_label(`On ${machine}`))
          .flex_none().child(svg("mods/t3-inbox/icons/server.svg").size(14).text_color(t.dim));
        return el.child(ghost ? server : tip(view, t, `machine-${a.address}`, machine, server, { delay }));
      })
      .when(Boolean(pic), (el) => el.child(div().flex_none().opacity(0.6).child(pic))) : null;
    // Hovered, the corner offers Settle, but only for what's finished: a working or stuck tree stays in sight.
    const offer = over && !busy(a);
    const id = `settle-${a.address}`;
    const napOffer = canNap && over;
    // As in T3, the corner says the state when there's one worth saying (Working, Needs you, Done: finished
    // and not yet seen), else how long ago it last changed. Sized as T3's: 16px mark, 4px gaps, and the
    // time in monospace children, one per part, so spacing and width don't hang on the interface font and
    // a monospace space (a full cell) doesn't open "1h 5m" wider than the 4px gaps.
    const pill = (color, mark, label, time) => h_flex().id(`state-${a.address}`).h(20).gap(4).flex_none().items_center().font_medium().text_color(color)
      .child(mark).child(div().child(label))
      .when(Boolean(time), (el) => el.children(time.split(" ").map((part) => div().font_family(settings().font_family ?? "JetBrains Mono").child(part))));
    // It wakes where it was, so this carries the weight, as T3's; a click dismisses it, and it stays on hover.
    const wokeMark = woke(a) && tip(view, t, `woke-${a.address}`, "Dismiss Woke notification", stop(view, t, `woke-${a.address}`, h_flex().id(`woke-${a.address}`).h(20).gap(4).flex_none().items_center().font_medium().text_color(t.blocked)
      .hover((s) => s.underline()).on_hover(glow(view, `woke-${a.address}`)).role("button").accessibility_label("Dismiss Woke notification")
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => {
        cx.stop_propagation();
        view.hot = null; // It goes, before the pointer can report leaving it.
        wake(a, cx);
        cx.notify();
      })
      .child(svg("mods/t3-inbox/icons/alarm-clock.svg").size(16).flex_none().text_color(t.blocked)).child("Woke"), 4), { delay });
    const acting = offer || napOffer, quiet = acting && (menu || !woke(a));
    // Lifted, or marked by a sweep, the corner says what letting go will do instead.
    // The state or the time, faded out on hover where Settle fades in over it, as T3's corner.
    const word = running(a)
        ? pill(t.working, svg("mods/workspace-chrome/spinner.svg").size(16).flex_none().text_color(t.working).spin(900),
          "Working", started(a) > 0 && started(a) < Infinity ? took(started(a), now) : null)
        : st === "blocked"
          ? pill(t.blocked, div().size(16).flex_none().rounded(4).bg(t.blocked + "26").text_size(11).font_bold().flex().items_center().justify_center().child("!"), "Needs you")
          : wokeMark
            || (st === "done"
              ? pill(t.ansi2, svg("mods/t3-inbox/icons/circle-check.svg").size(16).flex_none().text_color(t.ansi2), "Done")
              : div().id(`state-${a.address}`).flex_none().child(since(a) > 0 ? ago(since(a), now) : ""));
    // Still at work when it wakes, it says both, as T3's row; hovered, Woke stays and Working makes way.
    const status = running(a) && wokeMark ? h_flex().gap(4).flex_none().items_center().when(!acting, (el) => el.child(word)).child(wokeMark) : word;
    // T3's align="end" with its flip: right edges together if the menu fits to the clock's left, else from the clock's left edge and out over the sidebar's. Popover only clamps, so the flip is here; no press (the keyboard), the flip.
    const clock = canNap && snoozeButton(view, t, a, { now, offer: napOffer, delay }, pick);
    const corner = ghost ? (verb ? badge(verb) : div())
      : swept(a) ? badge("settle")
      // As T3's corner: hovered, the controls take the slot and the state fades out from under them, but for Woke.
      : h_flex().id(`corner-${a.address}`).relative().h(20).min_w(32).gap(4).flex_none().items_center().justify_end()
        .when(acting, (el) => el.on_hover((on, cx) => { view.detailsHold = on ? a.address : null; cx.notify(); }))
        .child(div().flex_none().when(quiet, (el) => el.absolute().top(0).right(0)).opacity(quiet ? 0 : 1).transition("opacity", MOTION).child(status))
        .child(h_flex().id(`controls-${a.address}`).h(20).flex_none().items_center().when(!acting, (el) => el.absolute().top(0).right(0))
        .when(Boolean(clock), (el) => el.child(clock))
        .child(div().when(!offer, (el) => el.absolute().top(0).right(0)).child(tip(view, t, id, a.mod ? "Settle and close" : "Settle agent", h_flex().id(id).h(20).px(6).mr(-4).gap(4).flex_none().items_center().rounded(6)
        .text_size(12).text_color(lit(id, t.muted)).opacity(offer ? 1 : 0).transition("opacity", MOTION)
        // Faded out it's no button: a click there is the card's. As T3's row controls, hover only lights it: no ground.
        .when(offer, (el) => el.on_hover(glow(view, id)).role("button").accessibility_label(a.mod ? "Settle and close" : "Settle").when(!a.mod, (b) => b.on_mouse_down("left", sweepFrom("settle", a))).on_click((_e, cx) => {
          cx.stop_propagation();
          if (justDropped()) return;
          // A click is no sweep. Its release stops here, so the sidebar's mouse-up won't end the one the press began.
          view.sweep = null;
          settle([a], cx);
          cx.notify();
        }))
        .child(svg("mods/t3-inbox/icons/check.svg").size(14).flex_none().text_color(lit(id, t.muted)))
        .child("Settle")
        .when(offer, (el) => stop(view, t, id, el, 6)), { action: "t3-tabs.settle", delay }))));
    // T3's card row: 10 and 8 in, rounded-md, its lines 20, 20 and 16 tall, 4 and 2 apart: 78 with all three.
    const base = v_flex().id(`${ghost ? "ghost-" : ""}card-${a.address}`).px(10).py(8).flex_none().rounded(6)
      // A working row recedes until it's hovered or in view, as T3's.
      .when(!ghost, (el) => el.opacity(running(a) && !woke(a) && !on && !over ? 0.7 : 1).transition("opacity", MOTION));
    return (ghost ? base : row(base, a, details).role("button").accessibility_label(title(a)).on_hover(hover(a))
      .on_click(open(a)).on_size_change((size) => { view.cardH = size.height / zoom; }))
      .when(on, (el) => el.bg(t.selected))
      .when(!on && !ghost && !dragging && !view.sweep?.moved, (el) => el.when(menu, (m) => m.bg(t.hover)).hover((s) => s.bg(t.hover)).active((s) => s.bg(t.selected)))
      .child(h_flex().h(20).gap(6).items_center().text_size(12).text_color(t.dim)
        .child(avatar(a.space, a.space_name, 16))
        // Lifted, a pin keeps its glyph only while it stays among the pins.
        .when(pins.includes(a.address) && (!ghost || plan?.section === "pinned" || !plan), (el) => el.child(svg("mods/t3-inbox/icons/pin.svg").size(12).flex_none().text_color(t.dim)))
        .child(div().flex_1().min_w(0).truncate().child(a.space_name ?? ""))
        .child(corner))
      .child(h_flex().h(20).mt(4).gap(6).items_center()
        .child(div().flex_1().min_w(0).truncate().text_size(14).when(leads, (el) => el.font_medium())
          .text_color(leads || over || swept(a) ? t.foreground : t.muted).child(title(a)))
        // Marks go on the third line when there is one, as in T3, so the title keeps its whole line.
        .when(Boolean(marks) && !meta, (el) => el.child(marks)))
      .when(Boolean(meta), (el) => el.child(h_flex().h(16).mt(2).gap(6).items_center().text_size(12).text_color(t.dim)
        .child(div().flex_1().min_w(0).truncate().child(meta))
        .when(Boolean(marks), (m) => m.child(marks))))
      .when(!ghost, (el) => stop(view, t, `card-${a.address}`, el));
  };

  // A settled or snoozed row: one dim line; viewing it leaves it so. Hovered it brightens and its time becomes a
  // bare undo arrow, or for a snoozed one, which shows when it comes back, Wake's crossed-out alarm clock, as in T3.
  const slim = (a, ghost) => {
    const on = viewing(a), over = !dragging && !view.sweep?.moved && (view.hovered === a.address || within(view, [`slim-${a.address}`, `wake-${a.address}`, `unsettle-${a.address}`])), bright = on || over || ghost || swept(a);
    const napping = hidden(a), undoId = `${napping ? "wake" : "unsettle"}-${a.address}`, undoLabel = napping ? "Wake agent" : "Unsettle";
    // As T3's settled rows: its project's mark, not its program's.
    const mark = avatar(a.space, a.space_name, 16);
    const undo = h_flex().id(undoId).h(24).px(6).flex_none().items_center().justify_center().rounded(6)
      .opacity(over ? 1 : 0).transition("opacity", MOTION)
      // Faded out it's no button: a click there is the row's.
      .when(over, (el) => el.on_hover(glow(view, undoId)).role("button").accessibility_label(undoLabel)
        .on_mouse_down("left", sweepFrom(napping ? "unsnooze" : "unsettle", a)).on_click((_e, cx) => {
        cx.stop_propagation();
        if (justDropped()) return;
        view.sweep = null;
        away(a, cx);
        if (napping) wake(a, cx); else unsettle(a, cx);
        cx.notify();
      }))
      .child(svg(`mods/t3-inbox/icons/${napping ? "alarm-clock-off" : "undo"}.svg`).size(napping ? 12 : 14).mb(1).flex_none().text_color(lit(undoId, t.muted)))
      .when(over, (el) => stop(view, t, undoId, el, 6));
    const time = napping
      ? h_flex().gap(4).items_center().text_color(t.accent).child(svg("mods/t3-inbox/icons/alarm-clock.svg").size(12).flex_none().text_color(t.accent)).child(left(napUntil(a), now))
      : !ghost && ago(settledAt(a)[0], now);
    const base = h_flex().id(`${ghost ? "ghost-" : ""}slim-${a.address}`).h(SLIM).px(10).gap(10).flex_none().items_center().rounded(6);
    return (ghost ? base : row(base, a, details).role("button").accessibility_label(title(a)).on_hover(hover(a)).on_click(open(a)))
      .when(on, (el) => el.bg(t.selected))
      .when(!on && !ghost && !dragging && !view.sweep?.moved, (el) => el.hover((s) => s.bg(t.hover)).active((s) => s.bg(t.selected)))
      .child(h_flex().id(`slim-mark-${a.address}`).size(16).flex_none().items_center().justify_center().opacity(bright ? 1 : 0.4).transition("opacity", MOTION).child(ghost ? mark : tipMark(view, t, `slim-space-${a.address}`, a.space_name, mark, { delay })))
      .child(div().flex_1().min_w(0).truncate().when(on, (el) => el.font_medium()).text_color(bright ? t.foreground : t.muted).child(title(a)))
      .child(ghost ? (verb ? badge(verb) : div()) : swept(a) ? badge(view.sweep.action === "unsnooze" ? "wake" : "unsettle")
        // T3's corner: the time fades out on hover as the undo arrow fades in over it.
        : h_flex().id(`slim-corner-${a.address}`).relative().h(24).min_w(32).flex_none().items_center().justify_end()
          .child(div().flex_none().text_size(12).text_color(t.dim).opacity(over ? 0 : 1).transition("opacity", MOTION).child(time))
          .child(div().absolute().top(0).right(-4).child(tip(view, t, undoId, undoLabel, undo, { action: napping ? undefined : "t3-inbox.settle", delay }))))
      .when(!ghost, (el) => stop(view, t, `slim-${a.address}`, el));
  };


  return { card, slim };
}
