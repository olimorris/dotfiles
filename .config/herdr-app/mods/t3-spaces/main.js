// Workspace spaces: stable colored avatars, worktrees under their checkout,
// grouped by machine when more than one is known. After a space's name, the repo
// its first terminal is in now, only where unusual: branch, ahead/behind. Agent state lives in the agents list, not here. Click to
// switch, right-click for its menu, drag to reorder.

import { View, div, svg } from "gpui-kit";
import { foldArrow, planMotion, flying, leavingRows } from "./motion.js";
import { v_flex, h_flex } from "gpui-base";
import { spaces, machines, panes, run, openOverlay, exec, hc, theme, shared, setShared, watchFolder, window, props, layout, nextCommand } from "herdr";
import { projectMark, placeOf, tint } from "./project.js";
import { dragGone, glow, tip, tipMark, POINTER_WATCH, pointerMoved } from "./tip.js";
import { stopsInit, stopsEnd, stop, focusRoot, enter, pressed, justClosed } from "./focus.js";

// Where a space is now. `ps`: panes(), read once by the caller (each read copies every pane).
const where = (s, ps) => JSON.stringify([s.machine ?? null, placeOf(s, ps)]);
const base = (path) => path.replace(/\/+$/, "").split("/").pop();

// Changes made outside Herdr (an editor's save, a commit in another app): looked
// for this often, in repos the list shows, while the window is in front.
const FALLBACK = 60000;
// How long a checkout being opened may take to show up before it's asked for again.
const OPENING = 5000;
// T3's project row, and its list's 1px between items (gap-px). A drag's math goes by the pitch.
const ROW = 32, STACK = 1, PITCH = ROW + STACK;
const find = (n, id) => n?.id === id ? n : (n?.children ?? []).map((c) => find(c, id)).find(Boolean);
// Docked alone there's no Inbox to be behind.
const listInView = (root = layout()) => find(root, "sidebar-lists")?.active !== "inbox" && !find(root, "sidebar")?.hidden;

export default class Spaces extends View {
  async close() { stopsEnd(this); }

  init(_props, cx) {
    stopsInit(this, cx);
    // pane.go onto this list (mod.json's "focusable"): the keyboard starts at the heading's button.
    cx.spawn(async (cx) => {
      for (;;) if (await nextCommand() === "focus") enter(this, cx, "space-new");
    });
    this.git = {}; // where() -> { name, branch, ahead, behind, repo, linked }, null: not a repo
    this.lastGit = {}; // space -> its git where it last had an answer; kept for one that's gone, as its machine may bring it back
    this.opening = new Map(); // repo -> when its checkout was opened from its dim row
    this.checked = {}; // where() -> when it was last looked at
    this.unsure = new Set(); // where()s git couldn't answer for (a machine away)
    this.pending = new Set(); // where()s to look at next
    this.refreshing = new Set(); // machines being looked at
    this.busy = {}; // pane -> an agent working or a program in front of its shell
    this.ready = {}; // machine -> its layout was readable at the last look
    this.at = {}; // space -> its where() at the last look
    this.watching = new Map(); // local repos' git folders -> their watch's own token
    // Spaces made while this runs wait (at most a moment) for their git, so a
    // worktree appears under its repo instead of jumping there.
    this.shown = new Set(spaces().map((s) => s.id));
    this.born = {};
    this.drag = null; // { id, key, at, top, moved, dy, y, slot, drawn }: a pressed row, lifted once it moves 6px
    this.machines = [];
    this.reconnecting = JSON.parse(localStorage.getItem("machines.reconnecting") ?? "{}");
    for (const state of Object.values(this.reconnecting)) state.busy = false;
    this.folded = new Set(JSON.parse(localStorage.getItem("machines.folded") ?? "[]"));
    this.foldedRepos = new Set(JSON.parse(localStorage.getItem("repos.folded") ?? "[]"));
    this.machinesSeen = this.machinesNow();
    this.refreshMachines(cx);
    cx.timer.every(15000, cx => this.refreshMachines(cx));
    // `git status` walks the whole tree, on another machine a process there:
    // only when its answer could have changed (see `due`).
    cx.timer.every(250, (cx) => this.checkNew(cx));
  }

  machinesNow() {
    return JSON.stringify(machines().map((m) => [m.name, m.layout]));
  }

  checkNew(cx) {
    const now = Date.now();
    const sp = spaces();
    // A machine came or went: its heading needn't wait for the next poll.
    const seen = this.machinesNow();
    if (seen !== this.machinesSeen) {
      this.machinesSeen = seen;
      this.refreshMachines(cx);
    }
    const due = this.due(now, sp, panes());
    if (due.size) this.refreshGit(due, cx);
    if (sp.some((s) => !this.shown.has(s.id)) || this.orderingDue(now)) cx.notify();
  }

  // Places whose git could have changed: new ones (a new space, a cd), where a
  // command or an agent's turn just ended (a checkout, a commit, edits), those on
  // a machine that is back, and repos in view whose fallback is due.
  due(now, sp, ps) {
    // Moved there: what it knew of that place may be old.
    const at = {};
    for (const s of sp) at[s.id] = where(s, ps);
    const keys = new Set(Object.values(at).filter((k) => JSON.parse(k)[1]));
    // Where no space is any more: forgotten, so a commit looks only where spaces are and a repo none is in isn't watched.
    for (const k of Object.keys(this.git)) if (!keys.has(k)) { delete this.git[k]; delete this.checked[k]; this.unsure.delete(k); }
    // Not while a place is unanswered: a cd within a repo would let it go and watch it again.
    if ([...keys].every((k) => k in this.git)) {
      const used = new Set(Object.values(this.git).filter(Boolean).map((g) => JSON.parse(g.repo)).filter(([on]) => !on).map(([, repo]) => repo));
      for (const repo of this.watching.keys()) if (!used.has(repo)) this.watching.delete(repo);
    }
    const due = new Set([...keys].filter((k) => !(k in this.git) && !(k in this.checked)));
    for (const [id, k] of Object.entries(at)) if (this.at[id] && this.at[id] !== k && keys.has(k)) due.add(k);
    this.at = at;
    const spaceOf = {};
    for (const s of sp) for (const t of s.tabs ?? []) spaceOf[t.id] = s;
    const busy = {};
    for (const p of ps) {
      if (!p.terminal || !spaceOf[p.tab]) continue;
      busy[p.pane] = p.status === "working" || !(p.program?.shell || p.program?.agent);
      if (this.busy[p.pane] && !busy[p.pane]) this.sameRepo(at[spaceOf[p.tab].id], keys).forEach((k) => due.add(k));
    }
    this.busy = busy;
    for (const m of machines()) {
      const ready = m.layout === "ready";
      if (ready && this.ready[m.name] === false) for (const k of keys) if (JSON.parse(k)[0] === m.name) due.add(k);
      this.ready[m.name] = ready;
    }
    if (window().active && listInView()) {
      for (const k of keys) {
        const asks = this.git[k] || this.unsure.has(k);
        if (asks && !this.folded.has(JSON.parse(k)[0]) && now - (this.checked[k] ?? 0) > FALLBACK) due.add(k);
      }
    }
    return due;
  }

  // `key` and the other places in its repo (a commit there moves their ahead/behind).
  sameRepo(key, keys) {
    const repo = this.git[key]?.repo;
    return [key, ...(repo ? [...keys].filter((k) => this.git[k]?.repo === repo) : [])];
  }

  refreshMachines(cx) {
    cx.spawn(async cx => {
      try {
        const r = await hc(["machine", "ls", "--json"]);
        if (r.code === 0) {
          this.machines = JSON.parse(r.stdout).machines ?? [];
          // Connected some other way (Add machine, hc machine add): no repair is left to hide its spaces behind.
          const fixed = this.machines.filter((m) => m.state === "connected" && this.reconnecting[m.name] && !this.reconnecting[m.name].busy);
          for (const m of fixed) delete this.reconnecting[m.name];
          if (fixed.length) localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
        }
      } catch {}
      cx.notify();
    });
  }

  rebuilt(machine) {
    return machine?.state === "unreachable" && /^a different core answers there \("[^"]+"\)$/.test(machine.why ?? "");
  }

  reconnect(machine, cx) {
    const name = machine.name;
    if (this.reconnecting[name]?.busy) return;
    const state = this.reconnecting[name] ??= { machine, removed: false };
    state.busy = true;
    state.error = null;
    localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
    cx.notify();
    cx.spawn(async cx => {
      try {
        const ask = async args => {
          const r = await hc([...args, "--json"]);
          if (r.code !== 0) {
            let error;
            try { error = JSON.parse(r.stdout || r.stderr).error?.message; } catch {}
            throw new Error(error || r.stderr || r.stdout || "Couldn't connect.");
          }
        };
        if (!state.removed) {
          await ask(["machine", "rm", name]);
          state.removed = true;
          localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
        }
        const args = ["machine", "add"];
        if (machine.via) args.push("--via", machine.target);
        else args.push(machine.target);
        args.push("--name", name);
        if (machine.session) args.push("--session", machine.session);
        if (machine.temporary) args.push("--temp");
        await ask(args);
        this.folded.delete(name);
        localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
        delete this.reconnecting[name];
      } catch (e) {
        state.error = String(e.message ?? e);
        state.busy = false;
      }
      localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
      this.refreshMachines(cx);
      cx.notify();
    });
  }

  // One look at a time on each machine, so one that hangs holds up only its own places; each place once however often it was asked for meanwhile.
  refreshGit(keys, cx) {
    const now = Date.now(), machineOf = (k) => JSON.parse(k)[0];
    for (const k of keys) { this.pending.add(k); this.checked[k] = now; }
    for (const on of new Set([...this.pending].map(machineOf))) {
      if (this.refreshing.has(on)) continue;
      this.refreshing.add(on);
      cx.spawn(async (cx) => {
        for (let key; (key = [...this.pending].find((k) => machineOf(k) === on));) {
          this.pending.delete(key);
          await this.check(key, cx);
        }
        this.refreshing.delete(on);
        cx.notify();
      });
    }
  }

  // One place's git: branch, ahead/behind, its repo.
  async check(key, cx) {
    const [on, cwd] = JSON.parse(key);
    try {
      // No optional locks: a status that touched the index would wake the watch again.
      // Writes nothing under .git (index lock, fsmonitor cookie): watch() would wake on it.
      const r = await exec("git", ["--no-optional-locks", "-c", "core.fsmonitor=false", "status", "--porcelain=v2", "--branch"], { cwd, on });
      this.unsure.delete(key); // Only now: until it answers, what it couldn't say stays unsaid.
      if (r.code !== 0) {
        // Only git's own "no" is remembered as no repo; anything else is asked again.
        if (!/not a git repository/i.test(r.stderr)) this.unsure.add(key);
        this.git[key] = null;
        return;
      }
      // The repo's own .git folder names it; a worktree's top differs from it.
      const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on });
      const common = await exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd, on });
      const repo = common.stdout.trim();
      let name = repo.endsWith("/.git") ? base(repo.slice(0, -5)) : base(repo).replace(/\.git$/, "");
      // A checkout in <repo>/main, beside its worktrees, is named for the repo, not its branch.
      if (/^(main|master|trunk)$/.test(name) && repo.endsWith("/.git")) name = base(repo.slice(0, -5).replace(/\/[^/]+$/, ""));
      const info = { name, branch: null, ahead: 0, behind: 0, repo: JSON.stringify([on, repo]), linked: repo !== `${top.stdout.trim()}/.git` };
      for (const line of r.stdout.split("\n")) {
        if (line.startsWith("# branch.head ")) info.branch = line.slice(14);
        else if (line.startsWith("# branch.ab ")) {
          const [a, b] = line.slice(12).split(" ");
          info.ahead = Math.abs(parseInt(a, 10)) || 0;
          info.behind = Math.abs(parseInt(b, 10)) || 0;
        }
      }
      this.git[key] = info;
      if (!on) this.watch(repo, cx);
    } catch {
      // Couldn't ask (the machine is away): keep what it showed, look again later.
      this.git[key] ??= null;
      this.unsure.add(key);
    }
  }

  watch(repo, cx) {
    if (this.watching.has(repo)) return;
    // A wait can't be taken back: a repo let go and watched again has a new loop, and the old one, on waking, ends here.
    const token = {};
    this.watching.set(repo, token);
    cx.spawn(async (cx) => {
      try {
        while (this.watching.get(repo) === token) {
          await watchFolder(repo);
          const mine = JSON.stringify([null, repo]);
          if (this.watching.get(repo) === token) this.refreshGit(Object.keys(this.git).filter((k) => this.git[k]?.repo === mine), cx);
        }
      } catch { if (this.watching.get(repo) === token) this.watching.delete(repo); }
    });
  }

  menu(w) {
    // A popup is as tall as its items; height is only the most.
    openOverlay({ mod: "t3-menu", kind: "popup", width: 220, height: 260, props: { tab: "space", target: { id: w.id } } });
  }

  orderingDue(now) {
    return this.ordering && now - this.ordering.at >= 1000
      && this.ordering.machines.every(name => machines().some(m => m.name === name && m.layout === "ready"));
  }

  // Spaces in order, each worktree space moved under its main checkout's.
  ordered() {
    const sp = spaces(), ps = panes();
    const ready = (w) => this.shown.has(w.id) || where(w, ps) in this.git || Date.now() - (this.born[w.id] ??= Date.now()) > 1500;
    for (const w of sp) if (!this.shown.has(w.id) && ready(w)) this.shown.add(w.id);
    // Home stays in the model's order below, so the moves count it, but it's no one's checkout and has no row.
    const homeId = shared("t3-home.space");
    // A place not asked about yet (a cd just now) isn't "not a repo": it stays as it was, or this frame reorders the model for good.
    const gitOf = (w) => {
      const k = where(w, ps);
      if (this.git[k] || (k in this.git && !this.unsure.has(k))) this.lastGit[w.id] = this.git[k];
      return this.lastGit[w.id] ?? null;
    };
    const list = sp.map((w, i) => ({ w, i, g: w.id === homeId ? null : gitOf(w) }));
    const mains = new Set(list.filter((r) => r.g && !r.g.linked).map((r) => r.g.repo));
    const worktrees = (repo) => list.filter((k) => k.g?.linked && k.g.repo === repo);
    // A checkout just opened from its dim row arrives last: it takes that row's place, so the group doesn't jump to the list's end.
    for (const [repo, at] of this.opening) {
      const main = list.findIndex((r) => r.g && !r.g.linked && r.g.repo === repo);
      const first = list.findIndex((r) => r.g?.linked && r.g.repo === repo);
      if (main >= 0 && first >= 0 && main > first) list.splice(first, 0, list.splice(main, 1)[0]);
      else if (main >= 0 || Date.now() - at > OPENING) this.opening.delete(repo);
    }
    // Grouped by repo, as T3's projects, so closing a checkout doesn't scatter its worktrees. One alone still nests, as the herdr CLI did.
    const nested = (r) => r.g?.linked;
    const out = [];
    const placed = new Set(); // repos whose worktrees are listed (under the first of its spaces)
    const hang = (top) => {
      const kids = worktrees(top.g.repo), folded = this.foldedRepos.has(top.g.repo);
      // Closed, the one you're on still shows, as T3's route row, and the count leaves it out.
      const keep = (k) => folded && k.w.active;
      top.kids = kids.length;
      top.members = kids.map((k) => k.w.id); // folded ones too: a drop's index counts them
      top.hiding = kids.filter((k) => !keep(k)).length;
      kids.forEach((k, n) => out.push({ ...k, folded: folded && !keep(k), tree: folded || n === kids.length - 1 ? "└─" : "├─" }));
    };
    for (const r of list) {
      if (nested(r)) {
        if (mains.has(r.g.repo) || placed.has(r.g.repo)) continue;
        placed.add(r.g.repo);
        // Its checkout isn't a space: a row stands for it, where its first worktree was. No .git folder (a bare repo): nothing to open.
        const [, common] = JSON.parse(r.g.repo);
        const head = { head: true, g: r.g, w: { id: `repo-${r.g.repo}`, name: r.g.name, machine: r.w.machine ?? null, folder: common.endsWith("/.git") ? common.slice(0, -5) : null } };
        out.push(head);
        hang(head);
        continue;
      }
      const top = { ...r, tree: null, kids: 0 };
      out.push(top);
      if (!r.g || r.g.linked || placed.has(r.g.repo)) continue;
      placed.add(r.g.repo);
      hang(top);
    }
    // space.next/prev and ctrl-N follow the model, so it keeps the rows' order, folded rows included: folding moves nothing. A row with no space isn't in it.
    // Simulate the batch so later indexes include earlier moves. An attempted write can lose a sync conflict: let its echo settle before retrying.
    const real = out.filter((r) => !r.head);
    const order = sp.map(w => w.id);
    const target = real.map(r => r.w.id);
    const key = JSON.stringify([order, target, machines()]);
    if (order.every((id, i) => id === target[i])) {
      this.ordering = null;
    } else if (this.ordering?.key !== key || this.orderingDue(Date.now())) {
      const moved = new Set();
      this.ordering = { key, at: Date.now(), machines: [] };
      for (let i = 0; i < real.length; i++) {
        const from = order.indexOf(real[i].w.id);
        if (from === i) continue;
        run("space.move", { id: real[i].w.id, index: i + 1 });
        moved.add(real[i].w.machine ?? null);
        order.splice(i, 0, order.splice(from, 1)[0]);
      }
      this.ordering.machines = [...moved];
    }
    return out.filter(r => (r.head || this.shown.has(r.w.id)) && !r.folded && r.w.id !== homeId);
  }

  toggleRepo(repo, cx) {
    this.foldedRepos.has(repo) ? this.foldedRepos.delete(repo) : this.foldedRepos.add(repo);
    localStorage.setItem("repos.folded", JSON.stringify([...this.foldedRepos]));
    cx.notify();
  }


  // The list's rows, each { key, h, el, ghost, m (its machine), r (a space's or repo's row) }; ghost() draws one
  // without the ids, handlers and labels the list uses.
  grouped(t) {
    const rows = this.ordered(), ps = panes(), lifting = Boolean(this.drag?.moved);
    const draw = (r, ghost) => r.head ? this.repoHead(r, t, ps, ghost) : this.row(r, t, ps, ghost);
    const entry = (r) => ({ key: r.head ? r.w.id : `space-${r.w.id}`, h: PITCH, m: r.w.machine ?? null, r, el: draw(r), ghost: () => draw(r, true) });
    const plain = (key, m, draw) => ({ key, h: PITCH, m, el: draw(false), ghost: () => draw(true) });
    const remote = [...new Set([...rows.map(r => r.w.machine).filter(Boolean), ...this.machines.filter(m => !m.temporary).map(m => m.name), ...Object.keys(this.reconnecting)])].sort();
    const loading = m => {
      const layout = machines().find(k => k.name === m)?.layout;
      return layout === "loading" || (!layout && this.machines.some(k => k.name === m && k.state === "connected"))
        || spaces().some(s => (s.machine ?? null) === m && !this.shown.has(s.id));
    };
    const loadingRow = m => plain(`machine-loading-${m ?? "local"}`, m, ghost => div().when(!ghost, el => el.id(`machine-loading-${m ?? "local"}`))
      .h(ROW).flex_none().px(10).flex().items_center().text_color(t.dim).child("Loading…"));
    if (!remote.length) return loading(null) && !rows.length ? [loadingRow(null)] : rows.map(entry);
    const machineNames = [null, ...remote];
    return machineNames.flatMap((m) => {
      const mine = rows.filter((r) => (r.w.machine ?? null) === m);
      const repair = this.reconnecting[m];
      const machine = this.machines.find(k => k.name === m) ?? repair?.machine;
      const connected = !m || machine?.state === "connected";
      const rebuilt = this.rebuilt(machine) || !!repair;
      const folded = this.folded.has(m);
      const id = m ?? "local";
      // Drawn as the agents list's shelves, T3's: 2 and 8 in, the chevron at the row's end and its + as T3's folder has it, 24 and 2 before.
      const head = h_flex().id(`machine-${id}`).h(ROW).flex_none().mx(2).px(8).gap(8).items_center()
        .text_size(12).font_medium().text_color(t.dim)
        .role("button").accessibility_label(`${folded ? "Expand" : "Collapse"} ${m ?? "This computer"}`)
        .on_hover((on, cx) => {
          // By the row's id: this computer's m is null, which a cleared field would equal.
          if (on) this.overMachine = `machine-${id}`;
          else if (this.overMachine === `machine-${id}`) this.overMachine = null;
          cx.notify();
        })
        .on_click((_e, cx) => {
          folded ? this.folded.delete(m) : this.folded.add(m);
          localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
          cx.notify();
        })
        // -1: the glyph's own inset, so its edge meets the heading and the spaces' marks.
        .child(svg(`mods/t3-spaces/icons/${m ? "server" : "monitor"}.svg`).size(14).ml(-1).flex_none())
        // The dot describes the machine, so it follows its name, however short.
        .child(h_flex().flex_1().min_w(0).gap(8).items_center()
          .child(div().min_w(0).truncate().child(m ?? "This computer"))
          .child(tipMark(this, t, `machine-state-${id}`, connected ? "Connected" : (machine?.state ?? "asleep").replace(/_/g, " ").replace(/^./, c => c.toUpperCase()), div().size(6).rounded_full().flex_none().bg(connected ? t.ansi2 : t.dim))))
        .when(!connected && !rebuilt, el => el.child(div().flex_none().child((machine?.state ?? "asleep").replace(/_/g, " "))))
        .when(rebuilt, el => el.child(h_flex().flex_none().gap(4).items_center()
          .child(div().max_w(140).truncate().child(repair?.error || "rebuilt ·"))
          .child(tip(this, t, `machine-connect-${m}`, `Connect ${m}`, stop(this, t, `machine-connect-${m}`, div().id(`machine-connect-${m}`).text_color(repair?.error ? t.blocked : t.muted)
            .hover(s => s.text_color(t.foreground)).on_hover(glow(this, `machine-connect-${m}`))
            .role("button").accessibility_label(`Connect ${m}`)
            .on_click((_e, cx) => { cx.stop_propagation(); this.reconnect(machine, cx); })
            .child(repair?.busy ? "Connecting…" : "Connect"), 4)))))
        .child(h_flex().flex_none().gap(2).items_center()
          .when(connected, el => el.child(tip(this, t, `machine-add-${id}`, "New space here", stop(this, t, `machine-add-${id}`, div().id(`machine-add-${id}`).size(24).flex_none().flex().items_center().justify_center().rounded(8)
            .text_color(this.hot === `machine-add-${id}` ? t.foreground : t.dim).on_hover(glow(this, `machine-add-${id}`))
            .role("button").accessibility_label("New space here")
            .on_click((_e, cx) => { cx.stop_propagation(); run("space.new", { machine: m ?? "" }); }).child(svg("mods/t3-spaces/icons/plus.svg").size(14)), 8),
            // The key makes a space on the current space's machine: it names this + only on that one.
            { action: (spaces().find(s => s.active)?.machine ?? null) === m ? "space.new" : null })))
          // An indicator, not a button: the whole row folds, so it lights with the row and has no label of its own.
          .child(div().id(`machine-fold-${id}`).flex_none()
            .text_color(this.overMachine === `machine-${id}` ? t.foreground : t.dim)
            .child(foldArrow("t3-spaces", `machine-fold-${id}`, !folded, 12, this.overMachine === `machine-${id}` ? t.foreground : t.dim))));
      const empty = plain(`machine-new-${id}`, m, ghost => {
        const el = h_flex().h(ROW).flex_none().px(10).gap(10).items_center().rounded(8)
          .text_color(this.hot === `machine-new-${id}` ? t.foreground : t.dim)
          // Laid out as a space's row: the + in the mark's 16px, the words where a name starts.
          .child(div().size(16).flex_none().flex().items_center().justify_center().child(svg("mods/t3-spaces/icons/plus.svg").size(12))).child("New space here");
        return ghost ? el : stop(this, t, `machine-new-${id}`, el.id(`machine-new-${id}`)
          .when(!lifting, el => el.hover(s => s.bg(t.hover)).active(s => s.bg(t.selected))).on_hover(glow(this, `machine-new-${id}`))
          .role("button").accessibility_label("New space here")
          .on_click(() => run("space.new", { machine: m ?? "" })), 8);
      });
      // A machine rarely goes, and when it does its heading just goes: no ghost.
      const heading = { key: `machine-${id}`, h: PITCH, m, el: stop(this, t, `machine-${id}`, head) };
      if (rebuilt) return [heading];
      return [heading, ...(folded ? [] : mine.length ? mine.map(entry) : [loading(m) ? loadingRow(m) : empty])];
    });
  }

  // Only what's unusual, after the name: "herdr \u00b7 spike \u21912 \u21931". The repo or
  // branch goes when the name already says it (a worktree is named after its branch),
  // and master/main go: nearly every space is on one.
  gitTail(g, tree, name, t, id, ghost) {
    const n = (count, what) => `${count} commit${count === 1 ? "" : "s"} to ${what}`;
    const mark = (mid, label, el) => ghost ? el : tipMark(this, t, mid, label, el);
    const raw = g.branch ?? "detached";
    const same = (a) => a.toLowerCase() === name.toLowerCase();
    const branch = same(raw) || raw === "master" || raw === "main" ? "" : raw;
    const repo = tree || same(g.name) ? "" : g.name;
    const where = [repo, branch].filter(Boolean).join(" \u00b7 ");
    return h_flex()
      .flex_1()
      .min_w(0)
      .gap(6)
      .justify_end()
      .items_center()
      .text_size(12)
      .text_color(t.dim)
      .when(Boolean(where), (el) => el.child(div().min_w(0).truncate().child(where)))
      .when(g.ahead > 0, (el) => el.child(mark(`ahead-${id}`, n(g.ahead, "push"), div().text_color(t.ansi2).child(`\u2191${g.ahead}`))))
      .when(g.behind > 0, (el) => el.child(mark(`behind-${id}`, n(g.behind, "pull"), div().text_color(t.ansi1).child(`\u2193${g.behind}`))));
  }

  // A checkout's fold arrow: at the row's end, and folded, the count before it, as T3's folder; dim, brightening when hovered.
  // -6: past T3's micro button's padding, its chevron stands in the column of a machine's and a folder's chevron.
  // The count just shows: it changes with the arrow, and a fade there isn't worth an element of its own.
  foldButton(t, id, repo, hiding, ghost) {
    const folded = this.foldedRepos.has(repo), lit = this.hot === id ? t.foreground : t.dim;
    const label = folded ? "Expand worktrees" : "Collapse worktrees";
    const el = div().h(20).min_w(20).mr(-6).px(6).gap(4).flex_none().flex().items_center().justify_center().rounded(4)
      // raised: the row under it already shows hover or selected.
      .text_size(11).text_color(lit)
      .when(folded && hiding > 0, el => el.child(String(hiding)))
      .child(foldArrow("t3-spaces", ghost ? null : id, !folded, 12, lit));
    return ghost ? el : tip(this, t, id, label, stop(this, t, id, el.id(id)
      .role("button").accessibility_label(label)
      .on_hover(glow(this, id))
      // Pressing it neither selects nor drags the space.
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); this.toggleRepo(repo, cx); }), 4));
  }

  // Once, however often it's pressed: the new space takes a moment to show.
  openCheckout({ w, g }) {
    if (Date.now() - (this.opening.get(g.repo) ?? -Infinity) < OPENING) return;
    this.opening.set(g.repo, Date.now());
    run("space.new", { folder: w.folder, machine: w.machine ?? "" });
  }

  // A repo's worktrees with its checkout not open: the checkout's row, dimmed, with its fold arrow. It has no tab to go to,
  // so a click opens it, and it becomes the checkout's own row. A bare repo has nothing to open: there the click folds.
  repoHead(r, t, ps, ghost) {
    const { w, g, hiding = 0 } = r, rowId = w.id, foldId = `${rowId}-fold`;
    const el = h_flex().h(ROW).flex_none().px(10).gap(10).items_center().rounded(8)
      .child(div().flex_none().opacity(0.5).child(projectMark(w, 16, t, ps)))
      .child(div().flex_1().min_w(0).truncate().font_medium().text_color(t.dim).child(w.name))
      .child(this.foldButton(t, foldId, g.repo, hiding, ghost));
    return ghost ? el : stop(this, t, rowId, el.id(rowId)
      .when(!this.drag?.moved, el => el.hover(s => s.bg(t.hover)).active(s => s.bg(t.selected)))
      .role("button").accessibility_label(w.folder ? `Open ${w.name}` : `${this.foldedRepos.has(g.repo) ? "Expand" : "Collapse"} ${w.name}`)
      .on_click((_e, cx) => { if (w.folder) this.openCheckout(r); else this.toggleRepo(g.repo, cx); cx.notify(); }), 8);
  }

  row({ w, g, tree, kids = 0, hiding = kids }, t, ps, ghost) {
    const on = w.active;
    // A checkout with worktrees folds them as an agent folds its sub-agents: an arrow at the
    // end, and folded, the count; dim, brightening when hovered.
    const foldId = `space-fold-${w.id}`;
    const rowId = `space-${w.id}`;
    const el = v_flex()
      .relative()
      .px(10)
      .h(ROW)
      .flex_none()
      .justify_center()
      .rounded(8)
      .when(on, (el) => el.bg(t.selected))
      // The same tree lines as sub-agents: from the checkout's avatar center, turning into the branch icon.
      .when(tree === "├─", el => el.child(div().absolute().left(17.25).top(0).bottom(-STACK).w(1.5).bg(t.input)))
      .when(Boolean(tree), el => el.child(div().absolute().left(17.25).top(-4).h(20).w(9.75).border_l(1.5).border_b(1.5).rounded_bl(6).border_color(t.input)))
      .child(
        h_flex()
          .w_full().min_w(0)
          .gap(10)
          .items_center()
          .when(Boolean(tree), el => el.pl(20).child(h_flex().size(16).flex_none().items_center().justify_center()
            .child(svg("mods/t3-spaces/icons/git-branch.svg").size(16).text_color(t.dim))))
          .when(!tree, el => el.child(projectMark(w, 16, t, ps)))
          .child(div().min_w(0).max_w(150).truncate().font_medium().text_color(t.foreground + "e6").child(w.name))
          .child(g ? this.gitTail(g, tree, w.name, t, w.id, ghost) : div().flex_1())
          .when(kids > 0, el => el.child(this.foldButton(t, foldId, g.repo, hiding, ghost))),
      );
    if (ghost) return el;
    return stop(this, t, rowId, el
      .id(rowId)
      .role("button")
      .accessibility_label(w.name)
      .when(!on && !this.drag?.moved, (el) => el.hover((s) => s.bg(t.hover)).active((s) => s.bg(t.selected)))
      // Held by its space and where it was drawn: a move under it doesn't change what's lifted.
      .on_mouse_down("left", (e) => {
        this.drag = { id: w.id, key: rowId, at: e.position, top: this.motion?.at.get(rowId)?.y ?? 0, moved: false };
      })
      // A press that never became a drag is a click.
      .on_mouse_up("left", (_e, cx) => {
        if (this.drag?.id !== w.id || this.drag.moved) return;
        this.drag = null;
        run("space.select", { id: w.id });
        cx.notify();
      })
      .on_mouse_down("right", () => this.menu(w)),
    // A space goes by its mouse-up, which a key isn't.
    8, { enter: () => run("space.select", { id: w.id }) });
  }

  // Dragging, as T3's sidebar and the inbox do it: press a space and move 6px to lift it, with its worktrees when it's a
  // checkout; it follows the pointer and the list opens a gap where letting go puts it. Within its machine only.
  dragTo(e, cx) {
    const d = this.drag;
    if (!d) return;
    pointerMoved(e.position);
    d.box = e.bounds;
    const dy = e.position.y - d.at.y;
    if (!d.moved && Math.hypot(e.position.x - d.at.x, dy) <= 6) return;
    // Let go outside the window, neither a release nor a leave comes (see pointerGone), and a move doesn't say whether the button's down.
    if (!d.moved) {
      const watch = cx.timer.every(POINTER_WATCH, (cx) => {
        if (this.drag !== d) return watch.cancel();
        if (!dragGone(d.box)) return;
        watch.cancel();
        this.letGo(cx, true);
      });
    }
    d.moved = true;
    // shortcut: measured from the press in window coordinates, so scrolling the list mid-drag isn't followed; take the rows' local_position if that matters.
    d.dy = dy;
    cx.notify();
  }

  // The lifted rows (a checkout takes its worktrees along) and the list without them.
  lift(rows, key) {
    const at = rows.findIndex((e) => e.key === key);
    if (at < 0) return null;
    let end = at + 1;
    if (!rows[at].r.tree) while (rows[end]?.r?.tree) end++;
    return { at, block: rows.slice(at, end), rest: [...rows.slice(0, at), ...rows.slice(end)] };
  }

  // Where they'd land, as an index into the rest, from the lifted top `y` and the rest's fixed pitch (never from
  // the rows the gap is moving): the nearest boundary its kind may take, a group between its machine's groups or a
  // worktree among its own. Half a row into another machine's rows, where it came from.
  slot({ at, block, rest }, y) {
    const lead = block[0], kid = Boolean(lead.r.tree);
    const under = rest[Math.min(rest.length - 1, Math.floor((y - ROW / 2) / PITCH))];
    if (under && under.m !== lead.m) return at;
    let from = at, to = at;
    if (kid) { while (rest[from - 1]?.r?.tree) from--; while (rest[to]?.r?.tree) to++; }
    else { from = 0; to = rest.length; }
    const starts = (e) => e?.r && !e.r.tree && e.m === lead.m;
    let best = at;
    for (let j = from; j <= to; j++) {
      const ok = kid || starts(rest[j]) || (rest[j - 1]?.r && rest[j - 1].m === lead.m && rest[j]?.m !== lead.m);
      if (ok && Math.abs(j * PITCH - y) < Math.abs(best * PITCH - y)) best = j;
    }
    return best;
  }

  // space.move's index for landing at the slot: before the next group (worktree) there, else after the one above.
  // Read from the model as it is now, folded worktrees included.
  dest({ at, block, rest }, { id, slot }) {
    if (slot === at) return null;
    const kid = Boolean(block[0].r.tree), order = spaces().map((s) => s.id), from = order.indexOf(id);
    const unit = (r) => [...(r.head ? [] : [r.w.id]), ...(r.members ?? [])].map((x) => order.indexOf(x)).filter((i) => i >= 0);
    const next = rest[slot];
    if (next?.r && Boolean(next.r.tree) === kid && next.m === block[0].m) {
      const u = Math.min(...unit(next.r));
      return from < 0 || u === Infinity ? null : from > u ? u + 1 : u;
    }
    let k = slot - 1;
    while (!kid && rest[k]?.r?.tree) k--;
    const p = rest[k]?.r ? Math.max(...unit(rest[k].r)) : -Infinity;
    return from < 0 || p === -Infinity ? null : from < p ? p + 1 : p + 2;
  }

  // Let go: it lands where the gap is (with `back`, where it came from), sliding there from where it was let go.
  letGo(cx, back) {
    const d = this.drag;
    this.drag = null;
    if (d?.drawn) {
      this.landed = { key: d.key, y: d.y };
      const l = this.lift(this.rows, d.key), index = back || !l ? null : this.dest(l, d);
      if (index) {
        run("space.move", { id: d.id, index });
        this.landing = { key: d.key, slot: d.slot, at: Date.now() };
        cx.timer.after(1000, (cx) => cx.notify());
      }
    }
    cx.notify();
  }

  render(cx) {
    const t = theme();
    const sp = spaces();
    // While a row's lifted, nothing under the pointer lights or labels itself.
    if (this.drag?.moved) this.hot = this.overMachine = null;
    // The shipped mods (the Terminals picker) still color spaces from "space.colors": the same color, from the name.
    const colors = Object.fromEntries(sp.filter(p => p.name !== "~").map(p => [p.id, tint(p.name, false)]));
    if (JSON.stringify(colors) !== JSON.stringify(shared("space.colors") ?? {})) setShared("space.colors", colors);
    const rows = this.rows = this.grouped(t);
    // New space here goes as the space it made arrives, with no leave to say so: it would come back lit.
    if (this.hot?.startsWith("machine-new-") && !rows.some((e) => e.key === this.hot)) this.hot = null;
    // A row that left the list (closed, folded away) can't be dropped.
    let d = this.drag, shown = rows, lifted = null;
    if (d && !rows.some((e) => e.key === d.key)) d = this.drag = null;
    if (d?.moved) {
      const l = this.lift(rows, d.key), h = l.block.length * PITCH;
      d.y = Math.max(0, Math.min(d.top + d.dy, l.rest.length * PITCH));
      // The first frame lifted keeps the gap where the row was, so a quick first move still slides the rows it passes.
      d.slot = d.drawn ? this.slot(l, d.y) : l.at;
      shown = [...l.rest.slice(0, d.slot), { key: "space-gap", h, el: div().h(h - STACK), ghost: () => div().h(h - STACK) }, ...l.rest.slice(d.slot)];
      lifted = v_flex().id("space-lifted").absolute().left(0).right(0).top(d.y).gap(STACK).rounded(8).bg(t.selected).shadow_lg()
        .children(l.block.map((e) => e.ghost()));
    } else if (this.landing) {
      // Until the model's echo of the move arrives, the rows stay where they were let go.
      const l = this.lift(rows, this.landing.key), slot = this.landing.slot;
      if (!l || l.at === slot || Date.now() - this.landing.at >= 1000) this.landing = null;
      else shown = [...l.rest.slice(0, slot), ...l.block, ...l.rest.slice(slot)];
    }
    // The first frame lifted is the list as it was, the gap where the row was: nothing to play.
    planMotion(this, shown, cx, { freeze: d?.moved && !d.drawn, from: this.landed });
    if (d?.moved) d.drawn = true;
    this.landed = null;
    const asks = props()?.newMenu && machines().length > 1;
    const tool = (id, label, icon, fn, more) => tip(this, t, id, label, stop(this, t, id, div().id(id).size(28).flex_none().flex().items_center().justify_center().rounded(8).text_color(this.hot === id ? t.foreground : t.dim).on_hover(glow(this, id)).on_mouse_down("left", () => pressed(this)).role("button").accessibility_label(label).hover(s => s.bg(t.hover))
      .on_click(fn).child(svg(`mods/t3-spaces/icons/${icon}.svg`).size(16)), 8), more);
    return focusRoot(this, v_flex().size_full().min_h(0).bg(t.chrome).text_size(14)
      // As tall as Inbox's top row, T3's.
      .child(h_flex().id("spaces-heading").h(48).flex_none().pl(18).pr(8).items_center().justify_between().text_size(12).font_medium().text_color(t.dim)
        .child(div().text_color(t.muted).child("Spaces"))
        // The same two as Inbox's top row, so switching modes moves nothing.
        .child(h_flex().flex_none().items_center()
          .child(tool("space-new", "New space", "folder-plus", (_e, cx) => {
            this.hot = null;
            // The layout's menu asks which machine, as its mod.json places it; the shipped one can't, so docked alone it's the active space's.
            const closing = justClosed(this, `${props()?.newMenu}.pickClosed`);
            if (!asks) run("space.new");
            else if (!closing) openOverlay({ mod: props().newMenu, kind: "popup", frame: "none", at: "top", offset: 96, width: 576, height: 420, props: { pick: true } });
            cx.notify();
          }, { action: asks ? null : "space.new" }))
          .child(tool("space-new-tab", "New tab", "square-pen", (_e, cx) => { this.hot = null; const menu = props()?.newMenu ?? "new-menu"; if (!justClosed(this, `${menu}.closed`)) run("mod.open", { name: menu }); cx.notify(); }))))
      .child(v_flex().id("space-list").flex_1().min_h(0).overflow_y_scroll()
        .on_mouse_move((e, cx) => this.dragTo(e, cx))
        // Released anywhere in the list, it lands where the gap is.
        .on_mouse_up("left", (_e, cx) => this.letGo(cx))
        // Herdr reports no release outside the sidebar, so leaving ends a drag, as in the inbox: back where it was.
        .on_hover((on, cx) => { if (!on && this.drag) this.letGo(cx, true); })
        .child(v_flex().id("space-content").w_full().flex_none().px(8).pb(8)
          // Inside the padding, so the rows that left and the lifted one line up with the rows.
          .child(v_flex().id("space-rows").relative().gap(STACK)
            .children(leavingRows(this))
            .children(shown.map((e) => flying(this, e.key, e.el)))
            .when(Boolean(lifted), (el) => el.child(lifted))))));
  }
}
