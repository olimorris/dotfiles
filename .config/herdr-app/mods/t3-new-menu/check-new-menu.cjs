// Loads the menu in a fake `herdr`: the order, the keys' scrolling, and where a new space goes.
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
      else if (key === "on_click") node.handlers.click = args[0];
      else if (key === "on_hover") node.handlers.hover = args[0];
      else if (key === "on_key_down") node.handlers.key = args[0];
      else if (key === "id") node.key = args[0];
      else if (key === "opacity") node.opacity = args[0];
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
const text = (n) => typeof n === "string" ? n : n?.items ? n.items.map(text).join(" ") : "";

let spaces, machines;
let openProps = {};
const calls = [], state = {};
const cx = { notify() {}, stop_propagation() {} };
const context = vm.createContext({
  View: class {}, div: element, svg: element, h_flex: element, v_flex: element, Input: { new: element },
  InputState: { new: () => { const on = {}; let value = ""; return { on: (e, f) => { on[e] = f; }, value: () => value, focus() {}, set_value(v) { value = v; }, type(v) { value = v; on.change({}, cx); } }; } },
  settings: () => ({ zoom: 1 }),
  theme: () => ({ foreground: "#fff" }), spaces: () => spaces, machines: () => machines, panes: () => [], run: (name, args) => calls.push([name, args]),
  shared: (k) => state[k], setShared: (k, v) => { state[k] = v; }, closeOverlay() {}, props: () => ({ overlay: "o", ...openProps }), window: () => ({ platform: "macos" }), keys: () => [{ section: "global", keys: "cmd-n", action: "space.new" }], home: () => "/home/me", projectMark: element, placeOf: (s) => s.folder,
});
const src = ["list.js", "main.js"].map((f) => fs.readFileSync(path.join(__dirname, f), "utf8")).join("\n").replace(/^import .*;\r?\n/gm, "").replace(/^export (function|const) /gm, "$1 ").replace("export default class", "globalThis.Mod = class");
vm.runInContext(src, context);
const open = () => { const m = new context.Mod(); m.init({}, cx); return m; };
const list = (m) => find(m.render(), "new-rows");
const keysOf = (m) => list(m).items.map((n) => n.key);
const click = (m, id) => find(list(m), id).handlers.click({}, cx);
const press = (m, key, platform = false) => m.render().handlers.key({ key, modifiers: { platform } }, cx);
const take = () => JSON.parse(JSON.stringify(calls.splice(0)));

const local = (id, active = false) => ({ id, name: id, folder: "/home/me/" + id, machine: null, active });
const remote = (id, active = false) => ({ id, name: id, folder: "", machine: "kvm", active });
machines = [{ name: null, layout: "ready" }, { name: "kvm", layout: "ready" }, { name: "away", layout: "unavailable" }];

// The current space leads, a machine's spaces stay together, ⌘n follows what's shown.
spaces = [remote("r1"), local("a"), remote("r2", true), local("b")];
let m = open();
assert.deepEqual(keysOf(m), ["space:r2", "space:r1", "space:a", "space:b"]);
press(m, "3", true);
assert.deepEqual(take(), [["tab.new", { space: "a" }]]);

// New work doesn't start in Home, shown or not.
state["t3-home.space"] = "a";
assert.deepEqual(keysOf(open()), ["space:r2", "space:r1", "space:b"]);
delete state["t3-home.space"];

// Up and down keep the highlighted row on screen, round the ends too; six rows show.
spaces = Array.from({ length: 9 }, (_, i) => local("s" + i, i === 0));
m = open();
press(m, "up");
assert.deepEqual([m.at, keysOf(m).at(-1)], [8, "space:s8"]);
press(m, "down");
assert.deepEqual([m.at, keysOf(m)[0]], [0, "space:s0"]);
for (let i = 0; i < 6; i++) press(m, "down");
assert.deepEqual([keysOf(m)[0], keysOf(m).at(-1)], ["space:s1", "space:s6"]);
// The pointer lights a row.
find(list(m), "space:s3").handlers.hover(true, cx);
assert.equal(m.at, 3);
spaces = [local("a", true), remote("r1"), local("b")];
m = open();
m.spaceInput.type("kvm");
assert.deepEqual(keysOf(m), ["space:r1"], "search finds a space by its machine");
assert.equal(m.at, 0);
m.spaceInput.type("nothing");
assert.equal(list(m), null);
press(m, "down"); // no rows: nothing to reach, nothing thrown
click(open(), "space:r1");
assert.deepEqual(take(), [["tab.new", { space: "r1" }]]);

// New space asks which machine; one that's away can't be picked.
m = open();
find(m.render(), "space-new").handlers.click({}, cx);
assert.deepEqual(take(), []);
assert.deepEqual(keysOf(m), ["machine:", "machine:away", "machine:kvm"]);
click(m, "machine:away");
assert.deepEqual(take(), []);
click(m, "machine:kvm");
assert.deepEqual(take(), [["space.new", { machine: "kvm" }]]);
m = open();
find(m.render(), "space-new").handlers.click({}, cx);
find(m.render(), "new-back").handlers.click({}, cx);
assert.deepEqual(keysOf(m), ["space:a", "space:b", "space:r1"], "Back returns to the spaces");
m = open();
find(m.render(), "space-new").handlers.click({}, cx);
click(m, "machine:");
assert.deepEqual(take(), [["space.new", { machine: "" }]], "This computer");

// The sidebar's New space opens on the machines; ⌘N, which doesn't ask, isn't offered as the same thing.
openProps = { pick: true };
m = open();
assert.deepEqual(keysOf(m), ["machine:", "machine:away", "machine:kvm"]);
click(m, "machine:kvm");
assert.deepEqual(take(), [["space.new", { machine: "kvm" }]]);
openProps = {};
assert.ok(!text(open().render()).includes("⌘N"), "no ⌘N beside a button that asks");

// On a remote space its machine is offered first; with one machine there is nothing to ask.
spaces = [local("a"), remote("r1", true)];
m = open();
find(m.render(), "space-new").handlers.click({}, cx);
assert.equal(keysOf(m)[0], "machine:kvm");
machines = [{ name: null, layout: "ready" }];
spaces = [local("a", true)];
m = open();
find(m.render(), "space-new").handlers.click({}, cx);
assert.deepEqual(take(), [["space.new", { machine: "" }]]);
assert.ok(text(open().render()).includes("⌘N"), "⌘N beside a button that does the same");

// Its contents are there from the first frame: a fade leaves the popup blank.
assert.notEqual(typeof open().render().opacity, "number");
// Closing says which step it was on, for the buttons that open each to toggle.
openProps = {}; open().close();
assert.ok(state["t3-new-menu.closed"] && !state["t3-new-menu.pickClosed"]);
openProps = { pick: true }; open().close();
assert.ok(state["t3-new-menu.pickClosed"]);
openProps = {};
console.log("ok new menu");
