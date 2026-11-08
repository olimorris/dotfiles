// Home's default page: where putting the agent in view away lands, with nothing to look at but what can be done next.
// t3-tabs owns the place itself (a space of its own); this is only what it shows until someone arranges something else there.
import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { layout, run, shared, theme } from "herdr";
import { keyOf } from "./tip.js";
import { stopsInit, stopsEnd, stop, focusRoot, pressed, justClosed } from "./focus.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}
// The selected sidebar keeps its rows current while hidden too.
function hasNext() {
  return shared(find(layout(), "sidebar-lists")?.active === "inbox" ? "t3-inbox.rows" : "t3-agents.rows")?.order?.length > 0;
}
const ACTIONS = [
  { id: "next", word: "Next agent", action: "t3-tabs.next", go: () => run("t3-tabs.next"), ready: hasNext },
  { id: "goto", word: "Go to", action: "mod.open:t3-picker", go: () => run("mod.open", { name: "t3-picker" }), pops: "t3-picker.closed" },
  { id: "new", word: "New tab", action: "t3-tabs.new", go: () => run("t3-tabs.new"), pops: "t3-new-menu.closed" },
];
// A key as its strokes: each modifier, then the rest ("⇧⌘P", "Ctrl+Shift+P").
const caps = (key) => key.match(/[⌃⌥⇧⌘]|[^⌃⌥⇧⌘+]+/gu);

export default class Home extends View {
  init(_props, cx) {
    stopsInit(this, cx);
  }

  async close() {
    stopsEnd(this);
  }

  render() {
    const t = theme();
    const row = (a) => {
      const id = `home-${a.id}`, off = a.ready && !a.ready(), key = keyOf(a.action);
      const el = h_flex().id(id).h(32).px(10).gap(10).flex_none().rounded(8).items_center().justify_between().text_color(t.muted)
        .child(a.word)
        .when(Boolean(key), (r) => r.child(h_flex().flex_none().gap(4).children(caps(key).map((cap) => div().min_w(20).h(20).px(4).flex().items_center().justify_center()
          .rounded(4).bg(t.foreground + "12").text_size(12).font_medium().text_color(t.foreground + "bf").child(cap)))));
      // Nowhere to go: dimmed, as the key does nothing either. The theme's hover can be the pane's own color, so a tint of the text, as Go to's rows.
      return off ? el.opacity(0.5) : stop(this, t, id, el.role("button").accessibility_label(a.word)
        .hover((s) => s.bg(t.foreground + "0f").text_color(t.foreground)).active((s) => s.bg(t.selected)).on_mouse_down("left", () => pressed(this)).on_click(() => { if (!a.pops || !justClosed(this, a.pops)) a.go(); }), 8);
    };
    // As T3's launcher: pb its top bar's height, so the list centers on the whole panel.
    return focusRoot(this, v_flex().size_full().px(24).pb(40).items_center().justify_center()
      .child(v_flex().w_full().max_w(320).gap(2).text_size(14).children(ACTIONS.map(row))));
  }
}
