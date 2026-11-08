// Actions, as T3 Code's run button: commands you start with one click, kept in shared state.
// In a bar it draws "▶ Dev | ▾", sized to fit its block; the menu and the editor are this mod opened as overlays.
import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex, InputState, Input } from "gpui-base";
import { theme, run, openOverlay, closeOverlay, props, shared, setShared, home, focused, panes, spaces, settings, nextCommand } from "herdr";
import { tip, glow } from "./tip.js";
import { stopsInit, stopsEnd, stop, focusRoot, onStop, pressed, justClosed } from "./focus.js";
import { menuJump, scrollList } from "./list.js";

const MOD = "t3-actions";
// Where everyone's saved actions live: another key would lose them, whatever the mod is called.
const KEY = "t3-actions";
const MENU_CLOSED = `${MOD}.menuClosed`;
const ICONS = ["play", "test", "lint", "configure", "build", "debug"];
const PLACES = [["tab", "Tab"], ["right", "Right"], ["down", "Down"]];
const icon = (name) => svg(`mods/${MOD}/icons/action-${ICONS.includes(name) ? name : "play"}.svg`);

const lit = (view, id, color = theme().dim) => (view.hot === id ? theme().foreground : color);

// { list: [{ id, name, command, icon, place, cwd }], last: id }
const state = () => shared(KEY) ?? { list: [] };
const primary = ({ list, last }) => list.find(a => a.id === last) ?? list[0];
// The menu: a popup's height is only a maximum, so its list sets its own. REST: its padding, rule and Add action.
const MENU_MAX = 420, MENU_REST = 45;
const editor = (id) => openOverlay({ mod: MOD, kind: "dialog", frame: "none", width: 512, props: { actions: "edit", id } });

// A menu hangs 4px under the bar's 24px control, centered in its 40 (T3's MenuPopup sideOffset), under the click, not on the pointer; the app keeps it in the window.
// With no press to read (assistive tech clicks without one), the app's default: the pointer.
const underBar = (press) => press && { x: press.x - 8, y: 36 * settings().zoom };

function runAction(a) {
  setShared(KEY, { ...state(), last: a.id });
  // A mod pane (a review beside its agent) has no folder: use a terminal's in the same tab, else the space's.
  const f = focused();
  const folder = a.cwd?.startsWith("~") ? home() + a.cwd.slice(1)
    : a.cwd || f?.cwd || panes().find(p => p.tab === f?.tab && p.cwd)?.cwd || spaces().find(s => s.active)?.folder;
  // shortcut: sh -c skips your shell's aliases and functions and needs sh (not on plain Windows); run them through `zsh -ic` in the command if needed.
  run("terminal.open", { argv: ["sh", "-c", a.command], name: a.name, place: a.place ?? "tab", ...(folder ? { folder } : {}) });
}

// The answer from Delete's confirm dialog.
function deleteAction(id) {
  const s = state();
  setShared(KEY, { ...s, list: s.list.filter(x => x.id !== id) });
}

// The bar's control: "▶ Dev | ▾", or "Add action" before there is one. Outlined, not filled: a fill would read as an active tab.
function control(view, t, stopPress) {
  // A narrow bar's layout sets it (Herdr T3's bar-measure): the icon alone, the name left to the hover label. Unset, the full control.
  const s = state(), main = primary(s), compact = shared("bar.compact");
  // T3's xs outline button: its svg hangs 2px into each side, its label sits 4 on, and with the icon alone it's 24 square.
  const ends = (el, wide) => wide ? el.pl(5).pr(7).gap(4) : el.justify_center();
  const box = (id) => h_flex().id(id).h(24).flex_none().items_center().rounded(8).border(1).border_color(t.border).text_size(12).on_mouse_down("left", stopPress);
  if (!main) return tip(view, t, "action-add", "Add action", stop(view, t, "action-add", ends(box("action-add"), !compact).when(Boolean(compact), el => el.w(24)).text_color(lit(view, "action-add")).hover(st => st.bg(t.hover)).on_hover(glow(view, "action-add"))
    // The dialog covers it, before the pointer can report leaving it.
    .role("button").accessibility_label("Add action").on_click((_e, cx) => { view.hot = null; editor(null); cx.notify(); })
    .child(svg("mods/t3-actions/icons/plus.svg").size(14)).when(!compact, el => el.child("Add action")), 8), { below: true });
  return box("actions").text_color(t.dim)
    // 22, the outline's inside: a hover card's wrapper has no height for h_full to fill.
    .child(tip(view, t, "action-run", `Run ${main.name}`, stop(view, t, "action-run", ends(h_flex().id("action-run").h(22).items_center().rounded_l(8), !compact).when(Boolean(compact), el => el.w(23)).text_color(lit(view, "action-run")).hover(st => st.bg(t.hover)).on_hover(glow(view, "action-run"))
      .role("button").accessibility_label(`Run ${main.name}`).on_click(() => runAction(main))
      .child(icon(main.icon).size(14)).when(!compact, el => el.child(div().max_w(140).truncate().child(main.name))), 8), { below: true }))
    .child(div().w(1).h(22).flex_none().bg(t.border))
    .child(tip(view, t, "action-more", "Actions", stop(view, t, "action-more", div().id("action-more").h(22).w(23).flex().items_center().justify_center().rounded_r(8).text_color(lit(view, "action-more")).hover(st => st.bg(t.hover)).on_hover(glow(view, "action-more"))
      .role("button").accessibility_label("Actions").on_click((_e, cx) => {
        view.hot = null; // The menu covers it, before the pointer can report leaving it.
        if (!justClosed(view, MENU_CLOSED)) openOverlay({ mod: MOD, kind: "popup", at: underBar(view.actionPress), width: 280, height: Math.min(MENU_MAX, MENU_REST + s.list.length * 28), props: { actions: "menu" } });
        cx.notify();
      })
      .on_mouse_down("left", (e, cx) => { view.actionPress = e.position; pressed(view); stopPress(e, cx); })
      .child(svg("mods/t3-actions/icons/chevron-down.svg").size(16)), 8), { below: true }));
}

// The menu takes the keyboard, as the shipped menu does.
function initMenu(view, cx) {
  view.at = 0;
  view.keys = cx.focus_handle();
  view.keys.focus();
  stopsInit(view, cx, "modal");
}

function menu(view) {
  const t = theme(), { list } = state(), done = () => closeOverlay(props().overlay);
  const picks = [...list.map(a => () => runAction(a)), () => editor(null)];
  const labels = [...list.map(a => a.name), "Add action"];
  const row = (id, at, i, label) => h_flex().id(id).h(28).px(8).gap(8).rounded(4).items_center().flex_none()
    .text_color(t.foreground).when(view.at === at, el => el.bg(t.selected))
    .role("button").accessibility_label(label)
    .on_hover((on, cx) => { if (on && view.at !== at) { view.at = at; cx.notify(); } })
    .on_click(() => { done(); picks[at](); })
    .child(i).child(div().flex_1().min_w(0).truncate().child(label));
  return focusRoot(view, v_flex().id("actions-menu").size_full().min_h(0).p(4).bg(t.popover).text_size(14)
    .track_focus(view.keys).on_key_down((e, cx) => {
      // On a row's Edit, Enter is Edit's.
      if (e.key === "enter") { if (onStop(view)) return; done(); picks[view.at](); }
      else if (e.key === "escape") done();
      else {
        const to = menuJump(view, e, labels, view.at);
        if (to < 0) return;
        view.at = to;
      }
      cx.stop_propagation();
      cx.notify();
    })
    // Add action stays outside the list, always in view: with it lit, nothing here is.
    .child(scrollList(view, "actions-list", { count: list.length, row: 28, height: Math.min(list.length * 28, MENU_MAX - MENU_REST), at: view.at < list.length ? view.at : -1, wheeled: (keep) => { if (keep >= 0) view.at = keep; }, draw: (at) => { const a = list[at]; return row(`action-${a.id}`, at, icon(a.icon).size(16).mx(-2).text_color(t.muted), a.name)
        .child(tip(view, t, `edit-${a.id}`, `Edit ${a.name}`, stop(view, t, `edit-${a.id}`, div().id(`edit-${a.id}`).size(24).flex_none().flex().items_center().justify_center().rounded(8).text_color(lit(view, `edit-${a.id}`))
          .hover(s => s.bg(t.raised)).on_hover(glow(view, `edit-${a.id}`)).role("button").accessibility_label(`Edit ${a.name}`)
          .on_click((_e, cx) => { cx.stop_propagation(); done(); editor(a.id); })
          .child(svg("mods/t3-actions/icons/settings.svg").size(14)), 8), { below: true })); } }))
    .child(div().h(1).mx(8).my(4).flex_none().bg(t.border))
    .child(row("action-new", list.length, svg("mods/t3-actions/icons/plus.svg").size(16).mx(-2).text_color(t.muted), "Add action")));
}

// The editor dialog: this copy's own inputs, made once in init.
function initEditor(view, cx) {
  stopsInit(view, cx, "modal");
  const a = state().list.find(x => x.id === props().id);
  view.action = a;
  view.icon = a?.icon ?? "play";
  view.place = a?.place ?? "tab";
  view.inputs = [["name", "Dev"], ["command", "bun run dev"], ["cwd", "Focused terminal's folder"]].map(([k, placeholder]) => {
    const input = InputState.new({ placeholder, value: a?.[k] ?? "" });
    input.on("change", (_e, cx) => cx.notify());
    input.on("submit", () => saveEditor(view));
    return [k, input];
  });
  view.inputs[0][1].focus();
}

function saveEditor(view) {
  const v = Object.fromEntries(view.inputs.map(([k, input]) => [k, input.value().trim()]));
  if (!v.name || !v.command) return;
  const s = state(), id = view.action?.id ?? Date.now().toString(36);
  const next = { id, name: v.name, command: v.command, icon: view.icon, place: view.place, ...(v.cwd ? { cwd: v.cwd } : {}) };
  setShared(KEY, { ...s, list: view.action ? s.list.map(x => x.id === id ? next : x) : [...s.list, next] });
  closeOverlay(props().overlay);
}

// T3's dialog: 512 wide (max-w-lg) and as tall as its content. Its 16px corners are more than the app's frame has, so it opens frame: "none" and draws them.
const dialog = (id, t) => v_flex().id(id).size_full().relative().rounded(16).border(1).border_color(t.border).bg(t.popover).shadow_2xl().text_size(14).line_height("20px");
const dialogTitle = (t, text) => div().text_size(20).line_height("27.5px").font_semibold().text_color(t.foreground).child(text);
// T3's default button, 32 high: 11 in from its 1px border.
const dialogButton = (view, t, id, text, el) => stop(view, t, id, el.id(id).h(32).px(11).flex_none().items_center().rounded(8).border_1().font_medium()
  .cursor_pointer().hover(s => s.opacity(0.88)).role("button").accessibility_label(text).child(text), 8);

function editorView(view) {
  const t = theme(), done = () => closeOverlay(props().overlay);
  const [name, command] = view.inputs.map(([, input]) => input.value().trim());
  const ok = Boolean(name && command);
  const label = (text) => div().line_height("16px").font_medium().text_color(t.foreground).child(text);
  const field = ([k, input]) => v_flex().gap(6).child(label({ name: "Name", command: "Command", cwd: "Folder (optional)" }[k]))
    .child(h_flex().h(32).px(11).rounded(8).border(1).border_color(t.border).bg(t.input).items_center()
      .child(Input.new(input).flex_1().h_full().text_size(14).text_color(t.foreground)));
  // T3's sm toggle: 28 at least, with 6 either side of its words.
  const choice = (id, on, pick, name, child) => stop(view, t, id, h_flex().id(id).h(28).min_w(28).px(6).rounded(8).items_center().justify_center().font_medium()
    .bg(on ? t.selected : t.input).text_color(lit(view, id, on ? t.foreground : t.dim)).on_hover(glow(view, id))
    .role("button").accessibility_label(name)
    .on_click((_e, cx) => { pick(); cx.notify(); }).child(child), 8);
  const button = (id, text, primary, act) => {
    const on = primary && ok;
    return dialogButton(view, t, id, text, h_flex().border_color(on ? t.solid : t.input)
      .bg(on ? t.solid : t.raised).text_color(on ? t.solid_foreground : primary ? t.dim : t.foreground).on_click(act));
  };
  return focusRoot(view, dialog("action-editor", t)
    .child(div().p(24).pb(12).child(dialogTitle(t, view.action ? "Edit action" : "Add action")))
    // T3's close: 32 square, 8 in from the corner.
    .child(stop(view, t, "action-close", div().id("action-close").absolute().top(8).right(8).size(32).flex().items_center().justify_center().rounded(8)
      .text_color(lit(view, "action-close")).hover(s => s.bg(t.hover)).on_hover(glow(view, "action-close"))
      .role("button").accessibility_label("Close").on_click(done).child(svg("mods/t3-actions/icons/x.svg").size(16)), 8))
    .child(v_flex().px(24).py(4).gap(16)
      .children(view.inputs.map(field))
      .child(h_flex().gap(16)
        .child(v_flex().gap(6).child(label("Icon")).child(h_flex().gap(2).children(ICONS.map(i =>
          choice(`icon-${i}`, view.icon === i, () => { view.icon = i; }, `Icon: ${i}`, icon(i).size(16)).px(0)))))
        .child(v_flex().gap(6).child(label("Run in")).child(h_flex().gap(2).children(PLACES.map(([p, text]) =>
          choice(`place-${p}`, view.place === p, () => { view.place = p; }, `Run in: ${text}`, text)))))))
    // As T3's editor: its footer is the bare kind, with no rule.
    .child(h_flex().mt_auto().px(24).py(16).gap(8).items_center()
      .when(Boolean(view.action), el => el.child(dialogButton(view, t, "action-delete", "Delete", h_flex().border_color(t.input).text_color(t.ansi1).on_click(() => {
          done();
          openOverlay({ mod: MOD, kind: "dialog", frame: "none", width: 512, props: {
            actions: "confirm",
            title: `Delete ${view.action.name}?`,
            detail: "This removes the action and can't be undone.",
            command: { name: `${MOD}.delete-action:${view.action.id}` },
          } });
        }))))
      .child(div().flex_1())
      .child(button("action-cancel", "Cancel", false, done))
      .child(button("action-save", "Save", true, () => saveEditor(view)))));
}

// T3's alert dialog, for what the shipped confirm mod would ask: props { title, detail, command: { name, args } }. Enter confirms, Esc cancels.
function initConfirm(view, cx) {
  view.ask = cx.focus_handle();
  view.ask.focus();
  stopsInit(view, cx, "modal");
}

// T3 writes white on its red, but a theme's red may be too pale for that (Catppuccin Mocha's, 2.3:1): whichever of white and the theme's background reads better.
const luminance = (c) => [1, 3, 5].map((i) => parseInt(c.slice(i, i + 2), 16) / 255).map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4)).reduce((sum, v, i) => sum + v * [0.2126, 0.7152, 0.0722][i], 0);
const contrast = (a, b) => { const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x); return (hi + 0.05) / (lo + 0.05); };
const onRed = (t) => (contrast(t.ansi1, "#ffffff") >= contrast(t.ansi1, t.background) ? "#ffffff" : t.background);

function confirmView(view) {
  const t = theme(), p = props() ?? {}, done = () => closeOverlay(p.overlay);
  const yes = () => { done(); run(p.command.name, p.command.args ?? {}); };
  return focusRoot(view, dialog("action-confirm", t).track_focus(view.ask)
    .on_key_down((e, cx) => {
      // On a button, Enter is the button's.
      if (e.key === "enter") { if (onStop(view)) return; yes(); }
      else if (e.key === "escape") done();
      else return;
      cx.stop_propagation();
    })
    .child(v_flex().p(24).gap(8).min_h(0)
      .child(dialogTitle(t, p.title ?? "Are you sure?"))
      .child(div().id("confirm-detail").max_h(384).overflow_y_scrollbar().text_color(t.muted).child(p.detail ?? "")))
    .child(h_flex().mt_auto().px(24).py(16).gap(8).items_center().justify_end().rounded_b(15).border_t(1).border_color(t.border).bg(t.foreground + "06")
      .child(dialogButton(view, t, "confirm-no", "Cancel", h_flex().border_color(t.input).bg(t.raised).text_color(t.foreground).on_click(done)))
      .child(dialogButton(view, t, "confirm-yes", "Confirm", h_flex().border_color(t.ansi1).bg(t.ansi1).text_color(onRed(t)).on_click(yes)))));
}

export default class Actions extends View {

  init(_props, cx) {
    const overlay = props()?.actions;
    if (overlay === "edit") initEditor(this, cx);
    if (overlay === "menu") initMenu(this, cx);
    if (overlay === "confirm") initConfirm(this, cx);
    if (!overlay) stopsInit(this, cx);
    // The bar's copy answers Delete's dialog: `t3-actions.delete-action:<id>`.
    if (!overlay) cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        if (command.startsWith("delete-action:")) deleteAction(command.slice("delete-action:".length));
      }
    });
  }

  close() {
    stopsEnd(this);
    if (this.keys) setShared(MENU_CLOSED, Date.now());
  }

  render() {
    const overlay = props()?.actions;
    if (overlay === "menu") return menu(this);
    if (overlay === "edit") return editorView(this);
    if (overlay === "confirm") return confirmView(this);
    const stopPress = (_e, cx) => cx.stop_propagation(), home = shared("t3-home.space");
    return focusRoot(this, h_flex().size_full().items_center().justify_end()
      // Home has no project to run them in.
      .when(!home || !spaces().some(s => s.active && s.id === home), el => el.child(h_flex().id("actions-fit").flex_none().pr(8).items_center().on_size_change((size) => this.fit(size)).child(control(this, theme(), stopPress)))));
  }

  // With the block's id in props.block, it sizes that block to the control: layout.resize, which Herdr keeps with the
  // layout's clicks. on_size_change reports zoomed pixels; a layout's are logical.
  fit(size) {
    const id = props()?.block, px = Math.ceil(size.width / (Number(settings()?.zoom) || 1));
    if (!id || px === this.fitted) return;
    this.fitted = px;
    run("layout.resize", { id, px });
  }
}
