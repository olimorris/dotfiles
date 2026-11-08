import { div, svg } from "gpui-kit";
import { v_flex, h_flex, Popover, Popup, Select, InputState, Input, NumberInput } from "gpui-base";
import { run, theme, props, settings, closeOverlay } from "herdr";
import { stopsInit, stop, focusRoot, onStop } from "./focus.js";
import { menuJump } from "./list.js";
import { glow, tip } from "./tip.js";
import { MOTION } from "./motion.js";

// A custom snooze can be far off; its timer needn't be.
export const DAY = 86400000;
// Base UI's collision padding, and the Snooze menu's width. shortcut: the width is the presets' widest as drawn, not measured; measure it if presets become editable.
const NAP_MENU_MARGIN = 5, NAP_MENU_W = 180;

// T3's default snooze menu, in local time: soonest first, one row per wake minute, tonight's gone once it's past.
function presets(now) {
  const d = new Date(now), at = (days, h) => new Date(d.getFullYear(), d.getMonth(), d.getDate() + days, h).getTime();
  const time = (ms) => { const w = new Date(ms); return `${w.getHours() % 12 || 12}:${String(w.getMinutes()).padStart(2, "0")} ${w.getHours() < 12 ? "am" : "pm"}`; };
  const day = (ms) => `${["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][new Date(ms).getDay()]} ${time(ms)}`;
  const inFrom = (hours) => { const ms = now + hours * 3600000; return { label: `In ${hours} hour${hours === 1 ? "" : "s"}`, at: ms, hours, when: new Date(ms).getDate() === d.getDate() ? time(ms) : day(ms) }; };
  const monday = at((1 - d.getDay() + 7) % 7 || 7, 9);
  return [inFrom(1), inFrom(3), { label: "This evening", at: at(0, 18), when: time(at(0, 18)) }, { label: "Tomorrow", at: at(1, 9), when: time(at(1, 9)) }, { label: "Next week", at: monday, when: day(monday) }]
    .filter((p) => p.at > now).sort((x, y) => x.at - y.at)
    .filter((p, i, xs) => xs.findIndex((q) => Math.floor(q.at / 60000) === Math.floor(p.at / 60000)) === i);
}

// T3's Custom snooze: when a date and time or a duration wakes, or null for a time that doesn't exist or has passed.
function customWake({ mode, date, time, amount, unit }, now) {
  let at;
  if (mode === "duration") {
    const n = Number(amount);
    if (!(n > 0)) return null;
    at = now + n * { minutes: 60000, hours: 3600000, days: DAY }[unit];
  } else {
    const m = /^(\d{1,2}):(\d{2})$/.exec(time.trim());
    if (!m) return null;
    const w = new Date(date.getFullYear(), date.getMonth(), date.getDate(), Number(m[1]), Number(m[2]));
    // 25:00 rolls over, and a local time a clock change skips moves.
    if (w.getHours() !== Number(m[1]) || w.getMinutes() !== Number(m[2])) return null;
    at = w.getTime();
  }
  return Number.isFinite(new Date(at).getTime()) && at > now ? at : null;
}

const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const UNITS = [["minutes", "Minutes"], ["hours", "Hours"], ["days", "Days"]];

// The Custom dialog: this copy's own inputs, made once in init. It opens on an hour from now, as T3's.
export function initCustom(view, cx) {
  stopsInit(view, cx, "modal");
  const soon = new Date(Date.now() + 3600000), pad = (n) => String(n).padStart(2, "0");
  view.mode = "date";
  view.unit = "hours";
  view.unitOpen = false;
  view.unitAt = 1;
  view.unitFocus = cx.focus_handle();
  view.unitKeys = cx.focus_handle();
  view.date = soon;
  view.month = new Date(soon.getFullYear(), soon.getMonth(), 1);
  view.calendarOpen = false;
  view.dayKeys = cx.focus_handle();
  view.dayAt = null;
  view.error = null;
  const field = (placeholder, value) => {
    const input = InputState.new({ placeholder, value });
    input.on("change", (_e, cx) => { view.error = null; cx.notify(); });
    input.on("submit", (_e, cx) => { submitCustom(view); cx.notify(); });
    return input;
  };
  view.time = field("HH:MM", `${pad(soon.getHours())}:${pad(soon.getMinutes())}`);
  view.amount = field("2", "2");
  // A number field, as T3's: its steppers count by 1 and stop at 0.
  view.amount.set_min(0);
  view.time.focus();
}

function submitCustom(view) {
  const at = customWake({ mode: view.mode, date: view.date, time: view.time.value(), amount: view.amount.value(), unit: view.unit }, Date.now());
  if (at === null) {
    view.error = view.mode === "date" ? "Choose a valid date and time in the future." : "Enter a positive duration.";
    return;
  }
  closeOverlay(props().overlay);
  run(`t3-inbox.custom-snooze:${props().customSnooze}:${at}`);
}

// A month to pick a day from; days gone by can't be picked. The kit has no calendar of its own.
function calendar(view, t) {
  const y = view.month.getFullYear(), m = view.month.getMonth(), lead = new Date(y, m, 1).getDay();
  const now = new Date(Date.now()), today = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
  const same = (a, b) => a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
  const pick = (d) => { view.date = d; view.calendarOpen = false; view.error = null; };
  const turn = (id, glyph, label, by) => stop(view, t, id, h_flex().id(id).size(36).flex_none().items_center().justify_center().rounded(8).hover((s) => s.bg(t.hover))
    .role("button").accessibility_label(label)
    .on_click((_e, cx) => { view.month = new Date(y, m + by, 1); cx.notify(); })
    .child(svg(`mods/t3-inbox/icons/chevron-${glyph}.svg`).size(16).text_color(t.muted)), 8);
  const day = (d) => {
    const past = d.getTime() < today, on = same(d, view.date), id = `day-${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
    return h_flex().id(id).size(36).items_center().justify_center().rounded(8)
      .text_color(on ? t.solid_foreground : past || d.getMonth() !== m ? t.dim : t.foreground)
      .when(past, (el) => el.opacity(0.5))
      .when(on, (el) => el.bg(t.solid))
      .when(!past, (el) => el.when(!on, (b) => b.hover((s) => s.bg(t.hover))).role("button").accessibility_label(`${MONTHS[d.getMonth()]} ${d.getDate()}`)
        .on_click((_e, cx) => { pick(d); cx.notify(); }))
      .child(String(d.getDate()))
      .when(Boolean(view.dayAt) && same(d, view.dayAt), (el) => el.relative().child(div().absolute().inset_0().rounded(8).border(2).border_color(t.accent)));
  };
  const weeks = Array.from({ length: 6 }, (_, w) => h_flex().children(Array.from({ length: 7 }, (_, i) => day(new Date(y, m, 1 - lead + w * 7 + i)))));
  // One stop for the month's days, as T3's: the panel holds the keyboard and the arrows walk them, the month following.
  return v_flex().id("custom-calendar").mt(4).p(8).rounded(12).bg(t.popover).border_1().border_color(t.border).shadow_lg().text_size(14)
    .track_focus(view.dayKeys).key_context("InboxCalendar")
    .on_action("t3_inbox_day_pick", (_e, cx) => {
      const by = { "month-back": -1, "month-on": 1 }[onStop(view)];
      if (by) view.month = new Date(y, m + by, 1);
      else pick(view.dayAt ?? view.date);
      cx.notify();
    })
    .on_key_down((e, cx) => {
      const by = { left: -1, right: 1, up: -7, down: 7 }[e.key];
      if (!by) return;
      cx.stop_propagation();
      const from = view.dayAt ?? view.date, to = new Date(from.getFullYear(), from.getMonth(), from.getDate() + by);
      if (to.getTime() < today) return;
      view.dayAt = to;
      view.month = new Date(to.getFullYear(), to.getMonth(), 1);
      view.dayKeys.focus();
      cx.notify();
    })
    .child(h_flex().h(36).mb(4).items_center()
      .child(turn("month-back", "left", "Previous month", -1))
      .child(div().flex_1().text_center().font_medium().text_color(t.foreground).child(`${MONTHS[m]} ${y}`))
      .child(turn("month-on", "right", "Next month", 1)))
    .child(h_flex().children(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].map((w) => h_flex().size(36).items_center().justify_center().text_size(12).font_medium().text_color(t.dim).child(w))))
    .children(weeks);
}

export function customView(view) {
  const t = theme(), done = () => closeOverlay(props().overlay);
  const label = (text) => div().text_size(14).line_height("16px").font_medium().text_color(t.foreground).child(text);
  // 11 and T3's 1px border, as its controls count their padding.
  const input = (state) => h_flex().h(32).px(11).rounded(8).border(1).border_color(t.border).bg(t.input).items_center()
    .child(Input.new(state).flex_1().h_full().text_size(14).text_color(t.foreground));
  const choice = (id, on, name, pick) => stop(view, t, id, h_flex().id(id).h(24).flex_1().px(10).rounded(6).items_center().justify_center().text_size(12).font_medium()
    .when(on, (el) => el.bg(t.selected)).text_color(on ? t.foreground : t.dim).hover((s) => s.text_color(t.foreground))
    .role("button").accessibility_label(name)
    .on_click((_e, cx) => { pick(); view.error = null; cx.notify(); }).child(name));
  const button = (id, text, primary, act) => stop(view, t, id, h_flex().id(id).h(32).px(11).items_center().rounded(8).border_1().border_color(primary ? t.solid : t.input).text_size(14).font_medium()
    .bg(primary ? t.solid : t.raised).text_color(primary ? t.solid_foreground : t.foreground)
    .cursor_pointer().hover((s) => s.opacity(0.88)).role("button").accessibility_label(text).on_click(act).child(text), 8);
  // NumberInput replays these onto its own step buttons (their ids are its own); inside the frame's 1px, so 7 round.
  const stepper = (glyph, name, side) => h_flex().h_full().px(11).flex_none().items_center().justify_center().cursor_pointer()
    .when(side === "l", (el) => el.rounded_l(7)).when(side === "r", (el) => el.rounded_r(7)).hover((s) => s.bg(t.hover))
    .accessibility_label(name).child(svg(`mods/t3-inbox/icons/${glyph}.svg`).size(16).flex_none().text_color(t.muted));
  // T3's unit Select, on the kit's: it owns Esc and ↑/↓/Enter opening; the highlight, the pick and a press elsewhere are ours.
  // The trigger is drawn as the date's, the list under it, the chosen one shaded.
  const zoom = Number(settings()?.zoom) || 1;
  const showUnits = (open) => {
    view.unitOpen = open;
    if (open) view.unitAt = UNITS.findIndex(([u]) => u === view.unit);
  };
  const pickUnit = (u) => {
    view.unit = u;
    view.error = null;
    showUnits(false);
    view.unitFocus.focus();
  };
  const unitTrigger = stop(view, t, "custom-unit-button", h_flex().id("custom-unit-button").w_full().h(32).px(11).gap(8).rounded(8).border(1).border_color(t.border).bg(t.input).items_center().cursor_pointer()
    .on_hover((on) => { view.overUnit = on; })
    .on_size_change((size) => { view.unitW = size.width / zoom; })
    .on_click((_e, cx) => {
      showUnits(!view.unitOpen);
      (view.unitOpen ? view.unitKeys : view.unitFocus).focus();
      cx.notify();
    })
    .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(UNITS.find(([u]) => u === view.unit)[1]))
    .child(svg("mods/t3-inbox/icons/chevron-down.svg").size(14).mr(-4).flex_none().text_color(t.muted).opacity(0.7)), 8, { handle: view.unitFocus });
  const unitList = v_flex().id("custom-unit-list").w(view.unitW ?? 161).mt(4).p(4).rounded(8).bg(t.popover).border_1().border_color(t.border).shadow_lg()
    .track_focus(view.unitKeys)
    // The trigger's own click toggles, so a press on it isn't "elsewhere".
    .on_mouse_down_out((_e, cx) => { if (!view.overUnit) { showUnits(false); cx.notify(); } })
    .on_key_down((e, cx) => {
      if (e.key === "enter" || e.key === "space") pickUnit(UNITS[view.unitAt][0]);
      else {
        const to = menuJump(view, e, UNITS.map(([, name]) => name), view.unitAt);
        if (to < 0) return;
        view.unitAt = to;
      }
      cx.stop_propagation();
      cx.notify();
    })
    .children(UNITS.map(([u, name], i) => h_flex().id(`unit-${u}`).h(28).px(8).flex_none().items_center().rounded(4).text_color(t.foreground)
      .when(view.unit === u, (row) => row.bg(t.selected)).when(view.unit !== u && view.unitAt === i, (row) => row.bg(t.hover))
      .when(view.unitAt === i, (row) => row.aria_active_descendant())
      .on_hover((on, cx) => { if (on && view.unitAt !== i) { view.unitAt = i; cx.notify(); } })
      .role("list_box_option").aria_selected(view.unit === u).accessibility_label(name)
      .on_click((_e, cx) => { pickUnit(u); cx.notify(); })
      .child(name)));
  const unit = Select.new("custom-unit").w_full().accessibility_label("Unit").open(view.unitOpen).track_focus(view.unitFocus).content_focus_handle(view.unitKeys)
    .on_open_change((open, cx) => { showUnits(open); cx.notify(); })
    .child(Popup.new("custom-unit-popup", unitTrigger).w_full().when(view.unitOpen, (el) => el.content(unitList)));
  const when = view.mode === "date"
    ? h_flex().gap(12)
      .child(v_flex().flex_1().min_w(0).gap(8).child(label("Date"))
        .child(Popover.new("custom-date").anchor("top_left").open(view.calendarOpen).track_focus(view.dayKeys)
          .on_open_change((open, cx) => {
            view.calendarOpen = open;
            if (open) {
              view.dayAt = null;
              view.month = new Date(view.date.getFullYear(), view.date.getMonth(), 1);
              // Enter and Space are the Popover's, which would only close it: a binding of ours, deeper in, comes first (as the snooze menu's).
              cx.bind_keys(["enter", "space"].map((keystroke) => ({ keystroke, action: "t3_inbox_day_pick", context: "InboxCalendar" })));
            }
            cx.notify();
          })
          .trigger(stop(view, t, "custom-date-button", h_flex().id("custom-date-button").h(32).px(11).gap(8).rounded(8).border(1).border_color(t.border).bg(t.input).items_center().cursor_pointer()
            .role("button").accessibility_label("Choose snooze date")
            .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(`${MONTHS[view.date.getMonth()].slice(0, 3)} ${view.date.getDate()}, ${view.date.getFullYear()}`))
            .child(svg("mods/t3-inbox/icons/calendar.svg").size(16).mr(-2).flex_none().text_color(t.muted)), 8))
          .when(view.calendarOpen, (el) => el.content(calendar(view, t)))))
      .child(v_flex().flex_1().min_w(0).gap(8).child(label("Time")).child(input(view.time)))
    : h_flex().gap(12)
      // As T3's NumberField: − and + either side of the amount, in the frame the other fields have.
      .child(v_flex().flex_1().min_w(0).gap(8).child(label("Snooze for"))
        .child(NumberInput.new(view.amount).h(32).rounded(8).border(1).border_color(t.border).bg(t.input).text_size(14).text_color(t.foreground)
          .decrement_button(stepper("minus", "Decrease duration", "l"))
          .increment_button(stepper("plus", "Increase duration", "r"))))
      .child(v_flex().flex_1().min_w(0).gap(8).child(label("Unit")).child(unit));
  // T3's dialog: its header, panel and footer, each with its own padding, in a frame drawn here for T3's 16px corners (Herdr's own is its size).
  return focusRoot(view, v_flex().id("custom-snooze").w_full().rounded(16).border(1).border_color(t.border).bg(t.popover).shadow_xl().text_size(14)
    .child(v_flex().flex_none().p(24).pb(12).gap(8)
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(20).line_height(1.375).font_semibold().text_color(t.foreground).child("Custom snooze"))
        .child(div().text_size(12).text_color(t.dim).child("Esc")))
      .child(div().line_height("20px").text_color(t.muted).child("Choose when snoozed agents return to your inbox.")))
    .child(v_flex().flex_none().px(24).pt(4).pb(24).gap(16)
      // T3's segmented group: the track and 2 around its toggles.
      .child(h_flex().gap(2).p(2).rounded(8).bg(t.input)
        .child(choice("mode-date", view.mode === "date", "Date and time", () => { view.mode = "date"; view.time.focus(); }))
        .child(choice("mode-duration", view.mode === "duration", "Duration", () => { view.mode = "duration"; view.amount.focus(); })))
      .child(when)
      .when(Boolean(view.error), (el) => el.child(div().id("custom-error").role("alert").line_height("20px").text_color(t.blocked).child(view.error))))
    .child(h_flex().flex_none().px(24).py(16).gap(8).items_center().justify_end().border_t(1).border_color(t.border)
      .child(button("custom-cancel", "Cancel", false, done))
      .child(button("custom-submit", "Snooze", true, (_e, cx) => { submitCustom(view); cx.notify(); }))));
}

export function snoozeButton(view, t, a, { now, offer: napOffer, delay }, pick) {
  const napId = `snooze-${a.address}`;
  const menu = view.napMenu === a.address, zoom = Number(settings()?.zoom) || 1;
  const lit = (id, color) => view.hot === id ? t.foreground : color;
  return tip(view, t, napId, "Snooze agent", Popover.new(`snooze-menu-${a.address}`).anchor(view.napRight - NAP_MENU_W >= NAP_MENU_MARGIN ? "top_right" : "top_left").open(menu).track_focus(view.napKeys)
    .on_open_change((open, cx) => {
      view.napMenu = open ? a.address : null;
      if (!open) view.napRight = null;
      view.napAt = -1;
      // T3's menu fades in: drawn clear once, then let go (Herdr eases only later changes). It closes at once.
      if (open) { view.napShown = false; cx.timer.after(16, (cx) => { view.napShown = true; cx.notify(); }); }
      // Enter and Space are the Popover's, which would only close it: a binding of ours, deeper in, comes first.
      // On each open, as win98's menu binds: a reload of keys.json clears the keymap.
      if (open) cx.bind_keys(["enter", "space"].map((keystroke) => ({ keystroke, action: "t3_inbox_snooze_pick", context: "InboxSnoozeMenu" })));
      cx.notify();
    })
    .trigger(h_flex().id(napId).h(20).px(6).flex_none().items_center().justify_center().rounded(6)
      .opacity(napOffer ? 1 : 0).transition("opacity", MOTION).on_hover(glow(view, napId))
      .on_mouse_down("left", (e) => { view.napRight = e.bounds ? (e.bounds.x + e.bounds.width) / zoom : null; })
      .role("button").accessibility_label("Snooze agent")
      .child(svg("mods/t3-inbox/icons/clock.svg").size(12).flex_none().text_color(menu ? t.foreground : lit(napId, t.muted)))
      .when(napOffer, (el) => stop(view, t, napId, el, 6)))
    .when(menu, (el) => {
      const choices = [...presets(now), { label: "Custom…", custom: true }];
      // Sized as T3's menu: as wide as its rows, 160px at least. Nothing lit until the pointer or a key gets there.
      return el.content(v_flex().id(`snooze-panel-${a.address}`).min_w(160).mt(4).p(4).rounded(8).bg(t.popover).border_1().border_color(t.border).shadow_lg().text_size(14)
        .opacity(view.napShown === false ? 0 : 1).transition("opacity", MOTION)
        .track_focus(view.napKeys).key_context("InboxSnoozeMenu")
        .on_action("t3_inbox_snooze_pick", (_e, cx) => {
          if (choices[view.napAt]) pick(a, choices[view.napAt], cx);
          cx.notify();
        })
        .on_key_down((e, cx) => {
          const to = menuJump(view, e, choices.map((p) => p.label), view.napAt);
          if (to < 0) return;
          view.napAt = to;
          cx.stop_propagation();
          cx.notify();
        })
        .children(choices.flatMap((p, i) => [
          ...(p.custom ? [div().h(1).mx(8).my(4).flex_none().bg(t.border)] : []),
          h_flex().id(`snooze-${i}-${a.address}`).h(28).px(8).gap(8).flex_none().items_center().rounded(4)
            .when(i === view.napAt, (row) => row.bg(t.selected))
            .on_hover((on, cx) => {
              const at = on ? i : view.napAt === i ? -1 : view.napAt;
              if (at !== view.napAt) { view.napAt = at; cx.notify(); }
            })
            .role("button").accessibility_label(p.label)
            .on_click((_e, cx) => {
              cx.stop_propagation();
              pick(a, p, cx);
              cx.notify();
            })
            .child(div().flex_none().text_color(t.foreground).child(p.label))
            .when(Boolean(p.when), (row) => row.child(div().flex_none().ml_auto().text_size(12).font_medium().text_color(t.dim).child(p.when))),
        ])));
    }), { delay, off: menu });
}
