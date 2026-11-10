// Worktrees of the repo you're in, through worktrunk (`wt`) so its paths and hooks apply; each worktree opens as its own space.
import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex, InputState, Input } from "gpui-base";
import { theme, spaces, panes, focused, run, exec, closeOverlay, props, home, notify } from "herdr";
import { step, scrollList } from "./list.js";

const ROW = 48;
const LIST_MAX = 420 - 2 - 48 - 8 - 28 - 8 - 41;

function placeOf(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder || null;
}

const inside = (dir, root) => Boolean(dir) && (dir === root || dir.startsWith(root + "/"));
const short = (p) => (p && p.startsWith(home()) ? "~" + p.slice(home().length) : p ?? "");
const lastLines = (r) => (r.stderr || r.stdout || "").trim().split("\n").filter(Boolean).slice(-3).join("\n");

// wt prints its JSON on stdout and its progress on stderr; the JSON is the line that parses.
function json(text) {
  for (const line of text.split("\n")) {
    try { return JSON.parse(line); } catch {}
  }
  try { return JSON.parse(text); } catch { return null; }
}

export default class Worktrunk extends View {
  init(_p, cx) {
    this.at = 0;
    this.filter = "";
    this.rows = null;
    this.input = InputState.new({ placeholder: "Switch to or create a worktree…" });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; this.confirm = null; cx.notify(); });
    this.input.on("submit", (_e, cx) => {
      const confirm = this.confirm, item = this.items()[this.at];
      // In a task: a handler's cx is dead once wt is awaited, so the list wouldn't redraw until the next key.
      cx.spawn((cx) => (confirm ? this.remove(confirm, cx) : this.choose(item, cx)));
    });
    this.input.focus();
    // keys.json can't reach it: the search field's own cmd-backspace (delete to line start) comes first, unless a binding scoped inside it.
    cx.bind_keys([{ keystroke: "cmd-backspace", action: "worktrunk_remove", context: "Worktrunk > Input" }]);
    cx.spawn(async (cx) => { await this.load(); cx.notify(); });
  }

  async load() {
    const active = spaces().find((s) => s.active);
    if (active?.machine) return (this.error = "Worktrees work on this computer only.");
    const cwd = focused()?.cwd ?? (active && placeOf(active, panes())) ?? home();
    const r = await exec("wt", ["list", "--branches", "--format=json"], { cwd });
    const data = r.code === 0 ? json(r.stdout) : null;
    if (!data) return (this.error = lastLines(r) || "Not in a git repository.");
    const items = (Array.isArray(data) ? data : data.items ?? []).filter((i) => i.branch || i.worktree?.path);
    const rows = items.map((i) => ({ branch: i.branch ?? null, path: i.worktree?.path ?? null, main: Boolean(i.worktree?.main) }));
    this.rows = [...rows.filter((r) => r.main), ...rows.filter((r) => r.path && !r.main), ...rows.filter((r) => !r.path)];
    this.main = this.rows.find((r) => r.main)?.path ?? cwd;
    this.base = data.repo?.default_branch ?? "the default branch";
    this.error = null;
  }

  // The space showing a checkout: its first terminal is in it, the deepest checkout winning.
  spaceFor(path) {
    const ps = panes(), paths = (this.rows ?? []).filter((r) => r.path).map((r) => r.path);
    return spaces().find((s) => {
      if (s.machine) return false;
      const p = placeOf(s, ps);
      return paths.filter((c) => inside(p, c)).sort((a, b) => b.length - a.length)[0] === path;
    });
  }

  items() {
    if (!this.rows) return [];
    const q = this.filter.trim(), lq = q.toLowerCase();
    const hits = this.rows.filter((r) => `${r.branch ?? ""} ${r.path ?? ""}`.toLowerCase().includes(lq));
    return q && !this.rows.some((r) => r.branch === q) ? [...hits, { create: q }] : hits;
  }

  async choose(item, cx) {
    if (!item || this.busy) return;
    if (item.path) {
      const s = this.spaceFor(item.path);
      closeOverlay(props().overlay);
      // Unnamed, so the space takes the checkout's folder name and nests under its repo.
      if (s) run("space.select", { id: s.id });
      else run("space.new", { folder: item.path });
      return;
    }
    const name = item.create ?? item.branch;
    this.busy = `${item.create ? "Creating" : "Checking out"} ${name}…`;
    this.error = null;
    cx.notify();
    const r = await exec("wt", ["switch", ...(item.create ? ["--create"] : []), name, "--no-cd", "--format=json"], { cwd: this.main });
    const path = r.code === 0 ? json(r.stdout)?.path : null;
    this.busy = null;
    if (!path) {
      this.error = lastLines(r) || `wt switch ${name} failed.`;
      cx.notify();
      return;
    }
    closeOverlay(props().overlay);
    run("space.new", { folder: path });
  }

  askRemove(item) {
    if (this.busy) return;
    if (item?.main) return (this.error = "The main checkout can't be removed.");
    if (!item?.path && !item?.branch) return (this.error = "Only a worktree or branch can be removed.");
    this.error = null;
    this.confirm = item;
  }

  async remove(item, cx) {
    this.confirm = null;
    this.busy = `Removing ${item.branch ?? short(item.path)}…`;
    cx.notify();
    // Without it a PR merged on GitHub since the last fetch looks unmerged, and wt keeps the branch.
    await exec("git", ["fetch", "--quiet", "origin"], { cwd: this.main, timeout: 15000 }).catch(() => {});
    // wt refuses uncommitted changes itself; its reason is shown as is.
    const r = await exec("wt", ["remove", "--foreground", "--format", "json", item.branch ?? item.path], { cwd: this.main });
    this.busy = null;
    if (r.code !== 0) {
      this.error = lastLines(r) || "wt remove failed.";
      // wt deletes the folder before it handles the branch, so a branch error can leave a space pointing at nothing.
      if (item.path && (await exec("test", ["-d", item.path])).code !== 0) this.closeSpacesIn(item.path);
      await this.load();
      cx.notify();
      return;
    }
    // wt exits 0 when it keeps an unmerged branch, so only its JSON says the branch is still there.
    const kept = json(r.stdout)?.[0]?.branch_outcome === "retained_unmerged";
    if (kept && !item.path) {
      this.error = `Kept ${item.branch}: it has unmerged changes.`;
      cx.notify();
      return;
    }
    if (item.path) this.closeSpacesIn(item.path);
    const title = kept ? `Removed the worktree, kept ${item.branch}: it has unmerged changes` : `Removed ${item.branch ?? short(item.path)}`;
    notify({ title, level: kept ? "info" : "success", timeout: 3000 });
    await this.load();
    this.at = Math.min(this.at, Math.max(0, this.items().length - 1));
    cx.notify();
  }

  closeSpacesIn(path) {
    const ps = panes();
    for (const s of spaces()) if (!s.machine && inside(placeOf(s, ps), path)) run("space.close", { id: s.id, confirmed: true });
  }

  row(item, i) {
    const t = theme(), on = this.at === i;
    const open = item.path && this.spaceFor(item.path);
    const title = item.create ? `Create ${item.create}` : item.branch ?? "(detached)";
    const sub = item.create ? `New branch from ${this.base}` : item.path ? short(item.path) : "Branch, no worktree yet";
    const removable = !item.main && !item.create && (item.path || item.branch);
    return h_flex().id(`wt-${i}`).w_full().h(ROW).px(8).py(6).gap(8).rounded(4).items_center().flex_none()
      .role("button").accessibility_label(title)
      .when(on, (el) => el.bg(t.selected))
      .on_hover((over, cx) => { if (over && this.at !== i) { this.at = i; cx.notify(); } })
      .on_click((_e, cx) => cx.spawn((cx) => this.choose(item, cx)))
      .child(h_flex().w(16).h(20).pt(2).self_start().flex_none().items_center().justify_center()
        .child(svg(`mods/worktrunk/icons/${item.create ? "folder-plus" : "git-branch"}.svg`).size(16).text_color(item.path ? t.muted : t.dim)))
      .child(v_flex().flex_1().min_w(0)
        .child(div().truncate().text_color(item.path || item.create ? t.foreground : t.muted).child(title))
        .child(div().truncate().text_size(12).line_height("16px").text_color(t.dim).child(sub)))
      .when(Boolean(item.main), (el) => el.child(div().flex_none().text_size(12).text_color(t.dim).child("main checkout")))
      .when(Boolean(open), (el) => el.child(div().flex_none().text_size(12).font_medium().text_color(t.muted).child("Open")))
      .when(Boolean(removable) && on, (el) => el.child(div().id(`wt-rm-${i}`).flex_none().p(4).rounded(6).text_color(t.dim)
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .tooltip(item.path ? "Remove worktree (⌘⌫)" : "Delete branch (⌘⌫)")
        .on_click((_e, cx) => { cx.stop_propagation(); this.askRemove(item); cx.notify(); })
        .child(svg("mods/worktrunk/icons/x.svg").size(14))));
  }

  render() {
    const t = theme(), items = this.items();
    const key = (label) => div().flex().flex_none().min_w(20).h(20).px(4).items_center().justify_center().rounded(4).bg(t.foreground + "14").text_size(12).text_color(t.foreground).child(label);
    const hint = (label, what) => h_flex().gap(4).items_center().children(label.split(" ").map(key)).child(what);
    const footer = this.confirm
      ? h_flex().gap(12).items_center()
        .child(div().text_color(t.blocked).child(`Remove ${this.confirm.branch ?? short(this.confirm.path)}?`))
        .child(hint("Enter", "Remove")).child(hint("Esc", "Cancel"))
      : this.busy
        ? div().text_color(t.muted).child(this.busy)
        : h_flex().gap(12).items_center()
          .child(hint("↑ ↓", "Navigate")).child(hint("Enter", "Switch")).child(hint("⌘ ⌫", "Remove")).child(hint("Esc", "Close"));
    return v_flex().id("worktrunk").size_full().min_h(0).rounded(16).border(1).border_color(t.border).bg(t.popover).shadow_2xl().text_size(14).line_height("20px")
      .key_context("Worktrunk")
      .on_action("worktrunk_remove", (_e, cx) => {
        this.askRemove(items[this.at]);
        cx.notify();
      })
      .on_key_down((e, cx) => {
        if (e.key === "escape") {
          cx.stop_propagation();
          if (this.confirm) { this.confirm = null; return cx.notify(); }
          return closeOverlay(props().overlay);
        }
        const to = step(e, this.at, items.length);
        if (to < 0) return;
        this.at = to;
        this.confirm = null;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().h(36).my(6).flex_none().pl(18).pr(20).gap(7).items_center()
        .child(svg("mods/worktrunk/icons/search.svg").size(16).flex_none().text_color(t.dim))
        .child(Input.new(this.input).flex_1().h_full().text_size(14).text_color(t.foreground)))
      .when(Boolean(this.error), (el) => el.child(div().mx(16).mt(4).px(10).py(6).rounded(6).bg(t.blocked + "1f").text_size(12).line_height("16px").text_color(t.foreground).child(this.error)))
      .child(div().mt(8).px(16).py(6).flex_none().text_size(12).line_height("16px").font_medium().text_color(t.muted).child("Worktrees"))
      .child(div().flex_none().mb(8).px(8)
        .when(items.length > 0, (el) => el.child(scrollList(this, "wt-rows", { count: items.length, row: ROW, at: this.at, height: Math.min(items.length * ROW, LIST_MAX),
          draw: (i) => this.row(items[i], i), wheeled: (keep) => { this.at = keep; } })))
        .when(items.length === 0, (el) => el.child(div().py(40).text_center().text_color(t.dim).child(this.rows ? "Type a name to create a worktree." : this.error ? "" : "Loading…"))))
      .child(h_flex().flex_none().px(16).py(10).gap(8).items_center().rounded_b(15).border_t(1).border_color(t.foreground + "12").bg(t.foreground + "06").font_medium().text_color(t.muted)
        .child(footer));
  }
}
