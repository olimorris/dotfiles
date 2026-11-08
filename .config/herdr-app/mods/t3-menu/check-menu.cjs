// Loads the menu in a fake `herdr`: a tab's and a pane's Close go through the tab bar; the rest is Herdr's own.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const el = () => new Proxy({}, { get: (o, k) => (k === "when" ? (c, f) => (c ? f(p) : p) : () => p) }), p = el();
let target = {}, calls = [];
const context = vm.createContext({
  View: class {}, div: el, svg: el, v_flex: el, h_flex: el,
  run: (name, args) => calls.push(args === undefined ? [name] : [name, args]), props: () => target, closeOverlay() {}, openOverlay() {},
  theme: () => ({}), keys: () => [], terminals: () => [{ address: "t1", labels: {} }], spaces: () => [], panes: () => [], exec: async () => ({ code: 1 }),
});
const src = fs.readFileSync(path.join(__dirname, "main.js"), "utf8").replace(/^import .*;\r?\n/gm, "").replace("export default class", "globalThis.Menu = class");
vm.runInContext(src, context);
const menu = new context.Menu();
const choose = (props, label) => {
  target = props; calls = [];
  const i = vm.runInContext("items", context)(props, null).findIndex((it) => it[0] === label);
  menu.choose(i, {});
  return JSON.parse(JSON.stringify(calls));
};

assert.deepEqual(choose({ tab: "tab", target: { id: "b1", space: "s1" } }, "Close"), [["t3-tabs.close-tab:b1"]], "a tab's Close asks and leaves first");
assert.deepEqual(choose({ tab: "pane", target: { pane: "p1", terminal: "t1" } }, "Close pane"), [["t3-tabs.close-pane:p1"]], "so does a pane's");
assert.deepEqual(choose({ tab: "tab", target: { id: "b1", space: "s1" } }, "Rename"), [["tab.rename", { id: "b1" }]], "the rest is Herdr's");
assert.deepEqual(choose({ tab: "space", target: { id: "s1" } }, "Close"), [["space.close", { id: "s1" }]], "a space's Close is Herdr's, which asks itself");
console.log("ok menu");
