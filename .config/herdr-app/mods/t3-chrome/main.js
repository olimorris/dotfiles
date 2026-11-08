import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, props, updates, layout, shared } from "herdr";
import { tip, glow } from "./tip.js";
import { stopsInit, stopsEnd, stop, focusRoot } from "./focus.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar shows either Lists (Spaces and Agents) or the Inbox (t3-inbox): a stack in the layout.
const inboxShown = () => find(layout(), "sidebar-lists")?.active === "inbox";
export default class WorkspaceChrome extends View {
  async close() { stopsEnd(this); }

  init(_props, cx) {
    stopsInit(this, cx);
  }

  render() {
    const t = theme();
    const lit = (id, color = t.dim) => (this.hot === id ? t.foreground : color);
    if (props()?.footer) {
      // As T3's footer: a row of 32px icon buttons, and at its end, once Herdr has downloaded an update, its restart.
      const ready = updates().app.ready;
      // T3's undo notice, the inbox's (t3-inbox.notice), in this row's free space so it covers nothing: "Settled," or
      // "Settled 2," then Undo, which the inbox does. It fades in and out over 200ms, Undo inert while it goes. One older than
      // its 5s and the fade is left from before a restart.
      const n = shared("t3-inbox.notice");
      // Short of room the summary is cut, never Undo: GPUI's flex doesn't do T3's two wraps, which squeezed Undo to nothing.
      const notice = n && Date.now() - n.at < 6000 && h_flex().id(`undo-notice-${n.gen}`).flex_1().min_w(0).h(24).justify_end().gap(4).items_center()
        .text_size(11).text_color(t.dim).opacity(n.shown ? 1 : 0).transition("opacity", { duration: 200, easing: "ease-out" })
        .child(div().min_w(0).truncate().child(`${n.action}${n.count === 1 ? "" : ` ${n.count}`},`))
        // As T3's InlineButton: medium, foreground, underlined on hover.
        .child(h_flex().id("undo-notice-undo").flex_none().h(24).items_center().font_medium().text_color(t.foreground)
          .when(n.live && Date.now() - n.at < 5000, (el) => el.hover((s) => s.underline()).role("button").accessibility_label(`Undo: ${n.action} ${n.count} agent${n.count === 1 ? "" : "s"}`)
            .on_click(() => run("t3-tabs.undo")))
          .child("Undo")
          .when(n.live && Date.now() - n.at < 5000, (el) => stop(this, t, "undo-notice-undo", el, 4)));
      const button = (id, glyph, label, action, key) => tip(this, t, id, label, stop(this, t, id, div().id(id).size(32).flex_none().flex().items_center().justify_center().rounded(8)
        .text_color(lit(id)).hover(s => s.bg(t.hover)).on_hover(glow(this, id))
        .role("button").accessibility_label(label)
        // Each opens over its button, before the pointer can report leaving it.
        .on_click((_e, cx) => { this.hot = null; action(); cx.notify(); })
        .child(glyph), 8), { action: key });
      // T3's footer: 8 in and 4 above its row, whatever height the layout gives the block.
      return focusRoot(this, div().size_full().bg(t.chrome).px(8).pt(4).child(h_flex().h(32).gap(4).items_center()
        .child(button("settings", svg("mods/t3-chrome/icons/settings.svg").size(16), "Settings", () => run("app.settings"), "app.settings"))
        .child(button("add-machine", svg("mods/t3-chrome/icons/server.svg").size(16), "Add machine", () => run("mod.open", { name: "machine-add" })))
        .child(notice || div().flex_1())
        .when(Boolean(ready), el => el.child(tip(this, t, "app-update", `Update ${ready} downloaded. Click to restart`, stop(this, t, "app-update", div().id("app-update").h(32).px(12).flex_none().flex().items_center()
          .rounded_full().bg(t.accent + "26").text_size(12).text_color(t.accent).hover(s => s.bg(t.accent + "40")).on_hover(glow(this, "app-update"))
          .role("button").accessibility_label(`Restart into Herdr ${ready}`)
          .on_click(() => run("app.update")).child("Update"), 16))))));
    }
    // Room for the macOS window buttons (layout traffic_lights), a place to drag the window, and the
    // sidebar toggle at its right edge; while the sidebar is hidden, t3-tabs shows it after the buttons.
    const inbox = inboxShown();
    // T3's 28px title bar buttons, side by side instead of its 12 apart, so each stands over a button of the list's top row below.
    return focusRoot(this, h_flex().id("brand").size_full().bg(t.chrome).pr(8).items_center().justify_end()
      .child(h_flex().flex_none().items_center()
      .child(tip(this, t, "sidebar-mode", inbox ? "Show lists" : "Show inbox", stop(this, t, "sidebar-mode", div().id("sidebar-mode").size(28).flex_none().flex().items_center().justify_center().rounded(8)
        .text_color(lit("sidebar-mode")).hover(s => s.bg(t.hover)).on_hover(glow(this, "sidebar-mode"))
        .role("button").accessibility_label(inbox ? "Show lists" : "Show inbox")
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(() => run("t3-tabs.sidebar"))
        // The mode a click shows, as its label says: a tray for the Inbox, rows with their marks for the lists. Not circle-check or layers: those are Settle and Grouped by space.
        .child(svg(`mods/t3-chrome/icons/${inbox ? "layout-list" : "inbox"}.svg`).size(14)), 8), { action: "t3-tabs.sidebar", below: true })))
      .child(tip(this, t, "sidebar-toggle", "Hide sidebar", stop(this, t, "sidebar-toggle", div().id("sidebar-toggle").size(28).flex_none().flex().items_center().justify_center().rounded(8)
        .text_color(lit("sidebar-toggle")).hover(s => s.bg(t.hover)).on_hover(glow(this, "sidebar-toggle"))
        .role("button").accessibility_label("Hide sidebar")
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        // It goes with the sidebar, before the pointer can report leaving it.
        .on_click(() => { this.hot = null; run("layout.toggle", { id: "sidebar" }); })
        .child(svg("mods/t3-chrome/icons/panel-left.svg").size(14)), 8), { action: "layout.toggle:sidebar", below: true })));
  }
}
