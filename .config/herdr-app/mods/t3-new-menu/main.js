// New: pick the space and open a terminal tab there, or start a new space, on a machine picked as T3 picks an environment.
import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex, InputState, Input } from "gpui-base";
import { theme, spaces, machines, panes, run, closeOverlay, props, window, keys, home, shared, setShared } from "herdr";
import { projectMark, placeOf } from "./project.js";
import { step, scrollList } from "./list.js";

function shortcut(name) {
  const k = keys().find(b => b.section === "global" && b.action === name);
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

// As T3's command item: 6 + a 20px title + a 16px line + 6.
const ROW = 48;
// The list's share of T3's 420 once its border, search, top inset and heading, bottom inset and footer are in; the popup hugs its content.
const LIST_MAX = 420 - 2 - 48 - 8 - 28 - 8 - 41;
const STATE = { ready: "Connected", loading: "Loading…", unavailable: "Unavailable" };

export default class NewMenu extends View {
  init() {
    this.at = 0;
    this.filter = "";
    this.picking = Boolean(props()?.pick); // choosing the machine for a new space; the sidebar's New space opens here
    const field = (placeholder) => {
      const input = InputState.new({ placeholder });
      input.on("change", (_e, cx) => { this.filter = input.value(); this.at = 0; cx.notify(); });
      input.on("submit", () => { this.choose(this.items()[this.at]); });
      return input;
    };
    this.spaceInput = field("Search spaces…");
    this.machineInput = field("Search machines…");
    (this.picking ? this.machineInput : this.spaceInput).focus();
  }

  // For the buttons that open this: see justClosed in focus.js. New space's and New tab's apart, as each opens the other's step.
  close() { setShared(this.picking ? "t3-new-menu.pickClosed" : "t3-new-menu.closed", Date.now()); }

  // The active space's machine first, as ⌘N would use it.
  machineRows() {
    const here = spaces().find(s => s.active)?.machine ?? null;
    const others = [...machines().map(k => k.name), ...spaces().map(s => s.machine)].filter(Boolean).sort();
    return [...new Set([here, null, ...others])].map(m => {
      const layout = m ? machines().find(k => k.name === m)?.layout ?? "unavailable" : "ready";
      return { key: `machine:${m ?? ""}`, machine: m, name: m ?? "This computer", sub: m ? STATE[layout] : "Local", off: layout !== "ready" };
    });
  }

  // The current space first, then its machine's, so a machine's spaces stay together.
  items() {
    const q = this.filter.toLowerCase();
    if (this.picking) return this.machineRows().filter(m => m.name.toLowerCase().includes(q));
    const ps = panes(), here = spaces().find(s => s.active)?.machine ?? null;
    const rank = (s) => (s.active ? 0 : (s.machine ?? null) === here ? 1 : 2);
    return spaces().filter(s => s.id !== shared("t3-home.space") && `${s.name} ${s.machine ?? ""} ${placeOf(s, ps)}`.toLowerCase().includes(q))
      .sort((a, b) => rank(a) - rank(b) || (a.machine ?? "").localeCompare(b.machine ?? ""))
      .map(s => ({ key: `space:${s.id}`, space: s }));
  }

  choose(item) {
    if (!item || item.off) return;
    closeOverlay(props().overlay);
    if (item.space) run("tab.new", { space: item.space.id });
    else run("space.new", { machine: item.machine ?? "" });
  }

  showMachines(on, cx) {
    this.picking = on;
    this.at = 0;
    this.filter = "";
    const input = on ? this.machineInput : this.spaceInput;
    input.set_value("");
    input.focus();
    cx.notify();
  }

  // As T3's Add project: a machine to pick only when there is more than one.
  newSpace(cx) {
    const rows = this.machineRows();
    if (rows.length > 1) this.showMachines(true, cx);
    else this.choose(rows[0]);
  }

  row(item, i, ps) {
    const t = theme(), on = this.at === i, s = item.space, h = home();
    const short = (p) => (p && h && p.startsWith(h) ? "~" + p.slice(h.length) : p ?? "");
    // A home path means nothing on another machine, and its empty folder is its home.
    const sub = s ? (s.machine ? placeOf(s, ps) || "~" : short(placeOf(s, ps))) : item.sub;
    return h_flex().id(item.key).w_full().h(ROW).px(8).py(6).gap(8).rounded(4).items_center().flex_none()
      .role("button").accessibility_label(s ? s.name : item.name)
      .when(on, el => el.bg(t.selected))
      .when(Boolean(item.off), el => el.opacity(0.64))
      .on_hover((over, cx) => { if (over && this.at !== i) { this.at = i; cx.notify(); } })
      .on_click(() => this.choose(item))
      // As T3's CommandPaletteTitleIcon: level with the title, not the row.
      .child(h_flex().w(16).h(20).pt(2).self_start().flex_none().items_center().justify_center()
        .child(s ? projectMark(s, 16, t, ps) : svg(`mods/t3-new-menu/icons/${item.machine ? "server" : "monitor"}.svg`).size(16).text_color(t.muted)))
      .child(v_flex().flex_1().min_w(0)
        .child(div().truncate().text_color(t.foreground).child(s ? s.name : item.name))
        .child(h_flex().min_w(0).gap(4).items_center().text_size(12).line_height("16px").text_color(t.dim)
          // As T3 marks a remote thread: a server icon, then the name.
          .when(Boolean(s?.machine), el => el
            .child(svg("mods/t3-new-menu/icons/server.svg").size(12).flex_none().text_color(t.muted))
            .child(div().flex_none().text_color(t.muted).child(`${s.machine} ·`)))
          .child(div().min_w(0).truncate().child(sub))))
      .when(Boolean(s) && i < 9, el => el.child(div().flex_none().text_size(12).font_medium().text_color(t.muted).child(`⌘${i + 1}`)));
  }

  render() {
    const t = theme(), ps = panes(), items = this.items();
    const key = (label) => div().flex().flex_none().min_w(20).h(20).px(4).items_center().justify_center().rounded(4).bg(t.foreground + "14").text_size(12).text_color(t.foreground).child(label);
    const hint = (label, what) => h_flex().gap(4).items_center().children(label.split(" ").map(key)).child(what);
    // ⌘N doesn't ask: it only names what this button does when there's nothing to ask.
    const newKey = this.machineRows().length > 1 ? "" : shortcut("space.new");
    // T3's CommandFooterAction: no fill of its own, its words brighten.
    const footButton = (id, label) => h_flex().id(id).gap(4).px(8).rounded(8).items_center().flex_none().text_size(12).line_height("16px")
      .role("button").accessibility_label(label).hover(s => s.text_color(t.foreground));
    return v_flex().id("new-menu").size_full().min_h(0).rounded(16).border(1).border_color(t.border).bg(t.popover).shadow_2xl().text_size(14).line_height("20px")
      .on_key_down((e, cx) => {
        if (e.key === "escape") return closeOverlay(props().overlay);
        const to = step(e, this.at, items.length);
        if (to >= 0) this.at = to;
        else if (!this.picking && /^[1-9]$/.test(e.key) && e.modifiers.platform) { cx.stop_propagation(); return this.choose(items[Number(e.key) - 1]); }
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().h(36).my(6).flex_none().pl(18).pr(20).gap(7).items_center()
        .child(svg("mods/t3-new-menu/icons/search.svg").size(16).flex_none().text_color(t.dim))
        .child(Input.new(this.picking ? this.machineInput : this.spaceInput).flex_1().h_full().text_size(14).text_color(t.foreground)))
      .child(div().mt(8).px(16).py(6).flex_none().text_size(12).line_height("16px").font_medium().text_color(t.muted).child(this.picking ? "Machines" : "Spaces"))
      .child(div().flex_none().mb(8).px(8)
        .when(items.length > 0, el => el.child(scrollList(this, "new-rows", { count: items.length, row: ROW, at: this.at, height: Math.min(items.length * ROW, LIST_MAX),
          draw: (i) => this.row(items[i], i, ps), wheeled: (keep) => { this.at = keep; } })))
        .when(items.length === 0, el => el.child(div().py(40).text_center().text_color(t.dim).child(this.picking ? "No matching machines." : "No matching spaces."))))
      .child(h_flex().flex_none().px(16).py(10).gap(8).items_center().justify_between().rounded_b(15).border_t(1).border_color(t.foreground + "12").bg(t.foreground + "06").font_medium().text_color(t.muted)
        .child(h_flex().gap(12).items_center()
          .child(hint("↑ ↓", "Navigate"))
          .child(hint("Enter", this.picking ? "New space" : "New tab"))
          .child(hint("Esc", "Close")))
        .when(this.picking, el => el.child(footButton("new-back", "Back to spaces").on_click((_e, cx) => this.showMachines(false, cx)).child("← Spaces")))
        .when(!this.picking, el => el.child(footButton("space-new", "New space").on_click((_e, cx) => this.newSpace(cx))
          .child(svg("mods/t3-new-menu/icons/folder-plus.svg").size(14).text_color(t.muted))
          .child("New space")
          .when(Boolean(newKey), row => row.child(key(newKey))))));
  }
}
