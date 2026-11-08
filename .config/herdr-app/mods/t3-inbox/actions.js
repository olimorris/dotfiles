import { focused, run, shared, setShared, props, notify, openOverlay } from "herdr";
import { focusAgent, focusPane } from "./zoom.js";
import { detailsFor } from "./details.js";

export function inboxActions(view, model) {
  const { every, viewing, term, pins, napUntil, wake, state, settledAt, busy, pinned, out, busyRows, sp, ps, put } = model;
  // A row moving away from under the pointer reports no leave.
  const away = (a, cx) => {
    if (view.hovered !== a.address) return;
    view.hovered = null;
    detailsFor(view, null, cx);
  };
  // Undo puts back only the pins it took, where they were: pins made since stay.
  const repin = (before, took) => {
    const current = [...(shared("agents.pins") ?? [])];
    for (const p of before.filter((p) => took.includes(p) && !current.includes(p))) {
      const next = before.slice(before.indexOf(p) + 1).find((q) => current.includes(q));
      current.splice(next ? current.indexOf(next) : current.length, 0, p);
    }
    setShared("agents.pins", current);
  };
  // Brought back, it's news again: the top of the list.
  const unsettle = (a, cx) => {
    away(a, cx);
    view.setLabel("settled", a.address, "", cx);
    view.changed[a.address] = { ...view.changed[a.address], at: Date.now(), start: null };
    localStorage.setItem("changes", JSON.stringify(view.changed));
  };
  const go = (a) => a.mod ? focusPane(a.pane) : focusAgent(a.address);
  // Putting away the agent in view moves on to the next card down the list, from the top past the end, as T3 does;
  // one in the background moves nothing.
  const moveOn = (xs) => {
    const cards = [...pinned, ...out, ...busyRows], i = cards.findIndex(viewing);
    if (i < 0 || !xs.includes(cards[i])) return false;
    // With a Home in the layout, that's where it lands: what to look at next stays the person's to say.
    if (props()?.home) { if (cards[i].mod) return false; run(props().home); return true; }
    const next = [...cards.slice(i + 1), ...cards.slice(0, i)].find((a) => !xs.includes(a));
    if (next) go(next);
    return Boolean(next);
  };
  // Undoing what took an agent off the screen brings it back, while Home is still where that left the person.
  const bringBack = (a) => { if (a && props()?.home && focused()?.space === shared("t3-home.space")) go(a); };
  // Settling ends a snooze and a pin, as T3's. A mod pane closes, once the view has moved on from it.
  const settle = (xs, cx) => {
    const panes = xs.filter((a) => a.mod), kept = xs.filter((a) => !a.mod), seen = kept.find(viewing);
    for (const a of xs) away(a, cx);
    const naps = new Map(kept.map((a) => [a, napUntil(a)]));
    const before = [...pins], unpinned = pins.filter((p) => !kept.some((a) => a.address === p));
    if (unpinned.length < before.length) setShared("agents.pins", unpinned);
    for (const a of kept) {
      view.setLabel("settled", a.address, `${Date.now()}:${term.get(a.address)?.turn ?? 0}`, cx);
      if (naps.get(a)) wake(a, cx);
    }
    // Undone, they're back where they were: no news, as T3 restores a thread, with its pin and a snooze that hasn't
    // run out.
    if (kept.length) view.remember("Settled", kept.length, (cx) => {
      repin(before, kept.map((a) => a.address));
      for (const a of kept) {
        view.setLabel("settled", a.address, "", cx);
        if (naps.get(a) > Date.now()) view.setLabel("snoozed", a.address, String(naps.get(a)), cx);
      }
      bringBack(seen);
    }, cx);
    const moved = moveOn(xs);
    for (const a of panes) run(props()?.home ? `t3-tabs.close-pane:${a.pane}` : "pane.close", props()?.home ? undefined : { pane: a.pane });
    return moved;
  };
  const snooze = (a, at, cx) => {
    const seen = viewing(a);
    view.setLabel("snoozed", a.address, String(at), cx);
    view.remember("Snoozed", 1, (cx) => { wake(a, cx); if (seen) bringBack(a); }, cx);
    // The card moves away without a pointer-leave event, for it or for the clock under the pointer.
    view.napMenu = view.hovered = view.hot = null;
    detailsFor(view, null, cx);
    moveOn([a]);
  };
  // As T3's pick: a duration counts from the click; a time that passed since the menu was drawn is refused.
  const pick = (a, p, cx) => {
    if (p.custom) {
      // A dialog covers the card, and nothing reports leaving it until the pointer moves.
      view.napMenu = view.hovered = view.hot = null;
      detailsFor(view, null, cx);
      openOverlay({ mod: "t3-inbox", kind: "dialog", frame: "none", width: 384, props: { customSnooze: a.address } });
      return;
    }
    const at = p.hours ? Date.now() + p.hours * 3600000 : p.at;
    if (at > Date.now()) return snooze(a, at, cx);
    view.napAt = -1;
    notify({ title: "Couldn't snooze the agent", body: "That time has passed. Choose another.", level: "warning" });
  };
  // The Custom dialog's answer. By then it may have come to need the person, which T3 refuses too.
  view.customSnooze = (answer, cx) => {
    const i = answer.lastIndexOf(":"), at = Number(answer.slice(i + 1)), a = every.find((x) => x.address === answer.slice(0, i));
    if (a && state(a) !== "blocked" && at > Date.now()) snooze(a, at, cx);
  };
  // The settle key: the agent in view, as its card's Settle (finished) or its settled row's undo.
  view.settleKey = (cx) => {
    const a = every.find(viewing);
    if (!a) return;
    if (settledAt(a)) unsettle(a, cx);
    else if (!busy(a)) settle([a], cx);
  };

  // Clear closes settled agents' panes; Herdr then closes emptied tabs. The one in view stays.
  const spaceNow = sp.find((s) => s.active), tabNow = spaceNow?.tabs.find((c) => c.active)?.id;
  const doomed = put.filter((a) => a.pane && !viewing(a) && a.tab !== tabNow);
  view.clearSettled = () => {
    const gone = new Set(doomed.map((a) => a.pane));
    for (const id of new Set(doomed.map((a) => a.space))) {
      const s = sp.find((s) => s.id === id), tabs = s?.tabs.map((c) => c.id) ?? [];
      const mine = ps.filter((p) => tabs.includes(p.tab));
      // The space stays: pane.close refuses its last pane, so a space left empty gets a fresh shell tab first,
      // where its terminals are now: an unnamed space is named after that, and s.folder is only where it began.
      if (mine.every((p) => gone.has(p.pane))) run("tab.new", { space: id, folder: mine.find((p) => p.cwd)?.cwd || s.folder });
      for (const a of doomed.filter((a) => a.space === id)) run("pane.close", { pane: a.pane });
    }
    // tab.new shows the new tab; go back to where the person was.
    if (tabNow) { run("space.select", { id: spaceNow.id }); run("tab.select", { id: tabNow }); }
  };

  return { away, repin, unsettle, go, settle, pick, doomed };
}
