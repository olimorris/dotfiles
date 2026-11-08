const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { test } = require("node:test");

// A mod as Herdr would load it, all in one scope: what main.js imports from its own folder, each file once and before what needs it.
function bundle(dir, file = "main.js", seen = new Set()) {
  if (seen.has(file)) return "";
  seen.add(file);
  const src = fs.readFileSync(path.join(dir, file), "utf8");
  const needs = [...src.matchAll(/^import [^;]*? from "\.\/(.+?)";/gm)].map((m) => bundle(dir, m[1], seen)).join("\n");
  return needs + "\n" + src.replace(/^import [^;]*;\r?\n/gm, "").replace(/^export (function|const) /gm, "$1 ").replace("export default class", "globalThis.Mod = class");
}

function element() {
  const node = { key: null, items: [], handlers: {}, style: {} };
  const proxy = new Proxy(node, { get(target, key) {
    if (key in target) return target[key];
    return (...args) => {
      if (key === "when") { if (args[0]) args[1](proxy); }
      else if (["child", "content", "trigger"].includes(key)) node.items.push(args[0]);
      else if (key === "children") node.items.push(...args[0]);
      else if (key === "id") node.key = args[0];
      else if (key === "on_mouse_down" || key === "on_mouse_up") node.handlers[`${key}:${args[0]}`] = args[1];
      else if (key === "on_action") node.handlers[`on_action:${args[0]}`] = args[1];
      else if (key.startsWith("on_")) node.handlers[key] = args[0];
      else node.style[key] = args;
      return proxy;
    };
  } });
  return proxy;
}

function find(node, id) {
  if (!node || typeof node !== "object") return null;
  if (node.key === id) return node;
  for (const child of node.items) { const hit = find(child, id); if (hit) return hit; }
  return null;
}

function slims(node, out = []) {
  if (!node || typeof node !== "object") return out;
  if (node.key?.startsWith("slim-") && !node.key.startsWith("slim-corner-") && !node.key.startsWith("slim-mark-") && !node.key.startsWith("slim-space-")) out.push(node.key.slice(5));
  else for (const child of node.items) slims(child, out);
  return out;
}

function cards(node, out = []) {
  if (!node || typeof node !== "object") return out;
  if (node.key?.startsWith("card-")) out.push(node.key.slice(5));
  else for (const child of node.items) cards(child, out);
  return out;
}

function texts(node) {
  if (typeof node === "string") return [node];
  return node && typeof node === "object" ? node.items.flatMap(texts) : [];
}

// The element whose own child is this text: a card's title, or its branch line.
function holding(node, text) {
  if (!node || typeof node !== "object") return null;
  if (node.items.includes(text)) return node;
  for (const child of node.items) { const hit = holding(child, text); if (hit) return hit; }
  return null;
}

// The row that element sits in.
function lineOf(node, text) {
  if (!node || typeof node !== "object") return null;
  if (node.items.some((child) => child?.items?.includes(text))) return node;
  for (const child of node.items) { const hit = lineOf(child, text); if (hit) return hit; }
  return null;
}

function fixture() {
  const f = { watches: [], tick() { for (const w of [...f.watches]) if (!w.cancelled) w.fn(cx); }, pointer: { x: 0, y: 0 }, active: true, now: 1000, rows: [], terms: [], order: [], calls: [], jobs: [], timers: [], data: new Map(), pins: [], mode: "inbox", notifications: [], state: {}, labelled: [], writes: [], orderWrites: 0 };
  // The real Date, with its clock at f.now.
  const FakeDate = function (...args) { return args.length ? new Date(...args) : new Date(f.now); };
  FakeDate.now = () => f.now;
  const cx = {
    notify() { f.notified = true; }, stop_propagation() {}, bind_keys(b) { f.bound = b; },
    focus_handle: () => { const h = { focus() { f.keys = true; f.held = h; }, is_focused: () => f.held === h }; return h; },
    spawn: (fn) => f.jobs.push(fn),
    timer: {
      every(ms, fn) {
        const watch = { ms, fn, cancelled: false, cancel() { this.cancelled = true; } };
        f.watches.push(watch);
        return watch;
      },
      after(ms, fn) {
        const timer = { at: f.now + ms, fn, cancelled: false, cancel() { this.cancelled = true; } };
        f.timers.push(timer);
        return timer;
      },
    },
  };
  const env = {
    window: Object.assign(() => ({ platform: "macos", active: f.active }), { mouse_position: () => f.pointer, viewport_size: () => ({ width: 1200, height: 800 }) }), View: class {}, div: element, image: (src) => { const e = element(); e.style.image = [src]; return e; }, svg: element, v_flex: element, h_flex: element,
    Popover: { new: (id) => element().id(id) }, HoverCard: { new: (id) => element().id(id) }, Popup: { new: (id, trigger) => element().id(id).child(trigger) }, Select: { new: (id) => element().id(id) }, Input: { new: element }, NumberInput: { new: element }, Button: { new: element },
    InputState: { new: (o = {}) => {
      let value = o.value ?? "";
      const input = { heard: {}, on(e, fn) { input.heard[e] = fn; }, value: () => value, set_value(v) { value = v; }, focus() {}, set_min(m) { this.min = m; } };
      return input;
    } },
    namer: () => (a) => a.mod ? f.state[`${a.mod}.titles`]?.[a.tab] || a.title : a.address, Date: FakeDate,
    programOf: (x) => x.mod ? f.state[`${x.mod}.program`] ?? null : x.program,
    modStatus: (x) => f.state[`${x.mod}.status`]?.[x.tab] ?? null,
    localStorage: { getItem: (k) => f.data.get(k) ?? null, setItem: (k, v) => f.data.set(k, v) },
    keys: () => [], agents: () => f.rows, terminals: () => f.terms, panes: () => [],
    spaces: () => [{ id: "s1", name: "One", tabs: [] }, { id: "s2", name: "Two", tabs: [] }],
    focused: () => ({ agent: f.rows.find((a) => a.focused)?.address }),
    theme: () => ({}), settings: () => ({}), props: () => ({}),
    layout: () => ({ id: "sidebar-lists", active: f.mode }),
    shared: (k) => k === "agents.pins" ? f.pins : f.state[k] ?? null,
    setShared: (k, v) => { f.writes.push(k); if (k === "agents.pins") f.pins = Array.from(v); else f.state[k] = v; },
    setAgentOrder: (xs) => { f.orderWrites++; f.order = Array.from(xs); },
    run: (...args) => f.calls.push(args), notify: (n) => f.notifications.push(n), openOverlay() {}, closeOverlay() {},
    hc: async (args) => { f.labelled.push(args.join(" ")); return { code: 0 }; }, nextCommand: () => new Promise(() => {}),
  };
  // name.js is the fake above: these cards are titled by what each test sets.
  const src = bundle(__dirname, "main.js", new Set(["name.js"]));
  const context = vm.createContext(env);
  vm.runInContext(src, context, { filename: "t3-inbox/main.js" });
  f.context = context;
  f.mod = new context.Mod(); f.mod.init({}, cx);
  f.loadAgents = () => {
    const src = bundle(path.join(__dirname, "../t3-agents"), "main.js", new Set(["name.js"]));
    const context = vm.createContext({ ...env });
    vm.runInContext(src, context);
    const mod = new context.Mod(); mod.init({}, cx);
    return () => mod.render(cx);
  };
  f.add = (address, status = "idle", ms = 100) => {
    const row = { address, status, seq: f.rows.length + 1, space: "s1", space_name: "One", pane: address, program: {}, focused: false };
    f.rows.push(row);
    f.terms.push({ address, status, status_ms: ms, state: "live", turn: 0, labels: {} });
    return row;
  };
  f.render = (now = f.now) => {
    f.now = now;
    for (const timer of f.timers) if (!timer.cancelled && timer.at <= now) { timer.cancel(); timer.fn(cx); }
    f.tree = f.mod.render(cx);
    return f.tree;
  };
  f.working = () => cards(find(f.tree, "shelves"));
  f.active = () => cards(find(f.tree, "inbox-list")).filter((a) => !f.working().includes(a) && !f.pins.includes(a));
  f.event = (id, name, e = {}) => {
    const node = find(f.tree, id);
    assert.ok(node, `missing ${id}`);
    assert.ok(node.handlers[name], `missing ${name} on ${id}`);
    node.handlers[name]({ position: { x: 20, y: 100 }, local_position: { x: 20, y: 100 }, bounds: { height: 82 }, modifiers: {}, ...e }, cx);
  };
  f.settle = () => f.mod.settleKey(cx);
  f.napping = () => slims(find(f.tree, "snoozed"));
  // Label writes run as jobs; the core's copy is what the next render reads.
  f.flush = () => { for (const job of f.jobs.splice(0)) job(cx); };
  f.label = (address, key, value) => { f.terms.find((k) => k.address === address).labels[key] = value; };
  f.cx = cx;
  f.env = env;
  // A review in a tab of its own, and the tabs it shares its space with.
  f.review = (pane = "pm", tab = "tr", space = "s1") => {
    f.state["review.program"] = { icon: "mods/review/icons/logo.svg", tint: false, name: "Review", inbox: true };
    f.state["review.titles"] = { ...f.state["review.titles"], [tab]: `${pane} vs main` };
    const now = f.context.panes(), tabs = f.context.spaces();
    f.context.panes = () => [...now, { pane, mod: "review", tab, title: "review", terminal: null, focused: false }];
    f.context.spaces = () => tabs.map((s) => s.id === space ? { ...s, tabs: [...s.tabs, { id: tab }] } : s);
  };
  return f;
}

test("a quick continuation keeps its Working place, showing its real state meanwhile", () => {
  const f = fixture(), a = f.add("A", "working", 100); f.add("B", "working", 200); f.mod.workOpen = true;
  f.render(); assert.deepEqual(f.working(), ["B", "A"]);
  a.status = "done"; f.render(1100);
  assert.deepEqual(f.working(), ["B", "A"]);
  assert.ok(texts(find(f.tree, "state-A")).includes("Done"));
  a.status = "working"; f.render(1300);
  assert.deepEqual(f.working(), ["B", "A"]);
});

test("a finished run moves to Active once the grace is out; blocked moves at once", () => {
  const f = fixture(), a = f.add("A", "working"), b = f.add("B", "working"); f.mod.workOpen = true;
  f.render(); a.status = "idle"; f.render(1100);
  f.terms[0].turn++; f.render(2000); // the turn's end arriving late doesn't restart the grace
  f.render(3099); assert.deepEqual(f.working(), ["A", "B"]);
  assert.ok(f.timers.some((t) => !t.cancelled && t.at === 3100)); // on time, not on the next second's tick
  f.render(3100); assert.deepEqual(f.active(), ["A"]);
  b.status = "blocked"; f.render(3200); assert.deepEqual(f.active(), ["B", "A"]);
  f.terms.push({ address: "kid", parent: "A", state: "live", status: "error" });
  a.status = "working"; f.render(3300); assert.deepEqual(f.active(), ["A", "B"]);
});

test("a failed turn needs the person: the terminal's error, which agents() can't say", () => {
  const f = fixture(); f.add("A", "done"); f.add("B", "done");
  f.terms[0].status = "error";
  f.render();
  assert.ok(texts(find(f.tree, "state-A")).includes("Needs you"));
  assert.ok(texts(find(f.tree, "state-B")).includes("Done"));
  // A sub-agent with its own pane is in agents() too, where its error reads as something else.
  f.add("kid", "done"); f.terms.at(-1).parent = "B"; f.terms.at(-1).status = "error";
  f.render();
  assert.ok(texts(find(f.tree, "state-B")).includes("Needs you"));
  f.label("A", "settled", "1:0"); f.rows[0].focused = true; f.render();
  assert.equal(f.mod.pending.settled.A, "", "a terminal error ends its settle too");
  const labels = f.jobs.length; f.settle();
  assert.equal(f.jobs.length, labels, "the failed terminal cannot be settled");
});

test("looking, seq and data order don't reshuffle; equal times go by address", () => {
  const f = fixture(), a = f.add("B", "done"); f.add("A", "done");
  f.render(); assert.deepEqual(f.order, ["A", "B"]);
  a.status = "idle"; a.focused = true; a.seq = 99; f.rows.reverse(); f.render(1500);
  assert.deepEqual(f.order, ["A", "B"]);
  for (const k of f.terms) k.labels.settled = "500:0";
  f.render(1600); f.rows.reverse(); f.render(1700); assert.deepEqual(f.order, ["A", "B"]);
});

test("a short absence and a restart keep each agent's place", () => {
  const f = fixture(), a = f.add("A", "working"), b = f.add("B"), c = f.add("C", "idle", 1500);
  f.render(1600); a.status = "done"; f.render(2000); f.render(4100);
  assert.deepEqual(f.order, ["A", "C", "B"]);
  f.rows = [b, c]; b.status = "working"; f.render(4200);
  f.rows = [a, b, c]; f.render(4300); assert.deepEqual(f.order, ["A", "C", "B"]);
  const g = fixture(); g.data = f.data; g.rows = f.rows; g.terms = f.terms; g.mod.init({}, g.cx);
  g.render(4400); assert.deepEqual(g.order, f.order);
  f.terms[0].state = "exited"; f.rows = [b, c]; c.status = "working"; f.render(4500);
  assert.equal(f.mod.changed.A, undefined);
});

// A hidden list doesn't draw: what happened meanwhile goes by each tab's changed_at, not by when it comes back into view.
function inTabs(f, at) {
  f.context.spaces = () => [{ id: "s1", name: "One", tabs: Object.entries(at).map(([id, changed_at]) => ({ id, changed_at })) }];
}

test("what ended or began while the list wasn't drawn goes by when it did", () => {
  const f = fixture(), z = f.add("Z", "working"), b = f.add("B", "working"), c = f.add("C"), at = {}; f.mod.workOpen = true;
  z.tab = "tz"; b.tab = "tb"; c.tab = "tc"; inTabs(f, at);
  f.render();
  z.status = b.status = "idle"; c.status = "working";
  Object.assign(at, { tz: 3000000, tb: 300000, tc: 1800000 });
  f.render(3600000);
  assert.deepEqual(f.active(), ["Z", "B"], "over long since: no grace, and the later one on top");
  assert.ok(texts(find(f.tree, "state-C")).includes("30m"), "not Working 0s");
  // One that stopped a moment ago still gets what's left of its grace.
  const y = f.add("Y", "working"); y.tab = "ty"; f.render(3600100);
  y.status = "idle"; at.ty = 3600000; f.render(3600500);
  assert.ok(f.working().includes("Y"));
  f.render(3601999); assert.ok(f.working().includes("Y"));
  f.render(3602000); assert.equal(f.active()[0], "Y");
});

test("a tab's time that isn't about the change goes unused: a sub-agent with no pane starting or stopping", () => {
  const f = fixture(), a = f.add("A"), at = { ta: 500 }; f.mod.workOpen = true;
  a.tab = "ta"; inTabs(f, at); f.render();
  const kid = { address: "kid", parent: "A", state: "live", status: "working" }; f.terms.push(kid);
  f.render(9000); assert.equal(f.mod.changed.A.at, 9000, "A's own last change is older than its sub-agent's start");
  kid.state = "exited"; f.render(20000); assert.equal(f.mod.changed.A.at, 20000);
});


test("a turn that ended unseen is news; unsettling doesn't land on Working", () => {
  const f = fixture(), a = f.add("A", "idle", 200); f.add("B", "idle", 100);
  f.render(); assert.deepEqual(f.order, ["A", "B"]);
  f.terms[1].turn++; f.render(1500); assert.deepEqual(f.order, ["B", "A"]);
  f.terms[0].labels.settled = "1000:0"; f.render(1600);
  a.focused = true; f.settle(); f.render(1700);
  assert.deepEqual(f.working(), []); assert.deepEqual(f.order, ["A", "B"]);
});

// Synced alone to herdr-t3-inbox, there's no agents list to load.
const lists = fs.existsSync(path.join(__dirname, "../t3-agents/main.js"));
// A hidden list isn't drawn, so whichever draws sets it.
test("the sidebar list in view sets agent.next order", { skip: !lists && "t3-agents isn't here" }, () => {
  const f = fixture(); f.add("A", "working"); f.add("B", "idle", 200); f.render();
  const order = [...f.order], renderAgents = f.loadAgents();
  f.mode = "lists"; renderAgents(); assert.notDeepEqual(f.order, order);
  f.mode = "inbox"; f.render(1500); assert.deepEqual(f.order, order);
});

test("a layout Inbox keeps computing while hidden, writes only changes and leaves Lists' order alone", () => {
  const f = fixture(), a = f.add("A", "working"); f.add("B");
  f.context.props = () => ({ home: "t3-tabs.home" }); f.render();
  const tick = () => f.watches.find(w => w.ms === 1000).fn(f.cx);
  f.mod.render = () => { throw new Error("a hidden copy must not draw"); };
  a.status = "blocked"; f.now = 2000; tick();
  assert.deepEqual([...f.state["t3-inbox.rows"].order], ["A", "B"]);
  const before = [f.writes.length, f.orderWrites]; tick(); tick();
  assert.deepEqual([f.writes.length, f.orderWrites], before, "unchanged data redraws no other mod and resets no navigation");
  f.mode = "lists"; f.order = ["Lists"]; a.status = "working"; tick();
  assert.deepEqual(f.order, ["Lists"]);
  assert.deepEqual([...f.state["t3-inbox.rows"].order], ["A", "B"], "inactive Inbox publishes no rows");
  f.mode = "inbox"; tick();
  assert.deepEqual([...f.state["t3-inbox.rows"].order], ["B"]);
});

test("a drag changing the settled page publishes its drawn rows only once, then causes no redraw loop", () => {
  const f = fixture(); f.add("A"); f.add("B");
  f.label("A", "settled", "100:0"); f.label("B", "settled", "200:0");
  f.mod.open = true; f.mod.limit = 1; f.render();
  f.mod.drag = { from: "B", moved: true, target: { section: "active" }, height: 36 };
  f.writes.length = 0; f.render();
  assert.equal(f.writes.filter(k => k === "t3-inbox.rows").length, 1);
  f.writes.length = 0; f.render();
  assert.equal(f.writes.filter(k => k === "t3-inbox.rows").length, 0);
});

test("a layout Inbox handles Undo through shared state while hidden or behind Lists", () => {
  for (const mode of ["inbox", "lists"]) {
    const f = fixture(); f.context.props = () => ({ home: "t3-tabs.home" }); f.mode = mode;
    let undone = 0;
    f.mod.remember("Snoozed", 1, () => undone++, f.cx);
    const n = f.state["t3-inbox.notice"];
    f.state["t3-inbox.undo"] = { gen: n.gen, at: n.at, requestedAt: f.now, request: 1 };
    const tick = () => f.watches.find(w => w.ms === 1000).fn(f.cx);
    tick(); tick(); assert.equal(undone, 1);
    assert.equal(f.state["t3-inbox.notice"].live, false);
    f.state["t3-inbox.notice"] = { owner: "tabs", gen: 100, live: true };
    f.now = 7000;
    for (const timer of f.timers) if (!timer.cancelled && timer.at <= f.now) { timer.cancel(); timer.fn(f.cx); }
    assert.equal(f.state["t3-inbox.notice"].owner, "tabs", "an older Inbox notice's timers cannot erase a newer tab-bar action");
  }
});

test("Undo pressed just before five seconds runs before expiry, without waiting for the hidden poll", () => {
  const f = fixture(); f.context.props = () => ({ home: "t3-tabs.home" }); let undone = 0;
  f.mod.remember("Snoozed", 1, () => undone++, f.cx);
  const n = f.state["t3-inbox.notice"];
  f.state["t3-inbox.undo"] = { gen: n.gen, at: n.at, requestedAt: f.now + 4999, request: 1 };
  f.now += 5000;
  f.timers.find(t => t.at === f.now).fn(f.cx);
  assert.equal(undone, 1);
});

test("a pause for the person keeps the run's Working place", () => {
  const f = fixture(), a = f.add("A", "working", 100); f.add("B", "working", 200); f.mod.workOpen = true;
  f.render(); a.status = "blocked"; f.render(1100); assert.deepEqual(f.active(), ["A"]);
  a.status = "working"; f.render(9000); assert.deepEqual(f.working(), ["B", "A"]);
});

test("a reply while sub-agents work comes to Active; read, the run goes on from its start", () => {
  const f = fixture(), a = f.add("A", "idle"); f.mod.workOpen = true;
  f.render(1000); f.terms.push({ address: "kid", parent: "A", state: "live", status: "working" });
  f.render(2000); assert.deepEqual(f.working(), ["A"]);
  a.status = "done"; f.render(3000); assert.deepEqual([f.active(), f.working()], [["A"], []]);
  a.status = "idle"; f.render(4000); assert.deepEqual(f.working(), ["A"]);
  assert.equal(f.mod.changed.A.at, 2000);
});

test("a hidden list's Working clock goes quiet: only a draw starts it again", () => {
  const f = fixture(); f.add("A", "working"); f.mod.workOpen = true; f.render();
  const second = () => { f.notified = false; f.watches.find((w) => w.ms === 1000).fn(f.cx); return f.notified; };
  assert.equal(second(), true);
  assert.equal(second(), false);
  f.render(); assert.equal(second(), true);
});


test("a run out of its grace lands on top of Active, over one that came back meanwhile", () => {
  const f = fixture(), a = f.add("A", "working"), b = f.add("B", "working"); f.mod.workOpen = true;
  f.render(); a.status = "idle"; f.render(1100);
  b.status = "blocked"; f.render(2000); assert.deepEqual(f.active(), ["B"]);
  f.render(3100); assert.deepEqual(f.active(), ["A", "B"]);
});

test("pinned agents skip the grace: unpinned right after stopping, it's in Active", () => {
  const f = fixture(), a = f.add("A", "working"); f.pins = ["A"]; f.mod.workOpen = true;
  f.render(); a.status = "idle"; f.render(1100);
  f.pins = []; f.render(1200);
  assert.deepEqual(f.active(), ["A"]); assert.deepEqual(f.working(), []);
});

test("Settle in view moves down the cards, then from the top", () => {
  const go = (focus) => {
    const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.add("P", "idle", 100); f.pins = ["P"];
    f.rows.find((a) => a.address === focus).focused = true; f.render(); assert.deepEqual(f.order, ["P", "A", "B"]);
    f.settle(); return f.calls.at(-1)[1].terminal;
  };
  assert.equal(go("A"), "B");
  assert.equal(go("B"), "P");
});

test("times read as T3's", () => {
  const f = fixture(), a = f.add("A", "working"), b = f.add("B", "working"); f.mod.workOpen = true;
  f.render(); f.render(1000 + 3720000);
  assert.deepEqual(texts(find(f.tree, "state-A")).slice(-2), ["1h", "2m"]);
  b.status = "idle"; f.render(4000000); f.render(4002000);
  assert.ok(texts(find(f.tree, "state-B")).includes("just now"));
  f.render(4002000 + 9 * 86400000); assert.ok(texts(find(f.tree, "state-B")).includes("9d"));
});

test("a new scope starts the settled tail over", () => {
  const f = fixture(); f.mod.limit = 35; f.mod.pick({ id: "s1" }, false, f.cx);
  assert.equal(f.mod.limit, 10);
});

test("only a list with nothing in it says so, as T3's", () => {
  const said = (f) => texts(f.tree).filter((s) => /^Nothing/.test(s));
  const f = fixture(); f.render();
  assert.equal(said(f).length, 1, "no agents at all");
  assert.match(said(f)[0], /^Nothing here yet/);
  const a = f.add("A", "idle", 100); f.pins = ["A"]; f.render();
  assert.deepEqual(said(f), [], "a pinned card and an empty Active: blank");
  f.pins = []; a.space = "s1"; f.terms[0].labels.settled = "1100:0"; f.render(1100);
  assert.deepEqual(said(f), [], "all settled: blank");
  f.mod.scope = ["s2"]; f.render();
  assert.deepEqual(said(f), ["Nothing in Two yet"], "a filter that leaves nothing names its space");
  f.mod.scope = ["s2", "gone"]; f.render();
  assert.deepEqual(said(f), ["Nothing in Two yet"]);
});

test("the space filter's menu measures as T3's, its search text inside the button's left edge", () => {
  const f = fixture(); f.add("A", "idle", 100); f.mod.scopeOpen = true; f.render();
  const num = (n, k) => n.style[k]?.[0];
  const menu = find(f.tree, "inbox-scope-menu"), panel = find(f.tree, "inbox-scope-panel"), field = panel.items[0];
  assert.equal(num(menu, "anchor"), "top_left", "hangs from the button's left edge");
  assert.deepEqual(["w", "mt", "p", "rounded"].map((k) => num(panel, k)), [288, 4, 4, 8]);
  assert.ok("shadow_lg" in panel.style, "as every other popup");
  assert.equal("gap" in panel.style, false, "T3's rows and field are flush");
  assert.deepEqual(["mx", "mt", "h", "pb", "gap"].map((k) => num(field, k)), [8, 5, 33, 6, 4]);
  const icon = field.items[0], inset = num(panel, "p") + num(field, "mx");
  assert.equal(num(icon, "size"), 16);
  assert.equal(inset + num(icon, "size") + num(field, "gap"), 32, "T3's: 12 to the icon, 20 on to the text");
  assert.equal(num(field, "h") - num(field, "pb") - 1, 26, "T3's h-6.5 field, above its 1px rule");
  const row = find(panel, "scope-all"), rows = find(panel, "inbox-scope-list").items.filter((n) => n.key?.startsWith("scope-"));
  assert.deepEqual(["h", "px", "gap", "rounded"].map((k) => num(row, k)), [32, 8, 8, 4]);
  assert.deepEqual(rows.slice(0, 2).map((n) => num(n, "top")), [0, 32], "the rows are 32 apart");
});

// shared/check-focus.cjs has focus.js's own rules; these are what the inbox wires to them.
test("in keyboard mode each control is a stop, and a row shows with the keyboard on it what it shows hovered", () => {
  const f = fixture(); f.add("A", "idle", 100);
  const on = (id) => { f.mod.fs.keyboard = true; f.mod.fs.handles.set(id, { focus() {}, is_focused: () => true }); };
  f.render();
  assert.equal(find(f.tree, "card-A").style.tab_index, undefined, "no stop until the mode's on: a press would take the terminal's keyboard");
  assert.equal(find(f.tree, "inbox-search").style.track_focus, undefined);
  f.state["t3-focus"] = "on";
  f.render();
  for (const id of ["card-A", "inbox-search", "inbox-scope", "inbox-new-space", "inbox-new-tab"]) assert.deepEqual(find(f.tree, id).style.tab_index, [0], id);
  assert.equal(find(f.tree, "settle-A").style.tab_index, undefined, "faded out it's no button");
  on("card-A"); f.render();
  assert.deepEqual(find(f.tree, "settle-A").style.tab_index, [0], "Settle comes with the keyboard");
  assert.deepEqual(find(f.tree, "snooze-A").style.tab_index, [0], "and Snooze");
  assert.equal(find(f.tree, "settle-A").style.opacity[0], 1);
  // And stays while the keyboard's on it, and Enter does what a click does (the kit's on_click: GPUI's keyboard click).
  f.mod.fs.handles.clear(); on("settle-A"); f.render();
  assert.equal(find(f.tree, "settle-A").style.opacity[0], 1);
  assert.ok(find(f.tree, "settle-A").handlers.on_click);
  // A settled row's undo the same.
  f.event("settle-A", "on_click"); f.flush(); f.label("A", "settled", "1"); f.render(1100);
  assert.equal(f.mod.fs.keyboard, true);
  f.mod.open = true; f.mod.fs.handles.clear(); on("slim-A"); f.render(1100);
  assert.deepEqual(find(f.tree, "unsettle-A").style.tab_index, [0]);
});

test("pane.go hands the inbox the keyboard, and it starts at Search", async () => {
  const f = fixture(); f.add("A", "idle", 100);
  f.render();
  const sent = ["focus"];
  f.context.nextCommand = async () => { if (sent.length) return sent.shift(); throw new Error("done"); };
  await assert.rejects(f.jobs.at(0)(f.cx), /done/);
  assert.ok(f.state["t3-focus"], "the mode's on");
  assert.ok(f.keys, "and the keyboard's moved");
  f.render();
  assert.equal(find(f.tree, "inbox-search").style.track_focus[0], f.mod.fs.handles.get("inbox-search"));
});

test("snooze menu, Custom's units: Home, End and typing move the same highlight", () => {
  const f = fixture(); f.add("A", "idle", 100);
  f.render(); f.mod.hovered = "A"; f.render();
  f.event("snooze-menu-A", "on_open_change", true); f.render();
  find(f.tree, "snooze-menu-A").handlers.on_open_change?.(true, f.cx); f.render();
  const key = (e) => { f.event("snooze-panel-A", "on_key_down", e); f.render(); };
  key({ key: "end" });
  assert.equal(f.mod.napAt, find(f.tree, "snooze-panel-A").items.filter((n) => n.key?.startsWith("snooze-")).length - 1);
  key({ key: "home" });
  assert.equal(f.mod.napAt, 0);
  key({ key: "c", key_char: "c" });
  assert.equal(find(f.tree, `snooze-${f.mod.napAt}-A`).style.accessibility_label[0], "Custom…");
});

test("a plain click on Settle leaves no sweep behind to swallow the next click", () => {
  const f = fixture(), a = f.add("A", "idle", 100); f.add("B", "idle", 50); f.add("C", "idle", 30); a.focused = true;
  f.render(); f.mod.hovered = "A"; f.render();
  f.event("settle-A", "on_mouse_down:left");
  // The button's click stops its release there: the sidebar's own mouse-up never comes.
  f.event("settle-A", "on_click"); f.render(1100);
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 20, y: 300 } });
  assert.equal(f.keys, undefined, "the sidebar doesn't take the keyboard");
  f.event("card-C", "on_click");
  assert.deepEqual([f.calls.at(-1)[0], f.calls.at(-1)[1].terminal], ["agent.focus", "C"], "the next click opens the card at once");
});

test("a plain click on a settled row's undo leaves no sweep behind either", () => {
  const f = fixture(); f.add("A"); f.terms[0].labels.settled = "500:0"; f.mod.open = true;
  f.render(); f.mod.hovered = "A"; f.render();
  f.event("unsettle-A", "on_mouse_down:left"); f.event("unsettle-A", "on_click"); f.render(1100);
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 20, y: 300 } });
  assert.equal(f.keys, undefined); assert.equal(f.mod.sweep, null);
});

test("a title is bright when it's in view, needs you or is done; hover brightens without changing its weight", () => {
  const f = fixture(); f.env.theme = () => ({ foreground: "bright", muted: "quiet" });
  f.add("Seen", "idle"); f.add("Finished", "done"); f.add("Stuck", "blocked"); f.add("Open", "idle").focused = true;
  f.render();
  const look = (name) => { const { style } = holding(f.tree, name); return [style.text_color[0], Boolean(style.font_medium)]; };
  assert.deepEqual(look("Seen"), ["quiet", false]);
  for (const name of ["Finished", "Stuck", "Open"]) assert.deepEqual(look(name), ["bright", true], name);
  f.mod.hovered = "Seen"; f.render();
  assert.deepEqual(look("Seen"), ["bright", false]);
});

test("a card's marks sit on its third line when it has one, else on the title's", () => {
  const f = fixture(); f.add("m1/A"); f.add("m1/B");
  f.env.panes = () => [{ pane: "m1/A", branch: "dev" }];
  f.render();
  assert.equal(find(lineOf(f.tree, "m1/A"), "machine-m1/A"), null, "the title keeps its whole line");
  assert.ok(find(lineOf(f.tree, "dev"), "machine-m1/A"), "the branch line carries the mark");
  assert.ok(find(lineOf(f.tree, "m1/B"), "machine-m1/B"), "no third line: the title's line carries it");
});

test("a space's monogram is its first glyph, in T3's color for the same name", () => {
  const f = fixture(), run = (code) => vm.runInContext(code, f.context);
  // T3's own cases (apps/mobile/src/lib/projectIcon.test.ts), its colors as Tailwind's 400.
  for (const [name, text, color] of [["t3code", "T", "#2dd4bf"], ["Auto Monogram", "A", "#a3e635"], ["blitzdiff", "B", "#f472b6"],
    ["uoalbumdotclub", "U", "#9ca3af"], ["  Tagium  ", "T", "#a3e635"], ["Café Ünïcode", "C", "#e879f9"], ["web2 app", "W", "#34d399"]]) {
    assert.deepEqual([run(`monogram(${JSON.stringify(name)})`), run(`tint(${JSON.stringify(name)}, true)`)], [text, color], name);
  }
  assert.deepEqual([run(`monogram("智能算量")`), run(`monogram("~/dev")`)], ["智", "D"]);
  assert.equal(run(`monogram("~")`), "", "nothing to spell: the folder instead");
  f.add("A"); f.render();
  const tile = holding(f.tree, "O"), color = run('tint("One", true)');
  assert.deepEqual([tile.style.size[0], tile.style.bg[0], tile.style.text_color[0], tile.style.text_size[0]], [16, color + "24", color, 8.25], "T3's 14% wash of the color, the card's 16px, its 8.25 type");
});

test("a space's own icon, found as T3 finds it, replaces its monogram on every card", async () => {
  const f = fixture(), runs = [], written = [];
  // Its terminal is down in the repo: the icon is the repo's, as T3's is its project root's.
  f.env.spaces = () => [{ id: "s1", name: "One", folder: "", machine: "vps", tabs: [{ id: "b1" }] }];
  f.env.panes = () => [{ pane: "A", tab: "b1", cwd: "/w/one/src" }];
  Object.assign(f.context, {
    Buffer, createHash: require("node:crypto").createHash, appHome: () => "/app",
    fs: { exists: async () => false, mkdir: async () => {}, writeFile: async (p, b) => written.push([p, Buffer.from(b).toString()]) },
    readTextFile: async (p) => p === "/w/one/index.html" ? `<link href="/brand/logo.svg" rel="icon">` : null,
    exec: async (cmd, args, opts) => {
      if (cmd === "git") return opts.cwd === "/w/one/src" ? { code: 0, stdout: "/w/one\n" } : { code: 128, stdout: "" };
      runs.push([args.slice(3), opts]);
      if (args[1].startsWith("base64")) return { code: 0, stdout: Buffer.from("<svg/>").toString("base64").replace(/(.{4})/g, "$1\n") };
      return { code: 0, stdout: args.includes("brand/logo.svg") ? "brand/logo.svg" : "" };
    },
  });
  f.add("A"); f.render();
  await new Promise((done) => setTimeout(done, 0));
  assert.equal(runs[0][0][0], "favicon.svg", "the well-known places first, in T3's order");
  assert.deepEqual([...runs[1][0]], ["public/brand/logo.svg", "brand/logo.svg"], "then the page's link, public/ first");
  assert.deepEqual({ ...runs[1][1] }, { cwd: "/w/one", on: "vps" }, "looked for on the space's own machine");
  const [[at, bytes]] = written, icon = at.slice("/app/".length);
  assert.match(icon, /^cache\/t3-icons\/[0-9a-f]{16}\.svg$/); assert.equal(bytes, "<svg/>");
  f.render();
  const pic = find(f.tree, "card-A") && (function first(n) { return n?.style?.image ? n : n?.items?.map(first).find(Boolean); })(f.tree);
  assert.deepEqual([pic.style.image[0], pic.style.size[0]], [icon, 16]);
  assert.equal(holding(f.tree, "O"), null, "no monogram beside it");
  f.render(f.now + 59000); await new Promise((done) => setTimeout(done, 0));
  assert.equal(runs.length, 3, "found, it isn't looked for again within ten minutes");
});

// The list moves as T3's (Sidebar.motion.ts): a frame where the rows were, then let go to ease into place.
const flyOf = (f, address) => {
  const walk = (n) => !n || typeof n !== "object" ? null : n.key?.startsWith(`fly-${address}-`) ? n : n.items.map(walk).find(Boolean) ?? null;
  return walk(f.tree);
};
const at = (n) => ({ id: n.key, top: n.style.top?.[0], opacity: n.style.opacity?.[0] });

test("settling slides the card down into Settled and the rows under it up, then lets them go", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.add("C", "idle", 100);
  f.mod.open = true; f.mod.listH = 600; f.render();
  assert.deepEqual(at(flyOf(f, "B")), { id: "fly-B-0", top: 0, opacity: 1 }, "nothing moves on the first draw");
  f.terms[0].labels.settled = "1100:0"; f.render(1100);
  const a = at(flyOf(f, "A")), b = at(flyOf(f, "B"));
  assert.equal(a.id, "fly-A-1", "a row that moves is a new element, first drawn where it was");
  assert.ok(a.top < 0, "A starts up where its card was, over Settled");
  assert.deepEqual(b, { id: "fly-B-1", top: 83, opacity: 1 }, "B starts a card lower, where it was");
  assert.equal(at(flyOf(f, "C")).top, 83);
  f.render(1116);
  assert.deepEqual([at(flyOf(f, "A")), at(flyOf(f, "B"))], [{ id: "fly-A-1", top: 0, opacity: 1 }, { id: "fly-B-1", top: 0, opacity: 1 }], "then they're let go, the same elements, so Herdr eases them");
  f.render(1200);
  assert.equal(flyOf(f, "B").key, "fly-B-1", "a draw with nothing new moves nothing");
});

test("a new row fades in from 40px up at the top, or in place under a row that stays", () => {
  const f = fixture(); f.add("A", "idle", 200); f.mod.listH = 600; f.render();
  f.add("B", "idle", 300); f.add("Z", "idle", 50); f.render(1100);
  assert.deepEqual(at(flyOf(f, "B")), { id: "fly-B-1", top: -40, opacity: 0 }, "at the top: from 40px up, clear");
  assert.deepEqual(at(flyOf(f, "Z")), { id: "fly-Z-1", top: -83, opacity: 0 }, "under A, which moved a card down: riding with it");
  f.render(1116);
  assert.deepEqual([at(flyOf(f, "B")).opacity, at(flyOf(f, "Z")).top], [1, 0]);
});

test("a row that leaves fades out where it was, then goes", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.mod.listH = 600; f.render();
  f.rows.splice(0, 1); f.terms.splice(0, 1); f.render(1100);
  const ghost = () => { const walk = (n) => !n || typeof n !== "object" ? null : n.key?.startsWith("leaving-A-") ? n : n.items.map(walk).find(Boolean) ?? null; return walk(f.tree); };
  assert.deepEqual([ghost().style.opacity[0], ghost().style.top[0]], [1, 10], "drawn as it was, where it was");
  assert.equal(at(flyOf(f, "B")).top, 83, "B slides up from under it");
  f.render(1116);
  assert.deepEqual([ghost().style.opacity[0], ghost().style.top[0]], [0, 50], "fading, 40px down: nothing above it stays");
  f.render(1300);
  assert.equal(ghost(), null);
});

test("a settled row's time fades out as its undo fades in, and back", () => {
  const f = fixture(); f.add("A"); f.terms[0].labels.settled = "500:0"; f.mod.open = true;
  f.render();
  const corner = () => find(f.tree, "slim-corner-A"), undo = () => find(f.tree, "unsettle-A");
  assert.deepEqual([corner().items[0].style.opacity[0], undo().style.opacity[0]], [1, 0]);
  assert.equal(undo().handlers.on_click, undefined, "faded out, it's no button");
  f.mod.hovered = "A"; f.render();
  assert.deepEqual([corner().items[0].style.opacity[0], undo().style.opacity[0]], [0, 1]);
  assert.deepEqual(JSON.parse(JSON.stringify(corner().items[0].style.transition)), ["opacity", { duration: 150, easing: "ease-out" }]);
});

test("a dropped row slides from where it was let go, and nothing moves while dragging", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.mod.open = true; f.mod.listH = 600; f.render();
  f.mod.drag = { from: "B", moved: true, y: 400, grab: 10, height: 82, target: { section: "settled" } };
  f.render(1050);
  assert.equal(flyOf(f, "B").key, "fly-B-0", "dragging: the lanes' gaps move, the rows don't fly");
  // Let go, from where the ghost was (390, below the list's top row), in the list's terms. B isn't the one in view.
  f.event("t3-inbox-root", "on_mouse_up:left"); f.render(1100);
  const b = flyOf(f, "B"), y = f.mod.motion.at.get("B").y;
  assert.deepEqual([b.key, b.style.top[0]], ["fly-B-1", 390 - 48 - y]);
});

// Herdr scales what a mod sets and reports what it measures as drawn, so at a zoom a drag has to go by one or the other.
test("at a zoom, the lifted row stays under the pointer and the gap is the card's height", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.add("C", "idle", 100); f.mod.listH = 600;
  f.context.settings = () => ({ zoom: 2 }); f.render();
  const leave = () => find(f.tree, "t3-inbox-root").handlers.on_hover(false, f.cx);
  const down = { position: { x: 40, y: 400 }, local_position: { x: 40, y: 60 }, bounds: { x: 0, y: 340, width: 500, height: 164 } };
  f.event("card-C", "on_mouse_down:left", down);
  f.event("t3-inbox-root", "on_size_change", { width: 600, height: 1600 });
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 40, y: 900 }, local_position: { x: 40, y: 900 }, bounds: { x: 0, y: 0, width: 600, height: 1600 } });
  f.mod.drag.target = { section: "pinned", before: null }; f.render();
  assert.equal(find(f.tree, "drag-ghost").style.top[0], (900 - 60) / 2, "in the values top() scales");
  assert.equal(find(f.tree, "gap-head-pinned").style.h[0], 164 / 2 + 5);
  // Measured as drawn too, a press near the bottom of the 1600 drawn is near the bottom, off the edge it lands.
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 300, y: 1590 }, local_position: { x: 300, y: 1590 }, bounds: { x: 0, y: 0, width: 600, height: 1600 } });
  f.render(); leave();
  assert.deepEqual(f.pins, ["C"], "it lands where its badge said");
  f.pins = []; f.render(2000);
  f.mod.cardH = null; f.event("card-A", "on_size_change", { width: 500, height: 164 }); f.render();
  assert.equal(f.mod.cardH, 82);
  f.mod.dropped = 0;
  f.event("card-A", "on_mouse_down:left", down);
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 5, y: 800 }, local_position: { x: 5, y: 800 }, bounds: { x: 0, y: 0, width: 600, height: 1600 } });
  f.mod.drag.target = { section: "pinned", before: null }; f.render();
  leave();
  assert.deepEqual(f.pins, [], "off a side it goes back");
});

test("the settle key takes the row the pointer's on along: no hover left on its settled row, far from the pointer", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); f.mod.open = true; a.focused = true; f.render();
  f.event("card-A", "on_hover", true); f.render(f.now + 150); f.render(f.now + 34);
  assert.ok(find(f.tree, "details-card-A"));
  f.settle(); f.render();
  assert.equal(f.mod.hovered, null);
  assert.equal(find(f.tree, "unsettle-A").style.opacity[0], 0, "no undo arrow");
  // And back: an unsettled row is no longer under the pointer either.
  f.mod.hovered = "A"; f.render(); f.settle(); f.render();
  assert.equal(f.mod.hovered, null);
  // The pointer on another row stays on it.
  f.event("card-B", "on_hover", true); f.settle(); f.render();
  assert.equal(f.mod.hovered, "B");
});


test("settling shows T3's undo notice over the first shelf for 5s; Undo puts them back where they were", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); a.focused = true; f.mod.listH = 600;
  f.render(); f.settle(); f.render(1000);
  const note = () => { const walk = (n) => !n || typeof n !== "object" ? null : n.key?.startsWith("undo-notice-") && n.key !== "undo-notice-undo" ? n : n.items.map(walk).find(Boolean) ?? null; return walk(f.tree); };
  assert.deepEqual([texts(note())[0], note().style.opacity[0]], ["Settled 1 agent,", 0], "a frame clear, then it fades in");
  f.render(1016);
  assert.equal(note().style.opacity[0], 1);
  assert.ok(find(find(f.tree, "shelves"), "undo-notice-undo"), "over the first shelf's header, as T3 hosts it");
  const undo = find(f.tree, "undo-notice-undo");
  assert.ok("font_medium" in undo.style && "hover" in undo.style, "as T3's InlineButton: medium, underlined on hover");
  // A second settle soon after joins the same notice.
  f.rows.find((x) => x.address === "B").focused = true; a.focused = false; f.settle(); f.render(2000);
  assert.equal(texts(note())[0], "Settled 2 agents,");
  f.event("undo-notice-undo", "on_click");
  assert.deepEqual([f.mod.pending.settled.A, f.mod.pending.settled.B], ["", ""], "both come back, as they were: no news");
  f.render(2016);
  assert.equal(note().style.opacity[0], 0, "fading out");
  f.render(2300);
  assert.equal(note(), null);
  // Left alone, it goes after 5s.
  f.rows.find((x) => x.address === "A").focused = true; f.settle(); f.render(3000); f.render(3016);
  assert.equal(note().style.opacity[0], 1);
  f.render(8000); assert.equal(note().style.opacity[0], 0); assert.equal(find(f.tree, "undo-notice-undo"), null, "no Undo once it's going");
  f.render(8300); assert.equal(note(), null);
});

test("with the layout's footer there, the notice goes to it, as T3's footer row hosts it; its Undo comes back as a command", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); a.focused = true;
  f.context.layout = () => ({ children: [{ id: "sidebar-lists", active: "inbox" }, { id: "sidebar-footer", content: { mod: "t3-chrome", props: { footer: true } } }] });
  f.render(); f.settle(); f.render(1000);
  assert.equal(find(f.tree, "undo-notice-1"), null, "nothing over the list");
  assert.deepEqual(plain(f.state["t3-inbox.notice"]), { action: "Settled", count: 1, gen: 1, shown: false, live: true, at: 1000 });
  f.render(1016); assert.equal(f.state["t3-inbox.notice"].shown, true, "then it fades in, there");
  f.mod.undo(f.cx);
  assert.equal(f.mod.pending.settled.A, "");
  f.render(1016); assert.deepEqual([f.state["t3-inbox.notice"].live, f.state["t3-inbox.notice"].shown], [false, false], "fading out");
  f.render(1300); assert.equal(f.state["t3-inbox.notice"], null);
  const writes = f.jobs.length; f.mod.undo(f.cx); assert.equal(f.jobs.length, writes, "an Undo pressed as it goes does nothing");
});

test("folding Working slides its header down with the list, as T3's markers move, so nothing passes over it", () => {
  const f = fixture(), a = f.add("A", "working", 300); f.add("B", "working", 200); f.add("C", "idle", 100); a.focused = true;
  f.terms[2].labels.settled = "500:0"; f.mod.workOpen = true; f.mod.open = true; f.mod.listH = 600; f.render();
  f.mod.workOpen = false; f.render(1100);
  assert.deepEqual(at(flyOf(f, "m:working")), { id: "fly-m:working-1", top: -83, opacity: 1 }, "the header starts where it was, a card higher");
  assert.equal(flyOf(f, "m:settled").key, "fly-m:settled-0", "Settled sits at the bottom: it doesn't move");
  assert.ok(find(f.tree, "working-header"), "the header's own element is inside its wrapper");
  f.render(1116);
  assert.equal(at(flyOf(f, "m:working")).top, 0);
  f.mod.workOpen = true; f.render(1300);
  assert.equal(at(flyOf(f, "m:working")).top, 83, "unfolding, it goes back up from where it was");
});

test("an agent brought into view that the space filter hides widens it, as T3's route reveal; a filter you pick stays", () => {
  const f = fixture(), a = f.add("A", "idle", 300), b = f.add("B", "idle", 200); b.space = "s2"; b.space_name = "Two";
  a.focused = true; f.mod.scope = ["s1"]; f.render();
  assert.deepEqual(f.active(), ["A"]);
  a.focused = false; b.focused = true; f.render(1100);
  assert.deepEqual([[...f.mod.scope], f.data.get("scope")], [[], "[]"], "kept: the filter is all spaces now");
  assert.ok(f.active().includes("B"));
  f.mod.pick({ id: "s1" }, false, f.cx); f.render(1200);
  assert.deepEqual([...f.mod.scope], ["s1"], "picked while B is in view, the filter holds");
  // A fresh inbox (a reload) leaves the filter as it was, as T3's mount doesn't widen.
  const g = fixture(), c = g.add("C", "idle"); c.space = "s2"; c.focused = true; g.mod.scope = ["s1"]; g.render();
  assert.deepEqual([...g.mod.scope], ["s1"]);
});

test("a sub-agent in view with no row of its own lights its parent's card, as T3's", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200);
  f.terms.push({ address: "c1", parent: "A", state: "live", status: "idle", labels: {} });
  f.context.focused = () => ({ terminal: "c1" }); f.render();
  assert.ok("bg" in find(f.tree, "card-A").style, "A is the row in view");
  assert.ok(!("bg" in find(f.tree, "card-B").style));
  f.mod.settleKey(f.cx);
  assert.match(f.mod.pending.settled.A ?? "", /^\d+:/, "the settle key acts on it too");
});

test("a mod pane in view, a review in a tab of its own, lights no card: Herdr's agent then falls back to the first", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200);
  f.context.focused = () => ({ pane: "pm", tab: "own", terminal: null, agent: "A" }); f.render();
  assert.ok(!("bg" in find(f.tree, "card-A").style) && !("bg" in find(f.tree, "card-B").style));
  // An agent block has no pane: its agent is the one shown, and lit.
  f.context.focused = () => ({ pane: null, terminal: "B", agent: "B" }); f.render();
  assert.ok("bg" in find(f.tree, "card-B").style);
});

test("a mod pane in view beside an agent, a review split off it, lights that agent's card, and the keys go on from it", () => {
  const f = fixture(), a = f.add("A", "idle", 300), b = f.add("B", "idle", 200), c = f.add("C", "idle", 100);
  a.tab = "ta"; b.tab = "tb"; c.tab = "tb";
  f.context.focused = () => ({ pane: "pm", tab: "tb", terminal: null, agent: "A" }); f.render();
  assert.ok("bg" in find(f.tree, "card-B").style, "Herdr's fallback is another tab's agent: the tab's first");
  assert.ok(!("bg" in find(f.tree, "card-A").style) && !("bg" in find(f.tree, "card-C").style));
  assert.equal(f.state["t3-inbox.rows"].view, "B");
  f.context.focused = () => ({ pane: "pm", tab: "tb", terminal: null, agent: "C" }); f.render();
  assert.ok("bg" in find(f.tree, "card-C").style, "the agent chosen in that tab, if there is one");
});

const REVIEW = "card-pane:pm";
const plain = (x) => JSON.parse(JSON.stringify(x));

test("a review in a tab with no agent is a card, at the top of Active when it opens", () => {
  const f = fixture(); f.add("A", "idle", 300); f.review(); f.render();
  assert.deepEqual(f.active(), ["pane:pm", "A"], "opened now, not news from before we were watching");
  const words = texts(find(f.tree, REVIEW));
  assert.ok(words.includes("One") && words.includes("pm vs main"), "which project, and which diff");
  const images = (n) => !n || typeof n !== "object" ? [] : [...(n.style?.image ?? []), ...n.items.flatMap(images)];
  assert.deepEqual(images(find(f.tree, REVIEW)), ["mods/review/icons/logo.svg"], "and what it is, where an agent's card has its program");
  assert.equal(find(f.tree, "settle-pane:pm") && f.mod.pending.settled["pane:pm"], undefined);
});

test("only a mod pane that asks, in a tab with no agent, gets a card", () => {
  const f = fixture(); f.add("A", "idle", 300).tab = "tr"; f.review(); f.render();
  assert.equal(find(f.tree, REVIEW), null, "beside an agent, the agent's card leads to it");
  const g = fixture(); g.add("A", "idle", 300); g.review(); delete g.state["review.program"]; g.render();
  assert.equal(find(g.tree, REVIEW), null, "a mod that publishes nothing, or no review mod at all");
  g.state["review.program"] = { icon: "x" }; g.render();
  assert.equal(find(g.tree, REVIEW), null, "an icon isn't asking: it's for tabs and pane headers");
  const h = fixture(); h.add("A", "idle", 300); h.state["review.titles"] = { gone: "old" }; h.state["review.program"] = { icon: "x", inbox: true }; h.render();
  assert.deepEqual(cards(h.tree), ["A"], "what's left in shared of a closed tab draws nothing");
  const two = fixture(); two.review("pm", "tr"); two.state["other.program"] = { icon: "x", inbox: true };
  const now = two.context.panes();
  two.context.panes = () => [...now, { pane: "pn", mod: "review", tab: "tr", title: "review", terminal: null }];
  two.render();
  assert.deepEqual(cards(two.tree), ["pane:pm"], "one a tab: titles go by tab");
});

test("a layout gives a split Review its own card and focus even beside a focused agent", () => {
  const f = fixture(), a = f.add("A"); a.tab = "tr"; a.focused = true; f.review();
  f.context.props = () => ({ home: "t3-tabs.home" });
  f.context.focused = () => ({ space: "s1", pane: "pm", tab: "tr", terminal: null, agent: "A" });
  f.render();
  assert.ok(find(f.tree, REVIEW) && find(f.tree, "card-A"));
  assert.ok("bg" in find(f.tree, REVIEW).style);
  assert.ok(!("bg" in find(f.tree, "card-A").style));
  assert.equal(f.state["t3-inbox.rows"].view, "pane:pm");
  f.settle();
  assert.deepEqual(plain(f.calls), [["t3-tabs.close-pane:pm", null]], "Review returns through its close path, without Home or a label");
  assert.deepEqual(plain(f.mod.pending), { settled: {}, snoozed: {} });
});

test("each mod pane asking for Inbox gets its own layout card, including two in one tab", () => {
  const f = fixture(); f.add("A").tab = "tr"; f.review();
  const ps = f.context.panes(); f.context.panes = () => [...ps, { pane: "pn", mod: "notes", tab: "tr", title: "Notes" }];
  f.state["notes.program"] = { inbox: true };
  f.context.props = () => ({ home: "t3-tabs.home" }); f.render();
  assert.deepEqual(cards(f.tree).sort(), ["A", "pane:pm", "pane:pn"]);
});

test("any mod that asks gets a card, by the same rules", () => {
  const f = fixture(); f.review("pm", "t1", "s2");
  const now = f.context.panes(), tabs = f.context.spaces();
  f.state["notes.program"] = { icon: "x", name: "Notes", inbox: true }; f.state["notes.titles"] = { t9: "todo" };
  f.context.panes = () => [...now, { pane: "pz", mod: "notes", tab: "t9", title: "notes", terminal: null }];
  f.context.spaces = () => tabs.map((s) => s.id === "s1" ? { ...s, tabs: [...s.tabs, { id: "t9" }] } : s);
  f.render();
  assert.deepEqual(cards(f.tree).sort(), ["pane:pm", "pane:pz"]);
  assert.ok(texts(find(f.tree, "card-pane:pz")).includes("todo"));
});

test("a review's card goes where its run says: Working while it analyzes, back on top of Active when it ends", () => {
  const f = fixture(); f.mod.workOpen = true; f.add("A", "idle", 300); f.review(); f.render(1000);
  f.add("B", "idle", 1050); f.render(1100);
  assert.deepEqual(f.active().slice(0, 1), ["B"], "newer news goes above it");
  f.state["review.status"] = { tr: "working" }; f.render(2000);
  assert.ok(f.working().includes("pane:pm"), "busy, on the shelf");
  assert.ok(!f.active().includes("pane:pm"));
  assert.ok(texts(find(f.tree, REVIEW)).includes("Working"));
  f.state["review.status"] = { tr: "done" }; f.render(3000);
  assert.ok(f.working().includes("pane:pm"), "the grace, as an agent's");
  f.render(5100);
  assert.deepEqual(f.active()[0], "pane:pm", "it came back to the person");
  assert.ok(texts(find(f.tree, REVIEW)).includes("Done"));
  f.state["review.status"] = {}; f.render(6000);
  assert.deepEqual(f.active()[0], "pane:pm", "looking at it moves nothing");
  assert.ok(!texts(find(f.tree, REVIEW)).includes("Done"));
  f.state["review.status"] = { tr: "blocked" }; f.render(7000);
  assert.ok(texts(find(f.tree, REVIEW)).includes("Needs you"), "a failure asks");
});

test("clicking a review's card focuses its pane, across spaces", () => {
  const f = fixture(); f.review("pm", "tr", "s2"); f.render();
  f.event(REVIEW, "on_click");
  assert.deepEqual(plain(f.calls.at(-1)), ["pane.focus", { pane: "pm" }]);
});

test("settling a review closes it: no Settled, nothing to undo, and it says so", () => {
  const f = fixture(); f.add("A", "idle", 300); f.review(); f.render();
  f.event(REVIEW, "on_hover", true); f.render();
  assert.ok(find(f.tree, "tip-settle-pane:pm") || find(f.tree, "settle-pane:pm"));
  assert.equal(find(f.tree, "settle-pane:pm").handlers["on_mouse_down:left"], undefined, "no sweep starts from it");
  assert.equal(find(f.tree, "snooze-pane:pm"), null, "no snooze: it has no terminal to hold the label");
  f.calls.length = 0;
  f.event("settle-pane:pm", "on_click");
  assert.deepEqual(plain(f.calls), [["pane.close", { pane: "pm" }]]);
  assert.deepEqual(plain(f.mod.pending), { settled: {}, snoozed: {} }, "no label: it has no terminal");
  assert.equal(f.mod.notice ?? null, null, "no Undo it couldn't keep");
});

test("the settle key on the review in view moves on to the next card, then closes it", () => {
  const f = fixture(); f.add("A", "idle", 300); f.review();
  f.context.focused = () => ({ pane: "pm", tab: "tr", terminal: null, agent: "A" }); f.render();
  assert.ok("bg" in find(f.tree, REVIEW).style, "lit, and no agent's card is");
  assert.ok(!("bg" in find(f.tree, "card-A").style));
  f.calls.length = 0; f.settle();
  assert.deepEqual(plain(f.calls), [["agent.focus", { terminal: "A" }], ["pane.close", { pane: "pm" }]]);
});

// As a layout with a Home passes it to the Inbox, with the person there or not.
const atHome = (f, where = "home") => {
  f.state["t3-home.space"] = "home";
  f.context.props = () => ({ home: "t3-tabs.home" });
  f.context.focused = () => ({ space: where, tab: "th", pane: "ph", terminal: null, agent: "B" });
};

test("with a Home, Settle and Snooze on the agent in view land there, not on the next card", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200);
  f.state["t3-home.space"] = "home"; f.context.props = () => ({ home: "t3-tabs.home" });
  a.focused = true; f.render(); f.calls.length = 0;
  f.settle();
  assert.deepEqual(plain(f.calls), [["t3-tabs.home"]]);
  const s = fixture(), b = s.add("A", "idle", 300); s.add("B", "idle", 200);
  s.state["t3-home.space"] = "home"; s.context.props = () => ({ home: "t3-tabs.home" });
  b.focused = true; s.render(); s.calls.length = 0;
  s.mod.customSnooze(`A:${Date.now() + 3600000}`, s.cx);
  assert.deepEqual(plain(s.calls), [["t3-tabs.home"]]);
});

test("with a Home, settling Review uses the tab bar's return path", () => {
  const f = fixture(); f.add("A", "idle", 300); f.review(); f.context.props = () => ({ home: "t3-tabs.home" });
  f.context.focused = () => ({ pane: "pm", tab: "tr", terminal: null, agent: "A" }); f.render(); f.calls.length = 0;
  f.settle();
  assert.deepEqual(plain(f.calls), [["t3-tabs.close-pane:pm", null]]);
});

test("with a Home, Undo brings the agent back while the person is still there, and moves nothing once they've gone", () => {
  for (const [where, back] of [["home", true], ["s1", false]]) for (const put of ["settle", "snooze"]) {
    const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200);
    f.state["t3-home.space"] = "home"; f.context.props = () => ({ home: "t3-tabs.home" });
    a.focused = true; f.render();
    if (put === "settle") f.settle();
    else f.mod.customSnooze(`A:${Date.now() + 3600000}`, f.cx);
    a.focused = false; atHome(f, where); f.render(); f.calls.length = 0;
    f.mod.undo(f.cx);
    assert.deepEqual(plain(f.calls), back ? [["agent.focus", { terminal: "A" }]] : [], `${put} from ${where}`);
  }
});

test("with a Home, an agent put away in the background moves nothing, nor does the key with none in view", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200);
  atHome(f); f.render(); f.calls.length = 0;
  f.settle();
  assert.deepEqual(plain(f.calls), [], "the key at Home takes no agent with it");
  f.mod.customSnooze(`A:${Date.now() + 3600000}`, f.cx);
  assert.deepEqual(plain(f.calls), [], "nor does putting one away from there");
});

test("from Home the next key opens the top card: nothing is in view", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200);
  atHome(f); f.render();
  assert.deepEqual(plain(f.state["t3-inbox.rows"]), { order: ["A", "B"], view: null });
});

test("the agents list lights no one on a mod pane with no agent in its tab, and lights the one beside it", { skip: !lists && "t3-agents isn't here" }, () => {
  const f = fixture(), a = f.add("A", "idle", 300);
  a.tab = "ta"; f.mode = "lists"; f.env.layout = () => ({ id: "sidebar-lists", active: "lists" });
  f.env.focused = () => ({ tab: "th", pane: "ph", terminal: null, agent: "A" });
  assert.equal(find(f.loadAgents()(), "ag-A"), null, "folded away, and Home isn't where it is");
  f.env.focused = () => ({ tab: "ta", pane: "ph", terminal: null, agent: "A" });
  assert.ok(find(f.loadAgents()(), "ag-A"), "beside it, a folded row still shows the one in view");
});

test("a review analyzing or failed offers no Settle, by key or on hover, as a busy agent", () => {
  const f = fixture(); f.review(); f.state["review.status"] = { tr: "working" };
  f.context.focused = () => ({ pane: "pm", tab: "tr", terminal: null, agent: null }); f.render();
  f.calls.length = 0; f.settle();
  assert.deepEqual(plain(f.calls), []);
  f.state["review.status"] = { tr: "blocked" }; f.render();
  f.event(REVIEW, "on_hover", true); f.render();
  assert.equal(find(f.tree, "settle-pane:pm").handlers.on_click, undefined);
  f.settle();
  assert.deepEqual(plain(f.calls), []);
});

test("a review's card can't be lifted, nor swept along with agents", () => {
  const f = fixture(); f.add("A", "idle", 300); f.review(); f.render();
  f.event(REVIEW, "on_mouse_down:left");
  assert.equal(f.mod.drag ?? null, null);
  f.event("card-A", "on_hover", true); f.render();
  f.event("settle-A", "on_mouse_down:left"); f.mod.sweep.moved = true; f.render();
  f.event(REVIEW, "on_mouse_move");
  assert.deepEqual([...f.mod.sweep.keys], ["A"]);
});

test("the keys walk a review's card in the order drawn; Herdr's agent.next knows agents only", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("W", "working", 200); f.add("C", "idle", 100); f.review();
  f.mod.workOpen = true; f.terms[2].labels.settled = "500:0"; f.mod.open = true;
  f.context.focused = () => ({ pane: "pm", tab: "tr", terminal: null, agent: "A" }); f.render();
  const rows = f.state["t3-inbox.rows"];
  assert.deepEqual([...rows.order], ["pane:pm", "A", "W", "C"]);
  assert.equal(rows.view, "pane:pm");
  assert.deepEqual([...f.order], ["A", "W", "C"]);
});

test("the space filter hides a review's card, and one brought into view from elsewhere widens it", () => {
  const f = fixture(); f.add("A", "idle", 300); f.review("pm", "tr", "s2");
  f.mod.scope = ["s1"]; f.render();
  assert.equal(find(f.tree, REVIEW), null);
  assert.ok(!f.state["t3-inbox.rows"].order.includes("pane:pm"));
  f.context.focused = () => ({ pane: "pm", tab: "tr", terminal: null, agent: "A" }); f.render(); f.render();
  assert.deepEqual([...f.mod.scope], [], "or the keys would have nowhere to go from it");
  assert.ok(find(f.tree, REVIEW));
  assert.equal(f.state["t3-inbox.rows"].view, "pane:pm");
});

test("a review closed fades where it was, and its record goes with it", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.review(); f.mod.listH = 600; f.render();
  assert.ok(f.mod.changed["pane:pm"]);
  f.context.panes = () => []; f.render();
  assert.ok(find(f.tree, "ghost-card-pane:pm"), "drawn inert while it leaves");
  assert.equal(find(f.tree, REVIEW), null);
  a.status = "working"; f.render();
  assert.equal(f.mod.changed["pane:pm"], undefined, "a pane once closed doesn't come back");
});

test("the rows the next and previous keys walk are the ones drawn, in order, with the one in view", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "working", 200); f.add("C", "idle", 100); f.add("W", "working", 50);
  f.terms[2].labels.settled = "500:0"; a.focused = true; f.render();
  assert.deepEqual(JSON.parse(JSON.stringify(f.state["t3-inbox.rows"])), { order: ["A"], view: "A" }, "folded shelves keep their rows out of the walk");
  f.mod.workOpen = true; f.mod.open = true; f.render();
  const rows = f.state["t3-inbox.rows"];
  assert.deepEqual([...rows.order].sort(), ["A", "B", "C", "W"]);
  assert.equal(rows.order[0], "A");
  assert.equal(rows.order.at(-1), "C", "Settled last, as drawn");
  f.render(); assert.equal(f.state["t3-inbox.rows"], rows, "unchanged, it isn't written again: every write redraws every mod");
});

test("a hovered row that leaves the list (to the folded Working shelf) and comes back brings no card or Settle with it", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200);
  f.render();
  f.event("card-A", "on_hover", true); f.render(f.now + 50); f.render(f.now + 200);
  assert.ok(find(f.tree, "details-card-A"));
  // Gone from the list, no pointer-leave ever comes for it.
  a.status = "working"; f.terms[0].status = "working"; f.render(f.now + 100);
  assert.ok(!f.active().includes("A"));
  a.status = "done"; f.terms[0].status = "done"; f.terms[0].turn++;
  f.render(f.now + 100); f.render(f.now + 3000); f.render(f.now + 100);
  assert.ok(f.active().includes("A"));
  assert.equal(find(f.tree, "details-card-A"), null, "no card: the pointer left long ago");
  assert.equal(find(f.tree, "settle-A").handlers.on_click, undefined, "no Settle offer either");
});

test("the snooze menu is T3's: soonest first, one row per wake minute, tonight gone once past", () => {
  const f = fixture(); f.add("A", "working"); f.mod.workOpen = true; f.mod.hovered = "A";
  const at = (day, h, m = 0) => new Date(2026, 10, day, h, m).getTime();
  const offered = (now) => {
    f.mod.napMenu = "A"; f.render(now);
    const panel = find(f.tree, "snooze-panel-A");
    return panel.items.filter((row) => row.key && !texts(row).includes("Custom…")).map((row) => texts(row).join(" "));
  };
  assert.deepEqual(offered(at(3, 10)), ["In 1 hour 11:00 am", "In 3 hours 1:00 pm", "This evening 6:00 pm", "Tomorrow 9:00 am", "Next week Mon 9:00 am"]);
  assert.deepEqual(offered(at(3, 15)), ["In 1 hour 4:00 pm", "In 3 hours 6:00 pm", "Tomorrow 9:00 am", "Next week Mon 9:00 am"], "6 pm from either shows once");
  assert.deepEqual(offered(at(3, 19)), ["In 1 hour 8:00 pm", "In 3 hours 10:00 pm", "Tomorrow 9:00 am", "Next week Mon 9:00 am"], "tonight's past");
  assert.deepEqual(offered(at(3, 22)), ["In 1 hour 11:00 pm", "In 3 hours Wed 1:00 am", "Tomorrow 9:00 am", "Next week Mon 9:00 am"], "another day names it");
  assert.deepEqual(offered(at(8, 10)).slice(-1), ["Tomorrow 9:00 am"], "on a Sunday next week is tomorrow");
  f.render(at(3, 10));
  for (let i = 0; i < 4; i++) f.event("snooze-panel-A", "on_key_down", { key: "down" });
  f.event("snooze-panel-A", "on_action:t3_inbox_snooze_pick"); f.flush();
  assert.deepEqual(f.labelled, [`label A snoozed=${at(4, 9)}`], "keys pick; tomorrow is the next calendar day at 9:00");
});

test("the Custom dialog's calendar walks by the arrows, stopping at today, and Enter picks where the keys are", () => {
  const f = fixture(); f.now = new Date(2026, 10, 30, 10, 0).getTime();
  f.context.props = () => ({ customSnooze: "A", overlay: "o1" });
  const d = new f.context.Mod(); d.init({}, f.cx);
  let tree = d.render(f.cx);
  find(tree, "custom-date").handlers.on_open_change(true, f.cx); tree = d.render(f.cx);
  const panel = () => find(tree, "custom-calendar");
  const key = (k) => { panel().handlers.on_key_down({ key: k }, f.cx); tree = d.render(f.cx); };
  const pickDay = () => { panel().handlers["on_action:t3_inbox_day_pick"]({}, f.cx); tree = d.render(f.cx); };
  assert.deepEqual([d.calendarOpen, d.dayAt], [true, null], "nothing's walked yet");
  assert.equal(panel().style.track_focus[0], find(tree, "custom-date").style.track_focus[0], "the keyboard moves to the panel");
  assert.deepEqual(Array.from(f.bound, (b) => b.keystroke), ["enter", "space"], "bound deeper than the Popover's, which would only close it");
  assert.equal(f.bound[0].context, panel().style.key_context[0]);
  const from = d.date.getDate();
  key("left");
  assert.equal(d.dayAt, null, "yesterday's gone by");
  key("right");
  assert.ok(texts(panel()).includes("December 2026"), "the month follows");
  assert.equal(d.dayAt.getDate(), 1);
  assert.equal(d.date.getDate(), from, "keys move the walk, not the choice");
  key("down"); key("up"); key("down");
  assert.equal(d.dayAt.getDate(), 8);
  pickDay();
  assert.deepEqual([d.date.getMonth(), d.date.getDate(), d.calendarOpen], [11, 8, false]);
  find(tree, "custom-date").handlers.on_open_change(true, f.cx); d.calendarOpen = true; tree = d.render(f.cx);
  assert.ok(texts(panel()).includes("December 2026"), "it opens on the day chosen");
  pickDay();
  assert.deepEqual([d.date.getDate(), d.calendarOpen], [8, false], "with no walk, Enter keeps it");
});

// The fixture has no focus path. What it takes for keys to arrive at all: the handle a Popover moves the keyboard to is
// on the panel, and Enter and Space, the Popover's own, are bound deeper in (checked for real against gpui-shell).
test("the snooze menu's keys are wired to reach it", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render(); f.mod.hovered = "A"; f.render();
  f.event("snooze-menu-A", "on_open_change", true); f.render();
  const pop = find(f.tree, "snooze-menu-A"), panel = find(f.tree, "snooze-panel-A");
  assert.deepEqual(JSON.parse(JSON.stringify([panel.style.opacity, panel.style.transition])), [[0], ["opacity", { duration: 150, easing: "ease-out" }]], "drawn clear once, as T3's menu fades in");
  f.render(f.now + 16); assert.equal(find(f.tree, "snooze-panel-A").style.opacity[0], 1, "then let go");
  assert.ok(panel.style.track_focus[0]);
  assert.equal(panel.style.track_focus[0], pop.style.track_focus[0], "the keyboard moves to the panel");
  assert.deepEqual(Array.from(f.bound, (b) => b.keystroke), ["enter", "space"]);
  for (const b of f.bound) {
    assert.equal(b.context, panel.style.key_context[0]);
    assert.ok(panel.handlers[`on_action:${b.action}`]);
  }
});

test("the clock opens its menu without lifting or opening the card, and the card's details step aside", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render(); f.mod.hovered = "A"; f.render();
  find(f.tree, "snooze-A").handlers.on_hover(true, f.cx); f.render();
  f.event("card-A", "on_mouse_down:left"); assert.equal(f.mod.drag ?? null, null);
  f.event("card-A", "on_click"); assert.deepEqual(f.calls, []);
  f.event("snooze-menu-A", "on_open_change", true);
  assert.equal(f.mod.napMenu, "A");
  find(f.tree, "snooze-A").handlers.on_hover(false, f.cx); f.mod.hovered = null; f.render();
  assert.equal(find(f.tree, "snooze-A").style.opacity[0], 1, "the pointer has left the card; the clock stays with its menu");
  assert.ok(find(f.tree, "snooze-panel-A"));
  f.mod.details = "A"; f.mod.hovered = "A"; f.render();
  assert.equal(find(f.tree, "details-card-A"), null);
  f.mod.napMenu = null; f.render();
  assert.ok(find(f.tree, "details-card-A"));
});

test("an open snooze menu holds its card as hovered: the pointer going into the menu moves and dims nothing", () => {
  const f = fixture(); f.add("A", "idle", 100); f.add("W", "working"); f.mod.workOpen = true; f.render();
  // Where things sit: what's out of the flow and what's faded, for every control in the corner.
  const layout = (id) => { const walk = (n) => !n || typeof n !== "object" ? [] : [[n.key, "absolute" in n.style, n.style.opacity?.[0]], ...n.items.flatMap(walk)]; return walk(find(f.tree, `corner-${id}`)); };
  const look = (id) => [layout(id), find(f.tree, `card-${id}`).style.opacity[0], holding(f.tree, id).style.text_color[0]];
  f.mod.hovered = "A"; f.render();
  f.event("snooze-menu-A", "on_open_change", true); f.render();
  const before = look("A");
  f.mod.hovered = null; f.render();
  assert.deepEqual(look("A"), before);
  assert.equal(find(f.tree, "settle-A").style.opacity[0], 1, "Settle stays beside the clock");
  assert.ok(find(f.tree, "card-A").style.bg, "and the card keeps its hover ground");
  find(f.tree, "snooze-menu-A").handlers.on_open_change(false, f.cx); f.render();
  assert.equal(find(f.tree, "settle-A").style.opacity[0], 0, "closed, it goes with the hover");
  assert.equal(find(f.tree, "card-A").style.bg, undefined);
  f.mod.hovered = "W"; f.render();
  f.event("snooze-menu-W", "on_open_change", true); f.render();
  const working = look("W");
  f.mod.hovered = null; f.render();
  assert.deepEqual(look("W"), working, "a working card doesn't recede under its menu");
});

test("a snoozed agent leaves the cards, working or not; undoing is no news, and it wakes where it was, marked Woke", async () => {
  const f = fixture(), b = f.add("B", "idle", 200); f.add("A", "working", 100); f.add("C", "idle", 300);
  f.mod.workOpen = true; f.mod.napOpen = true; f.mod.listH = 600;
  f.render(); f.mod.hovered = "A"; f.mod.napMenu = "A"; f.render();
  f.event("snooze-0-A", "on_click"); f.flush();
  assert.deepEqual(f.labelled, [`label A snoozed=${1000 + 3600000}`]);
  f.render();
  assert.deepEqual([f.working(), f.napping()], [[], ["A"]], "shown at once, before the label is back");
  const undo = find(f.tree, "undo-notice-undo");
  assert.ok(undo, "T3's undo notice"); undo.handlers.on_click({}, f.cx); f.flush();
  assert.equal(f.labelled.at(-1), "label A snoozed=");
  await new Promise(setImmediate); f.flush();
  f.render(); assert.deepEqual([f.working(), f.napping()], [["A"], []]);
  f.label("A", "snoozed", String(1000 + 3600000)); f.label("B", "snoozed", String(1000 + 600000)); f.render(1000);
  assert.deepEqual(f.napping(), ["B", "A"], "soonest first");
  assert.ok(texts(find(f.tree, "slim-B")).includes("10m"));
  assert.ok(f.timers.some((t) => !t.cancelled && t.at === 601000), "a timer for the next wake");
  assert.deepEqual(f.order, ["C", "B", "A"], "agent.next reads as the list, snoozed after the cards");
  f.render(601000);
  assert.deepEqual([f.active(), f.napping()], [["C", "B"], ["A"]], "not on top: its own place, as T3's static sort");
  assert.ok(texts(find(f.tree, "woke-B")).includes("Woke"));
  assert.equal(find(f.tree, "tip-woke-B").style.anchor[0], "bottom_center", "its label opens above, as T3's, leaving the title readable");
  assert.ok("font_medium" in holding(f.tree, "B").style, "Woke leads as Done does");
  // Hovered, Woke stays beside the controls; any other state makes way.
  f.mod.hovered = "B"; f.render(601000);
  assert.equal(find(f.tree, "woke-B").style.opacity, undefined);
  assert.ok(!("absolute" in find(f.tree, "controls-B").style));
  f.mod.hovered = "C"; f.render(601000);
  assert.ok(!("absolute" in find(f.tree, "controls-C").style), "the controls take the slot");
  // Looking drops Woke and the snooze, and leaves it where it is.
  f.labelled.length = 0;
  b.focused = true; f.render(602000); f.flush();
  assert.deepEqual(f.labelled, ["label B snoozed="]);
  f.label("B", "snoozed", ""); b.focused = false; f.render(603000);
  assert.deepEqual(f.active(), ["C", "B"]);
  assert.equal(find(f.tree, "woke-B"), null);
});

test("clicking Woke dismisses it, leaving the card alone", () => {
  const f = fixture(); f.add("A", "idle", 200); f.label("A", "snoozed", "500");
  f.render();
  f.event("woke-A", "on_mouse_down:left"); f.event("woke-A", "on_click"); f.flush();
  assert.deepEqual([f.labelled, f.calls], [["label A snoozed="], []]);
});

test("a snoozed agent shows while it needs the person; a failure ends the snooze", () => {
  const f = fixture(), a = f.add("A", "blocked"); f.mod.napOpen = true;
  f.mod.hovered = "A"; f.render();
  assert.equal(find(f.tree, "snooze-A"), null, "needing the person, it can't be snoozed");
  a.status = "working"; f.label("A", "snoozed", String(3600000)); f.render(2000);
  assert.deepEqual(f.napping(), ["A"]);
  a.status = "blocked"; f.render(3000);
  assert.deepEqual([f.active(), f.napping()], [["A"], []]);
  assert.ok(texts(find(f.tree, "state-A")).includes("Needs you"));
  a.status = "working"; f.render(4000);
  assert.deepEqual(f.napping(), ["A"], "answered, it goes back");
  assert.deepEqual(f.labelled, []);
  a.status = "done"; f.terms[0].status = "error"; f.render(5000); f.flush();
  assert.deepEqual(f.labelled, ["label A snoozed="]);
  assert.deepEqual(f.active(), ["A"]);
});

test("an open menu holds keyboard mode only while the keyboard's in it", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render();
  f.mod.napMenu = "A";
  assert.equal(Boolean(f.mod.fs.hold()), false, "open, the keyboard elsewhere (the Inbox hid with it open): no hold");
  f.mod.napKeys.focus();
  assert.equal(Boolean(f.mod.fs.hold()), true, "the keyboard in the snooze menu holds it");
  f.mod.napMenu = null; f.held = null; f.mod.scopeOpen = true;
  f.mod.search.heard.focus({}, f.cx);
  assert.equal(Boolean(f.mod.fs.hold()), true, "typing in the space filter holds it");
  f.mod.search.heard.blur({}, f.cx);
  assert.equal(Boolean(f.mod.fs.hold()), false, "the filter left open, the keyboard gone: no hold");
});

test("an open menu closes when its card comes to need the person", () => {
  const f = fixture(), a = f.add("A", "working"); f.mod.workOpen = true; f.mod.hovered = "A"; f.mod.napMenu = "A"; f.render();
  a.status = "blocked"; f.render(2000);
  assert.equal(f.mod.napMenu, null);
  a.status = "working"; f.render(3000);
  assert.equal(find(f.tree, "snooze-panel-A"), null);
});

test("Wake, pinning and Settle end a snooze; a pinned agent snoozes and keeps its pin", () => {
  const f = fixture(); f.add("A", "idle", 100); f.add("B", "idle", 200); f.add("P", "idle", 300); f.pins = ["P"]; f.mod.napOpen = true;
  f.render(); f.mod.hovered = "P"; f.mod.napMenu = "P"; f.render();
  f.event("snooze-0-P", "on_click"); f.flush();
  f.label("P", "snoozed", String(3601000)); f.mod.hovered = null; f.render(2000);
  assert.deepEqual([f.pins, cards(f.tree), f.napping()], [["P"], ["B", "A"], ["P"]]);
  f.label("P", "snoozed", ""); f.render(3000);
  assert.deepEqual(cards(f.tree), ["P", "B", "A"], "awake, it's back among the pins");
  // Wake leaves it where it was.
  f.label("A", "snoozed", String(3600000)); f.render(4000);
  f.mod.hovered = "A"; f.render(4000); f.event("wake-A", "on_mouse_down:left"); f.event("wake-A", "on_click"); f.flush();
  assert.equal(f.labelled.at(-1), "label A snoozed=");
  f.label("A", "snoozed", ""); f.render(5000);
  assert.deepEqual(f.active(), ["B", "A"]);
  // Pinning a snoozed agent wakes it: the drag does, as the agents list's pin does (it's the action's, not a pin seen later).
  f.label("B", "snoozed", String(3600000)); f.mod.listH = 600; f.render(6000);
  f.mod.drag = { from: "B", moved: true, y: 100, grab: 10, height: 30, target: { section: "pinned", before: null } }; f.render(7000);
  f.event("t3-inbox-root", "on_mouse_up:left"); f.flush();
  assert.equal(f.labelled.at(-1), "label B snoozed=");
  assert.deepEqual(f.pins, ["P", "B"]);
  f.mod.dropped = 0;
  // Settling a woken agent ends its snooze too.
  f.pins = ["P"]; f.label("B", "snoozed", ""); f.render(7400); f.label("B", "snoozed", "7500"); f.render(8000);
  assert.ok(find(f.tree, "woke-B"));
  f.mod.hovered = "B"; f.render(8000); f.event("settle-B", "on_click"); f.flush();
  assert.ok(f.labelled.includes("label B snoozed="));
});

test("snoozing the agent in view moves on; opened from the shelf it stays, until it's given work", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); a.focused = true;
  f.render(); f.mod.hovered = "A"; f.mod.napMenu = "A"; f.render();
  f.event("snooze-1-A", "on_click");
  assert.deepEqual([f.calls.at(-1)[0], f.calls.at(-1)[1].terminal], ["agent.focus", "B"]);
  f.flush(); f.label("A", "snoozed", String(1000 + 3 * 3600000)); f.render(2000);
  f.event("slim-A", "on_click");
  assert.equal(f.calls.at(-1)[1].terminal, "A", "a click opens it");
  f.render(3000); assert.equal(f.labelled.length, 1, "looking doesn't wake it");
  assert.deepEqual(f.napping(), ["A"], "the one in view shows on the folded shelf");
  a.status = "working"; f.render(4000); f.flush();
  assert.equal(f.labelled.at(-1), "label A snoozed=", "a new turn while in view wakes it");
});

test("a drag wakes a row out of the shelf, with its badge; nothing drags in, and a sweep wakes the run", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.add("C", "idle", 100); f.mod.napOpen = true; f.mod.listH = 600;
  f.label("A", "snoozed", "3600000"); f.label("B", "snoozed", "3700000"); f.render();
  assert.deepEqual([f.napping(), f.order], [["A", "B"], ["C", "A", "B"]]);
  // A card lifted over the shelf has nowhere to land.
  f.mod.drag = { from: "C", moved: true, y: 400, grab: 10, height: 82, target: { section: "active" } }; f.render();
  f.event("slim-A", "on_mouse_move");
  assert.equal(f.mod.drag.target, null);
  f.event("t3-inbox-root", "on_mouse_up:left"); f.flush();
  assert.deepEqual(f.labelled, []);
  // Out of it into Active.
  f.mod.drag = { from: "A", moved: true, y: 100, grab: 10, height: 30, target: { section: "active" } }; f.render();
  assert.ok(find(f.tree, "badge-wake"), "the lifted row says Wake");
  assert.ok(find(f.tree, "ghost-slim-A"));
  f.event("t3-inbox-root", "on_mouse_up:left"); f.flush();
  assert.deepEqual(f.labelled, ["label A snoozed="]);
  f.label("A", "snoozed", ""); f.mod.dropped = 0; f.render(2000);
  assert.deepEqual([f.active(), f.napping()], [["A", "C"], ["B"]]);
  // A pinned one dragged out wakes where it was, as Wake does: its badge says Wake, not Unpin.
  const g = fixture(); g.add("P", "idle", 300); g.add("Q", "idle", 200); g.pins = ["P"]; g.mod.napOpen = true; g.mod.listH = 600;
  g.label("P", "snoozed", "3600000"); g.render();
  g.mod.drag = { from: "P", moved: true, y: 100, grab: 10, height: 30, target: { section: "active" } }; g.render();
  assert.ok(find(g.tree, "badge-wake"));
  g.event("t3-inbox-root", "on_mouse_up:left"); g.flush();
  assert.deepEqual([g.pins, g.labelled, g.mod.notice ?? null], [["P"], ["label P snoozed="], null]);
  // A sweep over the shelf's rows wakes them all.
  f.label("A", "snoozed", "3600000"); f.labelled.length = 0; f.render(3000); f.mod.hovered = "A"; f.render(3000);
  f.event("wake-A", "on_mouse_down:left");
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 20, y: 300 } }); f.render(3000);
  f.event("slim-B", "on_mouse_move"); f.render(3000);
  assert.ok(find(f.tree, "badge-wake"));
  f.event("t3-inbox-root", "on_mouse_up:left"); f.flush();
  assert.deepEqual(f.labelled, ["label A snoozed=", "label B snoozed="]);
});

test("folding Snoozed slides its header with the list, between Working and Settled", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.add("C", "working", 100); f.mod.listH = 600;
  f.label("A", "snoozed", "3600000"); f.label("B", "settled", "500:0"); f.render();
  const kids = find(f.tree, "shelves").items.map((n) => n.key).filter(Boolean);
  assert.ok(kids.indexOf("snoozed") > -1 && kids.indexOf("snoozed") < kids.indexOf("settled"));
  assert.ok(f.mod.motion.at.has("m:snoozed"), "a marker, so rows don't pass over it");
  const y = f.mod.motion.at.get("m:snoozed").y;
  f.mod.napOpen = true; f.render(1100);
  assert.ok(f.mod.motion.at.get("m:snoozed").y < y, "opened, it moves up to make room");
  assert.deepEqual(f.napping(), ["A"]);
});

test("a run that stops under a snooze skips the grace, as a settled one's: awake, it's in Active", () => {
  const f = fixture(), a = f.add("A", "working", 100); f.label("A", "snoozed", "1500"); f.render();
  a.status = "idle"; f.render(1200);
  f.render(1600);
  assert.deepEqual([f.active(), f.working()], [["A"], []]);
});

test("the next and previous keys walk the shelf's rows when it's open, and only the one in view when it's folded", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); f.add("C", "idle", 100);
  f.label("A", "snoozed", "3600000"); f.label("B", "snoozed", "3700000"); f.render();
  assert.deepEqual(Array.from(f.state["t3-inbox.rows"].order), ["C"]);
  a.focused = true; f.render();
  assert.deepEqual(Array.from(f.state["t3-inbox.rows"].order), ["C", "A"]);
  f.mod.napOpen = true; f.render();
  assert.deepEqual(Array.from(f.state["t3-inbox.rows"].order), ["C", "A", "B"]);
});

test("a duration counts from the click; a clock time that passed since the menu was drawn is refused", () => {
  const at = (h, m = 0, s = 0) => new Date(2026, 10, 3, h, m, s).getTime();
  const row = (f, label) => find(f.tree, "snooze-panel-A").items.findIndex((r) => texts(r).includes(label));
  const f = fixture(); f.add("A", "idle", 100); f.add("B", "idle", 90); f.mod.hovered = "A"; f.mod.napMenu = "A"; f.render(at(17, 59, 50));
  const evening = row(f, "This evening");
  f.now = at(18, 0, 10);
  f.event(`snooze-${evening}-A`, "on_click"); f.flush();
  assert.deepEqual(f.labelled, [], "no label for a time gone by");
  assert.equal(f.notifications.at(-1).level, "warning");
  assert.equal(f.mod.notice ?? null, null, "and no Undo for a snooze that didn't happen");
  assert.equal(f.mod.napMenu, "A", "the menu stays, to choose another");
  f.render(at(18, 0, 10));
  assert.equal(row(f, "This evening"), -1);
  assert.equal(find(f.tree, "woke-A"), null);
  f.now = at(18, 0, 40);
  f.event(`snooze-${row(f, "In 1 hour")}-A`, "on_click"); f.flush();
  assert.deepEqual(f.labelled, [`label A snoozed=${at(19, 0, 40)}`], "an hour from the click, not from the draw");
});

test("snoozing with the pointer still on the clock leaves nothing lit: the row opens and details come back", () => {
  const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.mod.napOpen = true; f.mod.listH = 600;
  f.render(); f.mod.hovered = "A"; f.render();
  find(f.tree, "snooze-A").handlers.on_hover(true, f.cx); f.mod.napMenu = "A"; f.mod.napAt = 0; f.render();
  f.event("snooze-panel-A", "on_action:t3_inbox_snooze_pick"); f.flush();
  f.label("A", "snoozed", String(3601000)); f.render(2000);
  assert.equal(f.mod.hot, null);
  f.event("slim-A", "on_click");
  assert.equal(f.calls.at(-1)[1].terminal, "A");
  f.mod.hovered = "B"; f.mod.details = "B"; f.mod.detailsIn = true; f.render(2100);
  assert.ok(find(f.tree, "details-card-B"));
});

test("a label write that keeps failing is tried once a minute from render, and a click still tries at once", async () => {
  const f = fixture(), a = f.add("A", "idle", 100); f.label("A", "snoozed", "5000"); f.render();
  let writes = 0; f.context.hc = async () => { writes++; return { code: 1, stderr: "boom" }; };
  const settle = () => new Promise((r) => setImmediate(r));
  a.focused = true;
  for (let i = 0; i < 4; i++) { f.render(6000 + i); f.flush(); await settle(); }
  assert.deepEqual([writes, f.notifications.length], [1, 1]);
  f.render(6000 + 60000); f.flush(); await settle();
  assert.deepEqual([writes, f.notifications.length], [2, 2], "due again");
  a.focused = false; f.render(); f.flush();
  f.mod.hovered = "A"; f.render(); f.event("woke-A", "on_mouse_down:left"); f.event("woke-A", "on_click"); f.flush(); await settle();
  assert.equal(writes, 3, "the person asked");
});

test("a quick Undo stays undone while its writes are under way, whichever lands last", async () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.mod.open = true; a.focused = true; f.render();
  const held = []; f.context.hc = (args) => new Promise((done) => { f.labelled.push(args.join(" ")); held.push(done); });
  const shown = () => [f.active(), slims(find(f.tree, "settled"))];
  const answer = async (i) => { held[i]({ code: 0 }); await new Promise(setImmediate); f.flush(); };
  f.settle(); f.flush(); f.render();
  assert.deepEqual(shown(), [[], ["A"]]);
  f.mod.undo(f.cx); f.flush(); f.render(1100);
  assert.deepEqual(shown(), [["A"], []]);
  f.label("A", "settled", "1000:0"); f.render(1200);
  assert.deepEqual(shown(), [["A"], []], "the settle lands: still as the Undo left it");
  // Out of order: the Undo's write lands, then the settle's over it.
  f.label("A", "settled", ""); await answer(1); f.render(1300);
  f.label("A", "settled", "1000:0"); await answer(0); f.render(1400);
  assert.deepEqual(shown(), [["A"], []]);
  assert.deepEqual(f.labelled, ["label A settled=1000:0", "label A settled=", "label A settled="], "the latest is said again");
  f.label("A", "settled", ""); await answer(2); f.render(1500);
  assert.deepEqual(shown(), [["A"], []]);
  assert.deepEqual([f.labelled.length, Object.keys(f.mod.pending.settled)], [3, []]);
});

test("undoing a Settle brings back a snooze that hasn't run out", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); f.label("A", "snoozed", "3600000"); a.focused = true; f.render();
  f.settle(); f.flush();
  assert.deepEqual(f.labelled, ["label A settled=1000:0", "label A snoozed="]);
  f.label("A", "settled", "1000:0"); f.label("A", "snoozed", ""); f.render(1100);
  f.labelled.length = 0;
  find(f.tree, "undo-notice-undo").handlers.on_click({}, f.cx); f.flush();
  assert.deepEqual(f.labelled, ["label A settled=", "label A snoozed=3600000"]);
  f.label("A", "settled", ""); f.label("A", "snoozed", "3600000"); f.render(1200);
  assert.deepEqual(f.napping(), ["A"]);
  // Run out by the time of the Undo, it stays awake, as T3's skips an expired restore.
  f.settle(); f.flush(); f.label("A", "settled", "1200:0"); f.label("A", "snoozed", ""); f.render(1300);
  f.labelled.length = 0; f.now = 3600001;
  find(f.tree, "undo-notice-undo").handlers.on_click({}, f.cx); f.flush();
  assert.deepEqual(f.labelled, ["label A settled="]);
});

test("still at work when it wakes, it says Working and Woke; hovered, Woke stays beside the controls", () => {
  const f = fixture(), a = f.add("A", "working", 100); f.mod.workOpen = true; f.label("A", "snoozed", "500"); f.render();
  assert.deepEqual(f.working(), ["A"]);
  const says = () => texts(find(f.tree, "corner-A"));
  assert.ok(says().includes("Working") && says().includes("Woke"));
  f.mod.hovered = "A"; f.render();
  assert.ok(!says().includes("Working") && says().includes("Woke"));
  assert.notEqual(find(f.tree, "woke-A").style.opacity, 0);
  f.mod.hovered = null; a.status = "idle"; f.render(2000); f.render(9000);
  assert.ok(find(f.tree, "woke-A"), "and it's still there when the run ends");
});

test("a run that ends under a snooze lifts the agent when it wakes: it came back to the person, as T3's returns", () => {
  const f = fixture(), a = f.add("A", "idle", 100); f.add("B", "idle", 200); f.add("C", "idle", 300);
  f.label("A", "snoozed", "100000"); f.render();
  a.status = "working"; f.render(2000);
  a.status = "done"; f.terms[0].status = "done"; f.terms[0].turn++; f.render(50000);
  f.render(100001);
  assert.deepEqual(f.active(), ["A", "C", "B"]);
});

test("a pinned card offers Settle beside the clock, as T3's; settling drops the pin, and Undo brings it back in its place", () => {
  const f = fixture(); f.add("P", "idle", 300); f.add("Q", "idle", 200); f.add("A", "idle", 100); f.pins = ["P", "Q"];
  f.render(); f.mod.hovered = "P"; f.render();
  assert.ok(find(f.tree, "settle-P").handlers.on_click);
  assert.ok(find(f.tree, "snooze-P"));
  const anchor = () => find(f.tree, "snooze-menu-P").style.anchor[0];
  assert.equal(anchor(), "top_left", "no press (the keyboard), the flip");
  const press = (right) => { f.event("snooze-P", "on_mouse_down:left", { bounds: { x: right - 24, y: 40, width: 24, height: 20 } }); f.render(); };
  press(174);
  assert.equal(anchor(), "top_left", "no room to the clock's left, as T3's sidebar: flipped to its left edge, the card readable");
  press(300);
  assert.equal(anchor(), "top_right", "room to the clock's left: right edges together, as T3's align=end");
  find(f.tree, "snooze-menu-P").handlers.on_open_change(false, { notify() {} }); f.render();
  assert.equal(anchor(), "top_left", "closing forgets the press");
  f.event("settle-P", "on_click"); f.flush();
  assert.deepEqual(f.pins, ["Q"]);
  assert.deepEqual(f.labelled, ["label P settled=1000:0"]);
  f.label("P", "settled", "1000:0"); f.render(1100);
  f.mod.hovered = "Q"; f.render(1100);
  f.event("settle-Q", "on_click"); f.flush();
  assert.deepEqual(f.pins, []);
  f.label("Q", "settled", "1100:0"); f.render(1200);
  assert.equal(f.mod.notice.count, 2);
  find(f.tree, "undo-notice-undo").handlers.on_click({}, f.cx); f.flush();
  assert.deepEqual(f.pins, ["P", "Q"], "a run undone latest first ends as it began");
  f.label("P", "settled", ""); f.label("Q", "settled", ""); f.render(1300);
  assert.deepEqual(cards(f.tree), ["P", "Q", "A"]);
});

test("Undo puts back the pin it took, in its place, and leaves one made since", () => {
  const f = fixture(); f.add("P", "idle", 300); f.add("Q", "idle", 200); f.add("B", "idle", 100); f.pins = ["P", "Q"];
  f.render(); f.mod.hovered = "P"; f.render();
  f.event("settle-P", "on_click"); f.flush(); f.render(1100);
  f.pins = ["Q", "B"]; f.render(1200);
  f.mod.undo(f.cx);
  assert.deepEqual(f.pins, ["P", "Q", "B"]);
  // A drag's unpin too; one pinned again meanwhile is left alone.
  f.flush(); f.label("P", "settled", ""); f.mod.dropped = 0; f.render(7000); f.mod.listH = 600; f.render(7000);
  f.mod.drag = { from: "P", moved: true, y: 300, grab: 10, height: 30, target: { section: "active" } }; f.render(7000);
  f.event("t3-inbox-root", "on_mouse_up:left"); f.render(7100);
  assert.deepEqual([f.pins, f.mod.notice.action], [["Q", "B"], "Unpinned"]);
  f.pins = ["Q", "C", "B"]; f.mod.undo(f.cx);
  assert.deepEqual(f.pins, ["P", "Q", "C", "B"]);
  f.pins = ["Q", "P"]; f.mod.notice = null; f.render(7200);
  f.mod.drag = { from: "Q", moved: true, y: 300, grab: 10, height: 30, target: { section: "active" } }; f.render(7200);
  f.event("t3-inbox-root", "on_mouse_up:left"); f.pins = ["Q", "P"]; f.mod.undo(f.cx);
  assert.deepEqual(f.pins, ["Q", "P"]);
});


test("the settle key and a drag to Settled take a pinned agent too; Undo restores its pin and its snooze", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); f.pins = ["A"]; a.focused = true; f.render();
  f.settle(); f.flush();
  assert.deepEqual([f.pins, f.calls.at(-1)[1].terminal], [[], "B"], "and the view moves on");
  f.label("A", "settled", "1000:0"); a.focused = false; f.render(1100);
  find(f.tree, "undo-notice-undo").handlers.on_click({}, f.cx); f.flush();
  f.label("A", "settled", ""); f.render(1200);
  assert.deepEqual(f.pins, ["A"]);
  // Snoozed under its pin, dragged to Settled: no "Unpinned" notice in the way, and Undo gives back both.
  f.label("A", "snoozed", "3600000"); f.render(1300); f.labelled.length = 0;
  assert.deepEqual([f.pins, f.napping()], [["A"], []], "folded");
  f.mod.napOpen = true; f.mod.open = true; f.mod.listH = 600; f.render(1300);
  f.mod.drag = { from: "A", moved: true, y: 400, grab: 10, height: 30, target: { section: "settled" } }; f.render(1300);
  f.event("t3-inbox-root", "on_mouse_up:left"); f.flush();
  assert.deepEqual(f.pins, []);
  assert.equal(f.mod.notice.action, "Settled");
  f.label("A", "settled", "1300:0"); f.label("A", "snoozed", ""); f.mod.dropped = 0; f.render(1400);
  f.labelled.length = 0;
  find(f.tree, "undo-notice-undo").handlers.on_click({}, f.cx); f.flush();
  assert.deepEqual([f.pins, f.labelled], [["A"], ["label A settled=", "label A snoozed=3600000"]]);
  f.label("A", "settled", ""); f.label("A", "snoozed", "3600000"); f.labelled.length = 0; f.render(1500); f.flush();
  assert.deepEqual([f.labelled, f.napping()], [[], ["A"]], "a pin coming back doesn't wake it");
});

test("a sweep from a pinned card's Settle stays among the pins", () => {
  const f = fixture(); f.add("P", "idle", 300); f.add("Q", "idle", 200); f.add("A", "idle", 100); f.pins = ["P", "Q"];
  f.render(); f.mod.hovered = "P"; f.render();
  f.event("settle-P", "on_mouse_down:left");
  f.event("t3-inbox-root", "on_mouse_move", { position: { x: 20, y: 300 } }); f.render();
  f.event("card-A", "on_mouse_move"); f.event("card-Q", "on_mouse_move"); f.render();
  f.event("t3-inbox-root", "on_mouse_up:left"); f.flush();
  assert.deepEqual(f.pins, []);
  assert.deepEqual(f.labelled.map((l) => l.split("=")[0]), ["label P settled", "label Q settled"]);
});

test("the snooze menu lights nothing until the pointer or a key gets there, and a pick needs a lit row", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render(); f.mod.hovered = "A"; f.render();
  f.event("snooze-menu-A", "on_open_change", true); f.render();
  const lit = () => find(f.tree, "snooze-panel-A").items.filter((r) => r.key).findIndex((r) => r.style.bg);
  const rows = find(f.tree, "snooze-panel-A").items.filter((r) => r.key).length;
  assert.equal(lit(), -1);
  f.event("snooze-panel-A", "on_action:t3_inbox_snooze_pick"); f.flush();
  assert.deepEqual([f.labelled, f.mod.napMenu], [[], "A"], "Enter on nothing does nothing");
  f.event("snooze-panel-A", "on_key_down", { key: "up" }); f.render();
  assert.equal(lit(), rows - 1, "up from nothing is the last row");
  f.event("snooze-panel-A", "on_key_down", { key: "down" }); f.render();
  assert.equal(lit(), 0, "and it wraps");
  find(f.tree, "snooze-1-A").handlers.on_hover(true, f.cx); f.render();
  assert.equal(lit(), 1);
  find(f.tree, "snooze-1-A").handlers.on_hover(false, f.cx); f.render();
  assert.equal(lit(), -1, "the pointer leaving takes the light with it");
});

test("Custom… opens the dialog; its answer snoozes as a preset does, with its Undo, unless the agent came to need the person", () => {
  const f = fixture(), a = f.add("A", "idle", 300); f.add("B", "idle", 200); f.render(); f.mod.hovered = "A"; f.mod.napMenu = "A"; f.render();
  const panel = find(f.tree, "snooze-panel-A").items, i = panel.filter((r) => r.key).findIndex((r) => texts(r).includes("Custom…"));
  assert.equal(panel.filter((r) => r.key).length - 1, i, "last, under a separator");
  const opened = []; f.context.openOverlay = (o) => opened.push(o);
  f.event(`snooze-${i}-A`, "on_click"); f.flush();
  assert.deepEqual([opened[0].mod, opened[0].kind, opened[0].props.customSnooze], ["t3-inbox", "dialog", "A"]);
  assert.deepEqual([f.mod.napMenu, f.labelled], [null, []]);
  f.mod.customSnooze("A:9000000", f.cx); f.flush();
  assert.deepEqual(f.labelled, ["label A snoozed=9000000"]);
  assert.equal(f.mod.notice.action, "Snoozed");
  f.labelled.length = 0; f.mod.pending.snoozed = {}; a.status = "blocked"; f.render(2000);
  f.mod.customSnooze("A:9000000", f.cx); f.flush();
  assert.deepEqual(f.labelled, []);
  // A machine's address has its own separators.
  f.add("m.1/a:b", "idle", 100); f.render(2100);
  f.mod.customSnooze("m.1/a:b:9000000", f.cx); f.flush();
  assert.deepEqual(f.labelled, ["label m.1/a:b snoozed=9000000"]);
});

test("the custom time follows T3's rules: a real local time in the future, or a positive duration", () => {
  const f = fixture(), wake = f.context.customWake, now = new Date(2026, 10, 3, 10, 0).getTime(), day = new Date(2026, 10, 3);
  const at = (time, date = day) => wake({ mode: "date", date, time }, now);
  assert.equal(at("11:30"), new Date(2026, 10, 3, 11, 30).getTime());
  assert.equal(at("9:30", new Date(2026, 10, 4)), new Date(2026, 10, 4, 9, 30).getTime(), "9:30 needs no leading zero");
  for (const bad of ["09:59", "10:00", "25:00", "11:60", "11", "soon", ""]) assert.equal(at(bad), null, bad);
  const lasting = (amount, unit) => wake({ mode: "duration", amount, unit }, now);
  assert.equal(lasting("2", "hours"), now + 7200000);
  assert.equal(lasting("90", "minutes"), now + 5400000);
  assert.equal(lasting("1.5", "days"), now + 129600000);
  for (const bad of ["0", "-1", "", "abc", "1e300"]) assert.equal(lasting(bad, "days"), null, bad);
});

test("the Custom dialog says what's wrong, stays open, and on a good answer hands it to the inbox", () => {
  const f = fixture(), closed = []; f.context.closeOverlay = (id) => closed.push(id);
  f.context.props = () => ({ customSnooze: "A", overlay: "o1" });
  const d = new f.context.Mod(); d.init({}, f.cx);
  let tree = d.render(f.cx);
  const fire = (id, name = "on_click") => { find(tree, id).handlers[name]({}, f.cx); tree = d.render(f.cx); };
  d.time.set_value("nope"); fire("custom-submit");
  assert.ok(texts(find(tree, "custom-error")).includes("Choose a valid date and time in the future."));
  assert.deepEqual(closed, []);
  fire("mode-duration");
  assert.equal(find(tree, "custom-error"), null, "changing course clears it");
  d.amount.set_value("0"); fire("custom-submit");
  assert.ok(texts(find(tree, "custom-error")).includes("Enter a positive duration."));
  // T3's number field and unit Select: steppers either side, stopping at 0; the units in a list under the trigger.
  assert.equal(d.amount.min, 0);
  assert.ok(find(tree, "custom-unit-button") && !find(tree, "unit-minutes"), "the list is shut");
  assert.ok(texts(find(tree, "custom-unit-button")).includes("Hours"));
  const lit = () => ["minutes", "hours", "days"].filter((u) => "aria_active_descendant" in find(tree, `unit-${u}`).style);
  const key = (k) => { find(tree, "custom-unit-list").handlers.on_key_down({ key: k }, f.cx); tree = d.render(f.cx); };
  fire("custom-unit-button");
  assert.deepEqual(lit(), ["hours"], "it opens on the chosen one");
  key("down"); assert.deepEqual([lit(), d.unit], [["days"], "hours"], "keys move the highlight, not the choice");
  key("down"); assert.deepEqual(lit(), ["minutes"], "round the ends");
  key("up"); assert.deepEqual(lit(), ["days"]);
  key("enter"); assert.deepEqual([d.unit, d.unitOpen], ["days", false], "Enter picks and closes");
  fire("custom-unit-button"); d.overUnit = true;
  find(tree, "custom-unit-list").handlers.on_mouse_down_out({}, f.cx);
  assert.equal(d.unitOpen, true, "a press on the trigger is the trigger's to toggle");
  d.overUnit = false; find(tree, "custom-unit-list").handlers.on_mouse_down_out({}, f.cx);
  assert.equal(d.unitOpen, false, "a press elsewhere closes it");
  tree = d.render(f.cx); fire("custom-unit-button");
  d.amount.set_value("30"); fire("unit-minutes");
  assert.deepEqual([d.unit, d.unitOpen, texts(find(tree, "custom-unit-button")).includes("Minutes")], ["minutes", false, true], "a click picks and closes");
  fire("custom-submit");
  assert.deepEqual(closed, ["o1"]);
  assert.equal(f.calls.at(-1)[0], `t3-inbox.custom-snooze:A:${f.now + 1800000}`);
});

test("the Custom dialog's calendar lets days gone by be seen but not picked, and turns the month", () => {
  const f = fixture(); f.now = new Date(2026, 10, 15, 10, 0).getTime();
  f.context.props = () => ({ customSnooze: "A", overlay: "o1" });
  const d = new f.context.Mod(); d.init({}, f.cx); d.calendarOpen = true;
  let tree = d.render(f.cx);
  assert.equal(find(tree, "day-2026-11-14").handlers.on_click, undefined);
  assert.ok(find(tree, "day-2026-11-15").handlers.on_click, "today can");
  assert.ok(texts(find(tree, "custom-calendar")).includes("November 2026"));
  find(tree, "day-2026-11-20").handlers.on_click({}, f.cx);
  assert.deepEqual([d.date.getDate(), d.calendarOpen], [20, false]);
  d.calendarOpen = true; tree = d.render(f.cx);
  find(tree, "month-on").handlers.on_click({}, f.cx); tree = d.render(f.cx);
  assert.ok(texts(find(tree, "custom-calendar")).includes("December 2026"));
  find(tree, "day-2026-12-25").handlers.on_click({}, f.cx);
  d.time.set_value("09:00"); tree = d.render(f.cx); find(tree, "custom-submit").handlers.on_click({}, f.cx);
  assert.ok(f.calls.at(-1)[0].endsWith(`:${new Date(2026, 11, 25, 9, 0).getTime()}`));
});

test("a far-off snooze wakes on time: its timer is re-armed a day at a time", () => {
  const f = fixture(); f.add("A", "idle", 100); f.label("A", "snoozed", String(1000 + 3 * 86400000)); f.render();
  const armed = () => f.timers.filter((t) => !t.cancelled).map((t) => t.at - f.now);
  assert.ok(armed().includes(86400000));
  assert.ok(!armed().some((ms) => ms > 86400000));
  assert.equal(f.mod.nextWake, 1000 + 3 * 86400000);
});

test("a hover label waits, fades in once laid out, fades out before it goes, and comes back from the fade", () => {
  const f = fixture(); f.add("A", "idle", 100);
  const walk = (n) => (n && typeof n === "object" ? [n, ...n.items.flatMap(walk)] : []);
  const body = () => walk(f.mod.render(f.cx)).find((n) => n.key?.startsWith("tip-body-inbox-scope-"));
  const over = (on) => { f.mod.hot = on ? "inbox-scope" : null; find(f.mod.render(f.cx), "tip-over-inbox-scope").handlers.on_hover(on, f.cx); };
  const pass = (ms) => f.render(f.now + ms);
  over(true);
  assert.equal(body(), undefined, "not before its delay");
  pass(150);
  const first = body();
  assert.deepEqual(first.style.opacity, [0], "drawn clear first: a transition adopts the first value it sees");
  first.handlers.on_size_change({ width: 40, height: 20 }, f.cx);
  assert.deepEqual([body().style.opacity, body().style.top], [[1], [0]]);
  over(false);
  assert.deepEqual([body().style.opacity, body().style.top], [[0], [-4]], "still up, fading back toward its control");
  over(true);
  assert.equal(body().key, first.key, "back before it went: the same one fades back");
  assert.deepEqual(body().style.opacity, [1]);
  pass(150);
  assert.deepEqual(body().style.opacity, [1], "its going was called off");
  over(false); pass(150);
  assert.equal(body(), undefined, "gone: a clear label would still block what it covers");
  over(true); pass(150);
  assert.notEqual(body().key, first.key, "reopened, a new id: a size reports only an id's first layout");
  over(false); pass(150);
  over(true); f.mod.hot = null; pass(150);
  assert.equal(body(), undefined, "unlit with no leaving reported: a dialog covers it, and no clear label stays over the dialog");
});

test("a row's card fades when a control in the row is lit and when another row's opens at once", () => {
  const f = fixture(); f.add("A", "idle", 100); f.add("B", "idle", 200); f.render();
  const card = (x) => find(f.tree, `details-card-${x}`);
  f.event("card-A", "on_hover", true); f.render(f.now + 150); f.render(f.now + 34);
  assert.deepEqual([card("A").style.opacity, card("A").style.left], [[1], [0]]);
  find(f.tree, "snooze-A").handlers.on_hover(true, f.cx); f.render();
  assert.deepEqual([card("A").style.opacity, card("A").style.left], [[0], [-4]], "up, clear");
  find(f.tree, "snooze-A").handlers.on_hover(false, f.cx); f.render();
  assert.deepEqual(card("A").style.opacity, [1], "back as the pointer comes off the control");
  find(f.tree, "corner-A").handlers.on_hover(true, f.cx); f.render();
  find(f.tree, "settle-A").handlers.on_hover(true, f.cx); f.render();
  find(f.tree, "settle-A").handlers.on_hover(false, f.cx); f.render();
  assert.deepEqual(card("A").style.opacity, [0], "in the gap between two controls, however long: no flash");
  find(f.tree, "snooze-A").handlers.on_hover(true, f.cx); f.render();
  assert.deepEqual(card("A").style.opacity, [0]);
  find(f.tree, "snooze-A").handlers.on_hover(false, f.cx); f.render();
  find(f.tree, "corner-A").handlers.on_hover(false, f.cx); f.render();
  assert.deepEqual(card("A").style.opacity, [1], "off the corner, still on the row: it shows");
  find(f.tree, "corner-A").handlers.on_hover(true, f.cx); f.render();
  find(f.tree, "card-A").handlers.on_hover(false, f.cx); f.render();
  find(f.tree, "card-A").handlers.on_hover(true, f.cx); f.render();
  assert.deepEqual(card("A").style.opacity, [1], "a corner's leave that never came doesn't hold it");
  f.event("card-A", "on_hover", false); f.event("card-B", "on_hover", true); f.render();
  assert.deepEqual(card("B").style.opacity, [1], "at once");
  assert.deepEqual(card("A").style.opacity, [0], "fading under it");
  f.render(f.now + 150);
  assert.equal(card("A"), null);
  assert.deepEqual(card("B").style.opacity, [1]);
});

// Herdr drops a leave while the pointer's last known place is in the element's last box, and no other comes: these never get an on_hover(false).
test("a row's card goes when its leave never comes: the pointer's elsewhere, or out past the window's edge, active or not", () => {
  const box = { x: 10, y: 100, width: 200, height: 36 };
  const pastEdge = (f) => {
    // Stopped at the edge, heading out: macOS reports no more.
    for (const x of [30, 12]) { f.pointer = { x, y: 110 }; f.event("card-A", "on_mouse_move", { position: f.pointer, local_position: f.pointer, bounds: { ...box, x: 0 } }); }
  };
  for (const [active, away] of [[true, (f) => { f.pointer = { x: 20, y: 300 }; }], [false, (f) => { f.pointer = { x: 20, y: 300 }; }], [false, pastEdge]]) {
    const f = fixture(); f.add("A", "idle", 100); f.render();
    f.active = active;
    const polling = () => f.watches.filter((w) => !w.cancelled).length, before = polling();
    const card = () => find(f.tree, "details-card-A");
    f.event("card-A", "on_hover", true); f.render(f.now + 150); f.render(f.now + 34);
    f.pointer = { x: 20, y: 110 };
    f.event("card-A", "on_mouse_move", { position: f.pointer, local_position: { x: 10, y: 10 }, bounds: box });
    f.tick(); f.render();
    assert.deepEqual(card().style.opacity, [1], "the pointer's on it: it stays");
    away(f);
    f.mod.hot = "snooze-A"; // Stranded with it.
    f.tick(); f.render();
    assert.equal(f.mod.hovered, null);
    assert.equal(f.mod.hot, null);
    assert.deepEqual(card().style.opacity, [0], "it fades");
    f.render(f.now + 150);
    assert.equal(card(), null);
    assert.equal(polling(), before, "nothing left polling");
  }
});

test("a drag or sweep ends when its leave never comes, by the same rule as a leave", () => {
  const box = { x: 0, y: 0, width: 300, height: 800 };
  const lift = (f, x, y) => {
    f.event("t3-inbox-root", "on_size_change", { width: 300, height: 800 });
    f.event("slim-A", "on_mouse_down:left");
    f.pointer = { x, y };
    f.event("t3-inbox-root", "on_mouse_move", { position: f.pointer, local_position: f.pointer, bounds: box });
  };
  const build = () => { const f = fixture(); f.add("A", "idle", 300); f.add("B", "idle", 200); f.label("A", "settled", "500:0"); f.mod.open = true; f.mod.listH = 600; f.render(); return f; };
  // Past the right edge from near it: back where it was, the keyboard back with it.
  const f = build(), polling = () => f.watches.filter((w) => !w.cancelled).length, before = polling();
  f.context.focused = () => ({ pane: "pm", terminal: "A" });
  lift(f, 280, 400); f.mod.drag.target = { section: "active" }; f.render();
  assert.equal(polling(), before + 1);
  f.tick(); assert.ok(f.mod.drag, "the pointer's in the sidebar: nothing yet");
  f.pointer = { x: 900, y: 400 }; f.tick(); f.flush();
  assert.deepEqual([f.mod.drag, f.labelled, plain(f.calls.at(-1))], [null, [], ["pane.focus", { pane: "pm" }]]);
  f.tick(); assert.equal(polling(), before, "nothing left polling");
  // Off the bottom edge: it lands where its badge says.
  const g = build(); lift(g, 150, 790); g.mod.drag.target = { section: "active" }; g.render();
  g.pointer = { x: 150, y: 900 }; g.tick(); g.flush();
  assert.deepEqual([g.mod.drag, g.labelled], [null, ["label A settled="]]);
  // The window going inactive with the release out of its sight ends it too.
  const h = build(); lift(h, 280, 400); h.render(); h.active = false; h.tick();
  assert.equal(h.mod.drag, null);
  // The pointer stopped on the sidebar's edge heading out of the window, which reports no more: gone too.
  const k = build(); lift(k, 280, 400); k.render();
  for (const y of [640, 700, 701]) { k.pointer = { x: 280, y }; k.event("t3-inbox-root", "on_mouse_move", { position: k.pointer, local_position: k.pointer, bounds: box }); }
  k.tick(); assert.ok(k.mod.drag, "a slow last step isn't heading out");
  // One move reaches a row and then the root, and must count once for that step to show.
  for (const y of [760, 795]) { k.pointer = { x: 280, y }; for (const id of ["slim-A", "t3-inbox-root"]) k.event(id, "on_mouse_move", { position: k.pointer, local_position: k.pointer, bounds: box }); }
  k.tick(); assert.equal(k.mod.drag, null);
  // A sweep off a side: nothing it marked happens.
  const m = build(); m.mod.hovered = "A"; m.render();
  m.event("unsettle-A", "on_mouse_down:left"); m.pointer = { x: 280, y: 400 };
  m.event("t3-inbox-root", "on_size_change", { width: 300, height: 800 });
  m.event("t3-inbox-root", "on_mouse_move", { position: m.pointer, local_position: m.pointer, bounds: box }); m.render();
  m.pointer = { x: 900, y: 400 }; m.tick(); m.flush();
  assert.deepEqual([m.mod.sweep, m.labelled], [null, []]);
});


test("a row's card goes when the pointer heads out of the window from it, and stays when it stops on the row", () => {
  const box = { x: 0, y: 100, width: 200, height: 36 };
  const f = fixture(); f.add("A", "idle", 100); f.render();
  const card = () => find(f.tree, "details-card-A");
  const move = (x, y) => { f.pointer = { x, y }; f.event("card-A", "on_mouse_move", { position: f.pointer, local_position: { x, y: y - 100 }, bounds: box }); };
  f.event("card-A", "on_hover", true); f.render(f.now + 150); f.render(f.now + 34);
  move(40, 110); move(20, 110); move(18, 110);
  f.tick(); f.render();
  assert.deepEqual(card().style.opacity, [1], "slowing to a stop on the row, it stays");
  move(4, 110);
  f.tick(); f.render();
  assert.deepEqual(card().style.opacity, [0], "its last step was on its way past the window's left edge: macOS says no more, and it fades");
});

test("a card with no box yet stays while the pointer holds still; moving, with no move reported on the row, it has left", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render();
  f.pointer = { x: 40, y: 120 };
  f.event("card-A", "on_hover", true); f.render(f.now + 150); f.render(f.now + 34);
  f.tick(); f.render();
  assert.deepEqual(find(f.tree, "details-card-A").style.opacity, [1], "it slid under a still pointer");
  f.pointer = { x: 900, y: 900 };
  f.tick(); f.render();
  assert.deepEqual(find(f.tree, "details-card-A").style.opacity, [0]);
});

test("a hover label goes when its leave never comes, and its control stops being lit", () => {
  const f = fixture(); f.add("A", "idle", 100);
  const polling = () => f.watches.filter((w) => !w.cancelled).length, before = polling();
  const walk = (n) => (n && typeof n === "object" ? [n, ...n.items.flatMap(walk)] : []);
  const body = () => walk(f.mod.render(f.cx)).find((n) => n.key?.startsWith("tip-body-inbox-scope-"));
  f.mod.hot = "inbox-scope";
  const over = () => find(f.mod.render(f.cx), "tip-over-inbox-scope");
  over().handlers.on_hover(true, f.cx);
  f.render(f.now + 150);
  f.pointer = { x: 20, y: 10 };
  over().handlers.on_mouse_move({ bounds: { x: 0, y: 0, width: 40, height: 20 } });
  f.tick();
  assert.equal(f.mod.hot, "inbox-scope", "the pointer's on it");
  assert.ok(body());
  f.pointer = { x: 20, y: 300 };
  f.tick();
  assert.equal(f.mod.hot, null);
  assert.deepEqual(body().style.opacity, [0], "it fades");
  f.render(f.now + 150);
  assert.equal(body(), undefined);
  assert.equal(polling(), before, "nothing left polling");
});

test("hovering works in a window that isn't active, as T3's: it doesn't flash and go", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render();
  f.active = false;
  f.event("card-A", "on_hover", true);
  f.tick(); f.render();
  assert.equal(f.mod.hovered, "A", "the pointer hasn't moved: the row stays hovered");
  assert.ok(find(f.tree, "settle-A"), "its controls are there");
  f.render(f.now + 150); f.render(f.now + 34); f.tick(); f.render();
  assert.equal(f.mod.hovered, "A");
  assert.ok(find(f.tree, "details-card-A"), "and its card opens");
  f.mod.hot = "inbox-scope";
  find(f.mod.render(f.cx), "tip-over-inbox-scope").handlers.on_hover(true, f.cx);
  f.render(f.now + 150); f.tick();
  assert.equal(f.mod.hot, "inbox-scope");
  const walk = (n) => n && typeof n === "object" ? [n, ...(n.items ?? []).flatMap(walk)] : [];
  assert.ok(walk(f.mod.render(f.cx)).find((n) => n.key?.startsWith("tip-body-inbox-scope-")), "and a label");
});

test("the window going inactive under a still pointer leaves its hover as it is", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render();
  f.event("card-A", "on_hover", true); f.render(f.now + 150); f.render(f.now + 34);
  f.active = false;
  f.tick(); f.render();
  assert.equal(f.mod.hovered, "A");
  assert.ok(find(f.tree, "details-card-A"));
});

test("past 40 rows coming and going at once, they just show", () => {
  const f = fixture(); f.add("A", "idle", 100); f.render();
  for (let i = 0; i < 41; i++) f.add(`N${i}`, "idle", 200 + i);
  f.render();
  assert.equal(Object.keys(f.mod.motion.fly).length, 0);
});

test("a card and a settled row measure as T3's, and the lists stack as its does", () => {
  const f = fixture(); f.add("A", "idle", 100); f.add("B", "idle", 200); f.terms[1].labels.settled = "500:0"; f.mod.open = true; f.render();
  const num = (n, k) => n.style[k]?.[0], card = find(f.tree, "card-A");
  assert.deepEqual(["px", "py", "rounded"].map((k) => num(card, k)), [10, 8, 6]);
  assert.deepEqual([num(card.items[0], "h"), num(card.items[1], "h"), num(card.items[1], "mt")], [20, 20, 4], "its lines, 4 apart");
  const slim = find(f.tree, "slim-B");
  assert.deepEqual(["h", "px", "gap", "rounded"].map((k) => num(slim, k)), [36, 10, 10, 6]);
  assert.deepEqual(["h", "min_w"].map((k) => num(find(slim, "slim-corner-B"), k)), [24, 32], "T3's corner");
  assert.equal(num(find(f.tree, "settled"), "gap"), 1, "gap-px between a shelf's rows");
  assert.deepEqual(["h", "px", "gap"].map((k) => num(find(f.tree, "inbox-top"), k)), [48, 8, 4], "T3's top group");
});
