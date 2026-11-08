// Loads Go to in a fake `herdr`: a row a pane, found by its name and program, not an unnamed tab's; Back goes back.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

function element() {
  const node = { items: [], handlers: {} };
  const proxy = new Proxy(node, { get(target, key) {
    if (key in target) return target[key];
    return (...args) => {
      if (key === "when") { if (args[0]) args[1](proxy); }
      else if (key === "child") node.items.push(args[0]);
      else if (key === "children") node.items.push(...args[0]);
      else if (key === "on_key_down") node.handlers.key = args[0];
      else if (key === "on_click") node.handlers.click = args[0];
      else if (key === "id") node.key = args[0];
      else if (key === "opacity") node.opacity = args[0];
      else if (key === "bg") node.fill = args[0];
      return proxy;
    };
  } });
  return proxy;
}
const find = (node, id) => {
  if (!node || typeof node !== "object") return null;
  if (node.key === id) return node;
  for (const child of node.items) { const found = find(child, id); if (found) return found; }
  return null;
};

const pi = { name: "Pi", key: "pi", agent: true }, git = { name: "Git Changes", key: "lazygit", agent: false };
const zsh = { name: "zsh", key: "shell", shell: true }, vite = { name: "Vite", key: "vite", agent: false };
// The current space comes first wherever it is in the list.
const spaces = [
  { id: "s2", name: "api", machine: null, active: false, tabs: [{ id: "c2", name: "herdr worktree", named: false, active: true }] },
  { id: "s1", name: "web", machine: null, active: true, tabs: [{ id: "c1", name: "Fix login", named: true, active: true }] },
];
const panes = [
  { pane: "p4", tab: "c2", terminal: "t4", program: vite, focused: true },
  { pane: "p1", tab: "c1", terminal: "t1", program: pi, status: "working", focused: true },
  { pane: "p2", tab: "c1", terminal: "t2", program: git, focused: false },
  { pane: "p3", tab: "c1", terminal: "t3", program: zsh, focused: false },
];
const shared = {}, calls = [];
let terms = [];
const cx = { notify() {}, stop_propagation() {} };
const context = vm.createContext({
  View: class {}, div: element, svg: element, image: element, h_flex: element, v_flex: element, Input: { new: element },
  InputState: { new: () => { const on = {}; let value = ""; return { on: (e, f) => { on[e] = f; }, value: () => value, focus() {}, type(v) { value = v; on.change({}, cx); }, submit() { on.submit(); } }; } },
  settings: () => ({ zoom: 1 }),
  spaces: () => spaces, panes: () => panes, agents: () => [], terminals: () => terms, window: () => ({ platform: "macos" }),
  focused: () => ({ pane: panes.find((p) => p.focused && spaces.find((s) => s.active).tabs.some((c) => c.id === p.tab)).pane }),
  run: (name, args) => calls.push([name, args]), theme: () => ({ done: "#done" }), props: () => ({ overlay: "o" }), closeOverlay() {},
  shared: (k) => shared[k], setShared: (k, v) => { shared[k] = v; },
  namer: () => (p) => p.program.name, programOf: (p) => p.program, modStatus: () => null, projectMark: element,
});
const src = ["tree.js", "list.js", "zoom.js", "main.js"].map((f) => fs.readFileSync(path.join(__dirname, f), "utf8")).join("\n").replace(/^import .*;\r?\n/gm, "").replace(/^export (function|const) /gm, "$1 ").replace("export default class", "globalThis.Mod = class");
vm.runInContext(src, context);
const open = () => { const m = new context.Mod(); m.init({}, cx); return m; };
const keys = (m) => find(m.render(), "picker-rows")?.items.map((n) => n.key) ?? [];
const take = () => JSON.parse(JSON.stringify(calls.splice(0)));
const focus = (id) => panes.forEach((p) => { if (p.tab === "c1") p.focused = p.pane === id; });

// Every pane has a row, the current space's first. Opens on where you are, and Enter there stays put.
let m = open();
assert.deepEqual(keys(m), ["pane:p1", "pane:p2", "pane:p3", "pane:p4"]);
m.input.submit();
assert.deepEqual(take(), [["pane.focus", { pane: "p1" }]]);
assert.equal(shared["t3-picker.back"], undefined, "staying put isn't a jump");

// Typing its program picks its row; Enter goes to its pane and keeps where it left.
m = open(); m.input.type("lazygit"); m.render(); m.input.submit();
assert.deepEqual(take(), [["pane.focus", { pane: "p2" }]]);
assert.equal(shared["t3-picker.back"], "p1");

// Opened again from lazygit, Back leads and Enter goes back; then Back points at lazygit.
focus("p2");
m = open();
assert.equal(keys(m)[0], "back:p1");
m.input.submit();
assert.deepEqual(take(), [["pane.focus", { pane: "p1" }]]);
assert.equal(shared["t3-picker.back"], "p2");

// Another space's program by its program; an unnamed tab's name finds nothing; a named tab's finds its panes.
focus("p1");
m = open(); m.input.type("vite"); m.render(); m.input.submit();
assert.deepEqual(take(), [["pane.focus", { pane: "p4" }]]);
m = open(); m.input.type("worktree");
assert.deepEqual(keys(m), []);
m = open(); m.input.type("fix login");
assert.deepEqual(keys(m), ["pane:p1", "pane:p2", "pane:p3"]);

// A click goes to its row's pane.
m = open(); find(m.render(), "pane:p3").handlers.click({}, cx);
assert.deepEqual(take(), [["pane.focus", { pane: "p3" }]]);

// ctrl+d closes the pane through the tab bar, which asks first.
m = open(); m.input.type("lazygit"); m.render().handlers.key({ key: "d", modifiers: { control: true } }, cx);
assert.deepEqual(take(), [["t3-tabs.close-pane:p2", null]]);

// Back across tabs: `focused` is each tab's own, so a pane another tab holds focus in is still somewhere to go back to.
shared["t3-picker.back"] = "p4";
assert.equal(keys(open())[0], "back:p4");
shared["t3-picker.back"] = "p1";
assert.ok(!keys(open()).some((k) => k.startsWith("back:")), "the pane you're in is no way back");

// Back to a pane that's gone shows nothing.
shared["t3-picker.back"] = "p9";
assert.ok(!keys(open()).some((k) => k.startsWith("back:")));

// Home's default page has no row; a program arranged beside it has one.
panes.push({ pane: "ph", tab: "c1", mod: "t3-home", title: "Home", program: {}, focused: false }, { pane: "pb", tab: "c1", terminal: "t5", program: vite, focused: false });
{ const rows = keys(open()); assert.ok(!rows.includes("pane:ph")); assert.ok(rows.includes("pane:pb")); }
panes.splice(-2);
// Its contents are there from the first frame: a fade leaves the popup blank.
assert.notEqual(typeof open().render().opacity, "number");
// Closing says so, for the buttons that open it to toggle.
{ const before = Date.now(); open().close(); assert.ok(shared["t3-picker.closed"] >= before); }

// Status follows the shared attention rule in either mode: quiet labels hide done, new work or waking brings it back.
panes[1].status = "done";
terms = [{ address: "t1", turn: 1, labels: {} }];
const hasDone = n => Boolean(n && typeof n === "object" && (n.fill === "#done" || n.items.some(hasDone)));
const done = () => hasDone(find(open().render(), "pane:p1"));
assert.ok(done());
terms[0].labels.settled = "1:1"; assert.equal(done(), false);
terms[0].turn = 2; assert.ok(done());
terms[0].labels = { snoozed: String(Date.now() + 60000) }; assert.equal(done(), false);
terms[0].labels.snoozed = String(Date.now() - 1); assert.ok(done());
console.log("ok picker");
