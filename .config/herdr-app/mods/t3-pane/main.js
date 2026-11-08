// A pane's header, for layouts that frame their panes:
//   { "tab": "active", "pane": { "header": { "content": { "mod": "t3-pane" } } } }
// Shows the program's icon (the app's program table), the agent's name or
// the terminal's title, the folder, and the agent's status; buttons split, zoom and close
// this pane. Props from the app: { pane, terminal }. Click: focus the pane.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, terminals, agents, props, run, theme, home } from "herdr";
import { modStatus, namer, programOf } from "./name.js";
import { notNews, ownStatus, subAgents, treeStatus } from "./tree.js";
import { tip, tipMark, glow, POINTER_WATCH, pointerAt, pointerGone, pointerMoved } from "./tip.js";
import { stopsInit, stopsEnd, stop, focusRoot, within } from "./focus.js";

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}


export default class Pane extends View {
  init(_props, cx) {
    this.hovered = false;
    stopsInit(this, cx);
  }

  async close() {
    stopsEnd(this);
  }

  // What shows on hover also watches where the pointer is: its leave can be dropped (tip.js).
  headHover(on, cx) {
    this.hovered = on;
    this.box = null;
    this.hoverWatch?.cancel();
    if (on) {
      const from = pointerAt();
      this.hoverWatch = cx.timer.every(POINTER_WATCH, (cx) => {
        if (!pointerGone(this.box, from)) return;
        this.hoverWatch.cancel();
        this.hovered = false;
        cx.notify();
      });
    }
    cx.notify();
  }

  me() {
    return panes().find((p) => p.pane === props()?.pane);
  }

  button(t, id, icon, label, action, key) {
    return tip(this, t, id, label, stop(this, t, id, div()
      .id(id)
      .size(24).flex_none().flex().items_center().justify_center()
      .rounded(8)
      // Its icon brightens by state: a hover style reaches text but not an svg, as in the inbox.
      .text_color(this.hot === id ? t.foreground : t.dim)
      .role("button").accessibility_label(label)
      .hover((s) => s.bg(t.hover))
      .on_hover(glow(this, id))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => {
        cx.stop_propagation();
        action();
        cx.notify();
      })
      .child(svg(icon).size(14)), 8), { action: key });
  }

  render(cx) {
    const t = theme();
    const p = this.me();
    if (!p) return div();
    // Home's default page says nothing of itself: the brand bar's button tells where this is.
    const name = p.mod === "t3-home" ? "" : namer()(p);
    const pic = icon(programOf(p), 14, t.muted);
    // Its agent with the sub-agents it started (tree.js).
    const all = terminals();
    const kids = subAgents(agents(), all)(p.terminal);
    const st = p.mod ? modStatus(p) : treeStatus(ownStatus(p.status, p.terminal, all), kids);
    const pane = p.pane;
    // A mark takes the last button's 24px, so it, the × and the tab bar's + share one column: this header's pr(2), the frame's 2 and the block's 8 are the bar's 12.
    const slot = (mark) => div().w(24).flex_none().flex().items_center().justify_center().child(mark);
    // The buttons show with the keyboard on the header or one of them, as they do hovered: the header's the stop that gets there.
    const head = `pane-head-${pane}`, tools = ["r", "d", "z", "x"].map((k) => `ph-${k}-${pane}`);
    // The rounded frame paints the background; rectangular child fills would cover its corners.
    return focusRoot(this, stop(this, t, head, h_flex()
      .id(head)
      .size_full()
      // 4 + the frame's 2 is a tab's 6: with its 16px slot and 2 to the name, the icon and first word stand under the first tab's.
      .pl(4)
      .pr(2)
      .gap(12)
      .items_center()
      .text_size(14)
      .on_hover((on, cx) => this.headHover(on, cx))
      .on_mouse_move((e) => { pointerMoved(e.position); this.box = e.bounds; })
      .on_click(() => run("pane.focus", { pane }))
      .child(div().size(16).mr(-10).flex_none().flex().items_center().justify_center().when(Boolean(pic), (el) => el.child(pic)))
      .when(Boolean(p.terminal) && name !== p.terminal, (el) => el.child(div().flex_none().text_color(t.dim).child(p.terminal)))
      .child(div().min_w(0).truncate().font_medium().text_color(p.focused ? t.foreground : t.muted).child(name))
      .child(div().relative().flex_1().min_w(0).h_full().flex().items_center()
        .child(div().flex_1().min_w(0).truncate().pr(12).text_color(t.dim).child(folder(p.cwd)))
        // Over the folder's end, so hovering moves nothing else, as in the agents list and the inbox.
        .when(this.hovered || within(this, [head, ...tools]), el => el.child(h_flex().absolute().top(0).bottom(0).right(0).pl(12).flex_none().gap(4).items_center().bg(t.background)
          .child(this.button(t, `ph-r-${pane}`, "mods/t3-pane/icons/square-split-horizontal.svg", "Split right", () => run("pane.split", { direction: "right", pane }), "pane.split:right"))
          .child(this.button(t, `ph-d-${pane}`, "mods/t3-pane/icons/square-split-vertical.svg", "Split down", () => run("pane.split", { direction: "down", pane }), "pane.split:down"))
          .child(this.button(t, `ph-z-${pane}`, `mods/t3-pane/icons/${p.zoomed ? "minimize-2" : "maximize-2"}.svg`, p.zoomed ? "Unzoom pane" : "Zoom pane", () => run("pane.zoom", { pane }), "pane.zoom"))
          .child(this.button(t, `ph-x-${pane}`, "mods/t3-pane/icons/x.svg", "Close pane", () => { this.hot = null; run(`t3-tabs.close-pane:${pane}`); }, "pane.close")))))
      .when(st === "working", el => el.child(slot(tipMark(this, t, `ph-mark-${pane}`, "Working", svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))))
      // The same marks as the agents list and tabs.
      .when(st === "blocked", el => el.child(slot(tipMark(this, t, `ph-mark-${pane}`, "Needs you", div().size(14).flex_none().rounded(4).bg(t.blocked + "26").text_size(11).font_bold().text_color(t.blocked).flex().items_center().justify_center().accessibility_label("Needs you").child("!")))))
      .when(st === "done" && !notNews(all.find(k => k.address === p.terminal), p.status, kids), el => el.child(slot(tipMark(this, t, `ph-mark-${pane}`, "Done", div().size(6).flex_none().rounded_full().bg(t.done))))), 8));
  }
}
