import { div, svg } from "gpui-kit";
import { v_flex, h_flex, Popover, Input } from "gpui-base";
import { spaces, machines, shared, run, props, openOverlay } from "herdr";
import { projectMark } from "./project.js";
import { glow, tip } from "./tip.js";
import { stop, pressed, justClosed } from "./focus.js";
import { step, scrollList } from "./list.js";
import { FIRST } from "./row-model.js";

// The space filter's rows, flush as T3's, and how many show before the list scrolls: the whole rows T3's 23rem holds.
const SCOPE_ROW = 32, SCOPE_SHOWN = 9;

export function inboxMatches(view) {
  const q = view.search.value().toLowerCase();
  return [{ id: null, name: "All spaces" }, ...spaces().filter((s) => s.id !== shared("t3-home.space"))].filter((s) => s.name.toLowerCase().includes(q));
}

// A click shows that space alone; shift-click adds or removes it and keeps the menu open, as in T3.
export function pickInboxSpace(view, s, shift, cx) {
  if (!s) return;
  view.scope = !s.id ? [] : !shift ? [s.id] : view.scope.includes(s.id) ? view.scope.filter((id) => id !== s.id) : [...view.scope, s.id];
  localStorage.setItem("scope", JSON.stringify(view.scope));
  // A new scope starts the settled tail over, as T3's does.
  view.limit = FIRST;
  if (!shift) view.scopeOpen = false;
  cx.notify();
}

export function inboxTop(view, t, model) {
  const { sp, ps, scope } = model;
  const lit = (id, color) => view.hot === id ? t.foreground : color;
  // A space's mark, as t3-spaces draws it.
  const avatar = (id, name, size) => projectMark(sp.find((s) => s.id === id) ?? { name: name ?? "" }, size, t, ps);
  // T3's top row: search on the left, then the space filter, new space and new tab.
  const asks = props()?.newMenu && machines().length > 1;
  const tool = (id, label, icon, fn, more) => tip(view, t, id, label, stop(view, t, id, div().id(id).size(28).flex_none().flex().items_center().justify_center().rounded(8)
    .hover((s) => s.bg(t.hover)).on_hover(glow(view, id)).on_mouse_down("left", () => pressed(view))
    .role("button").accessibility_label(label).on_click(fn)
    .child(svg(`mods/t3-inbox/icons/${icon}.svg`).size(16).text_color(lit(id, t.dim))), 8), more);
  // The filter shows what it filters to: one avatar, two overlapping, or the plain filter icon.
  const scoped = sp.filter((s) => scope.includes(s.id)), found = view.matches();
  const choice = (s, i) => {
    const on = s.id ? scope.includes(s.id) : scope.length === 0;
    // Selection is a check badge on the icon, as in T3.
    return h_flex().id(`scope-${s.id ?? "all"}`).h(SCOPE_ROW).px(8).gap(8).flex_none().items_center().rounded(4)
      .when(i === view.scopeAt, (el) => el.bg(t.selected))
      .on_hover((over, cx) => { if (over && view.scopeAt !== i) { view.scopeAt = i; cx.notify(); } })
      .role("button").accessibility_label(s.name)
      .on_click((e, cx) => view.pick(s, e.modifiers.shift, cx))
      .child(div().relative().flex_none()
        .child(s.id ? avatar(s.id, s.name, 16) : svg("mods/t3-inbox/icons/folder.svg").size(16).text_color(t.muted))
        // T3's ring is outside its 12px badge; a border here is inside, so 16 and 2 further out.
        .when(on, (el) => el.child(h_flex().absolute().right(-6).bottom(-6).size(16).rounded_full().bg(t.accent)
          .border(2).border_color(t.popover).items_center().justify_center()
          .child(svg("mods/t3-inbox/icons/check.svg").size(8).text_color("#ffffff")))))
      .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(s.name));
  };
  // As T3's: from the button's left edge, 288 wide, out over the work column; radius 8 and rows' 4, inset 4 (its rounded-lg, rounded-sm, px-1).
  const filter = Popover.new("inbox-scope-menu").anchor("top_left").open(view.scopeOpen)
    .on_open_change((open, cx) => {
      view.scopeOpen = open;
      if (open) {
        view.scopeAt = 0;
        view.search.set_value("");
        view.search.focus();
      }
      cx.notify();
    })
    .trigger(stop(view, t, "inbox-scope", h_flex().id("inbox-scope").size(28).flex_none().items_center().justify_center().rounded(8)
      .hover((s) => s.bg(t.hover)).on_hover(glow(view, "inbox-scope"))
      .role("button").accessibility_label(scoped.length ? `Filter by space: ${scoped.map((s) => s.name).join(", ")}` : "Filter by space")
      .child(scoped.length > 1
        // T3's second mark overlaps by 4 with a 2px ring of the sidebar's color.
        ? h_flex().children(scoped.slice(0, 2).map((s, i) => i === 0 ? avatar(s.id, s.name, 14)
          : h_flex().flex_none().ml(-6).rounded(6).border(2).border_color(t.chrome).child(avatar(s.id, s.name, 14))))
        : scoped.length
          ? avatar(scoped[0].id, scoped[0].name, 16)
          : svg("mods/t3-inbox/icons/list-filter.svg").size(16).text_color(lit("inbox-scope", t.dim))), 8))
    .content(v_flex().id("inbox-scope-panel").w(288).mt(4).p(4).rounded(8)
      .bg(t.popover).border_1().border_color(t.border).shadow_lg().text_size(14)
      .on_key_down((e, cx) => {
        const to = step(e, view.scopeAt, view.matches().length);
        if (to < 0) return;
        view.scopeAt = to;
        cx.stop_propagation();
        cx.notify();
      })
      // As T3's ComboboxSearchInput: 12 in and 10 down less the 1 it shifts up, a 26 field, 6 to the rule. Its text starts 20 from
      // the icon, 4 before the names, and inside the button's left edge as the panel hangs from it.
      .child(h_flex().mx(8).mt(5).h(33).pb(6).gap(4).flex_none().items_center().border_b_1().border_color(t.border)
        .child(svg("mods/t3-inbox/icons/search.svg").size(16).flex_none().text_color(t.dim))
        .child(Input.new(view.search).flex_1().h_full().text_size(14).text_color(t.foreground)))
      .child(div().pt(5).flex_none()
        .when(found.length > 0, (el) => el.child(scrollList(view, "inbox-scope-list", { count: found.length, row: SCOPE_ROW, at: view.scopeAt, height: Math.min(found.length, SCOPE_SHOWN) * SCOPE_ROW,
          draw: (i) => choice(found[i], i), wheeled: (keep) => { view.scopeAt = keep; } })))
        .when(found.length === 0, (el) => el.child(div().p(8).text_center().line_height("20px").text_color(t.dim).child("No matching spaces.")))));
  // T3's top group: 8 in and the search field 4 before its buttons, which touch. The right edge is the brand bar's above, so the two rows of icons line up.
  const top = h_flex().id("inbox-top").h(48).px(8).gap(4).flex_none().items_center()
    // Sized as T3's search field (h-8, 16px icon, a medium 14px placeholder), but a button: it opens Go to.
    .child(stop(view, t, "inbox-search", h_flex().id("inbox-search").flex_1().h(32).px(8).gap(8).items_center().rounded(6).text_size(14).font_medium()
      .text_color(lit("inbox-search", t.dim)).hover((s) => s.bg(t.hover)).on_hover(glow(view, "inbox-search")).on_mouse_down("left", () => pressed(view))
      // Each opens over its button, before the pointer can report leaving it.
      .role("button").accessibility_label("Search").on_click((_e, cx) => { view.hot = null; const picker = props()?.picker ?? "picker"; if (!justClosed(view, `${picker}.closed`)) run("mod.open", { name: picker }); cx.notify(); })
      .child(svg("mods/t3-inbox/icons/search.svg").size(16).flex_none().text_color(lit("inbox-search", t.dim)))
      .child(div().child("Search"))))
    .child(h_flex().flex_none().items_center()
    .child(tip(view, t, "inbox-scope", "Filter by space", filter, { off: view.scopeOpen, hint: "Shift+click to pick several", below: true }))
    .child(tool("inbox-new-space", "New space", "folder-plus", (_e, cx) => {
      view.hot = null;
      // The layout's menu asks which machine, as its mod.json places it; the shipped one can't, so docked alone it's the active space's.
      const closing = justClosed(view, `${props()?.newMenu}.pickClosed`);
      if (!asks) run("space.new");
      else if (!closing) openOverlay({ mod: props().newMenu, kind: "popup", frame: "none", at: "top", offset: 96, width: 576, height: 420, props: { pick: true } });
      cx.notify();
    }, { action: asks ? null : "space.new" }))
    // The layout passes its own menu; docked alone, the shipped one.
    .child(tool("inbox-new-tab", "New tab", "square-pen", (_e, cx) => { view.hot = null; const menu = props()?.newMenu ?? "new-menu"; if (!justClosed(view, `${menu}.closed`)) run("mod.open", { name: menu }); cx.notify(); })));


  return top;
}
