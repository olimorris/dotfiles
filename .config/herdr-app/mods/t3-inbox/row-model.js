import { kidStatus, descendants, ownStatus, treeStatus } from "./tree.js";

// The settled tail opens on this many, then grows by MORE.
export const FIRST = 10, MORE = 25;
// A run that stops stays on the Working shelf this long (ms), as in T3: a quick continuation doesn't move it twice.
const GRACE = 2000;
const BUSY = new Set(["working", "blocked"]);
// The last word when times tie, so the order doesn't follow the order the data came in.
const byAddress = (x, y) => x.address.localeCompare(y.address);

// Takes each agent's state as working, blocked or idle (done counts as idle: looking at it isn't news).
// A run's place in Working is when it started, as T3's is the person's message: a pause for them, or a stop
// that goes on within the grace, is the same run. Pinned and settled ones skip the grace, as in T3: their
// place doesn't hang on it. A turn ended while we weren't watching is news too. Hidden, nothing draws, so it goes by
// `changed`, when it really changed; a time no later than the last we saw is about something else, so then it's now.
export function trackInboxRows(previous, list, all, now) {
  const changes = { ...previous }, waits = [];
  let dirty = false;
  for (const { address, s, turn, excluded, first, changed } of list) {
    let was = changes[address];
    // The grace ran out: back with the person as of then, so it lands on top, and the run is over.
    if (was?.s === "idle" && was.start != null && (excluded || now - was.at >= GRACE)) {
      was = changes[address] = { s: "idle", at: excluded ? now : was.at + GRACE, turn: was.turn };
      dirty = true;
    }
    if (was?.s === s && (s !== "idle" || turn <= (was.turn ?? turn))) continue;
    const when = changed > (was?.at ?? 0) ? changed : now;
    const grace = was?.s === "working" && s === "idle" && !excluded && now - when < GRACE;
    if (grace) waits.push(GRACE - (now - when));
    changes[address] = !was ? { s, at: first ?? 0, turn } // First sight says nothing about when it changed.
      : s === "working" ? { s, at: was.start ?? when, turn }
      // A pause for the person, stuck or replying while its sub-agents work: the run keeps its start.
      : s === "blocked" || s === "done" ? { s, at: when, turn, start: was.s === "working" ? was.at : was.start }
      : grace ? { s, at: when, turn, start: was.at } // Stopped: the grace begins.
      : was.start != null && was.s === "idle" ? { ...was, turn } // The turn's end arriving within it.
      : { s, at: when, turn };
    dirty = true;
  }
  if (!dirty) return { changes, waits, dirty };
  // Only ended agents lose their record: one missing from the list for a moment comes back to its place.
  const listed = new Set(list.map((a) => a.address));
  const ended = new Set(all.filter((k) => k.state !== "live").map((k) => k.address));
  for (const [k, c] of Object.entries(changes)) if (!listed.has(k) && (ended.has(k) || k.startsWith("pane:") || now - c.at > 30 * 86400000)) delete changes[k];
  return { changes, waits, dirty };
}

export function inboxInView(every, all, f) {
  // The row in view: the focused agent's, or for a sub-agent with no row of its own (shown in a block, a peek), its
  // nearest listed ancestor's, as T3's resolveSidebarRowThreadId lights the parent of an open sub-agent.
  const card = every.find((a) => a.mod && a.pane === f?.pane);
  if (card) return card.address;
  const own = every.find((a) => a.focused);
  if (own) return own.address;
  const byAddress = new Map(all.map((k) => [k.address, k])), seen = new Set();
  // A mod pane has no agent of its own: it stands for the one beside it in its tab, if any. Herdr's agent is the
  // chosen one, else the first of all, so it counts only there, or for an agent block, which has no pane.
  if (f?.pane && !f.terminal) {
    const here = every.filter((a) => a.tab === f.tab);
    return (here.find((a) => a.address === f.agent) ?? here[0])?.address ?? null;
  }
  let k = byAddress.get(f?.pane ? f.terminal : f?.agent ?? f?.terminal);
  while (k && !every.some((a) => a.address === k.address) && !seen.has(k.address)) { seen.add(k.address); k = byAddress.get(k.parent); }
  return k && every.some((a) => a.address === k.address) ? k.address : null;
}

// All fields read the same snapshot; labels, focus and run records stay live for handlers drawn from it.
export function inboxFields({ every, all, term, pending, changed, now, inView }) {
  // Read live on the agent itself, so a key or click right after focus moves goes by where it is now.
  const cardInView = every.some(a => a.mod && a.address === inView);
  const stoodIn = inView !== null && !every.some(a => a.focused);
  const viewing = (a) => cardInView ? a.address === inView : a.focused || (stoodIn && a.address === inView);
  const settledAt = (a) => {
    const v = pending.settled[a.address] ?? term.get(a.address)?.labels?.settled;
    return v ? v.split(":").map(Number) : null;
  };
  const listed = new Map(every.map((a) => [a.address, a.status]));
  const kids = new Map(every.map((a) => [a.address, descendants(all, a.address).map((k) => kidStatus(k, listed))]));
  // It, or anything under it, is working or needs the person.
  const busy = (a) => BUSY.has(ownStatus(a.status, a.address, all)) || kids.get(a.address).some((s) => BUSY.has(s));
  // It with what's under it (tree.js).
  const state = (a) => treeStatus(ownStatus(a.status, a.address, all), kids.get(a.address));
  const running = (a) => state(a) === "working";
  // When a snooze ends (0: none). Past it, the label stays as "woke, not looked at yet".
  const napUntil = (a) => Number(pending.snoozed[a.address] ?? term.get(a.address)?.labels?.snoozed) || 0;
  // Out of sight until then, unless it needs the person.
  const hidden = (a) => !settledAt(a) && napUntil(a) > now && state(a) !== "blocked";
  const woke = (a) => napUntil(a) > 0 && napUntil(a) <= now;
  const mark = (a) => changed[a.address];
  // Seen changing, then; before that, the core's time of its last change. terminals() only has that as of
  // the app's start (status_ms isn't updated live), so it serves only until we see a change ourselves.
  const since = (a) => mark(a)?.at || term.get(a.address)?.status_ms || 0;
  // Just stopped: it shows its state now but keeps its Working place until the grace is out.
  const lingering = (a) => mark(a)?.s === "idle" && mark(a).start != null;
  // T3's Working shelf.
  const working = (a) => running(a) || lingering(a);
  // Active by when each came back to the person; Working by when its run started.
  const newest = (x, y) => since(y) - since(x) || byAddress(x, y);
  const begun = (a) => (lingering(a) ? mark(a).start || term.get(a.address)?.status_ms || 0 : since(a));
  // Working since: seen set going; before that, its own report, or for a parent waiting on sub-agents the
  // longest-working one's.
  const started = (a) => mark(a)?.at || (a.status === "working" ? term.get(a.address)?.status_ms
    : Math.min(Infinity, ...descendants(all, a.address).filter((k) => kidStatus(k, listed) === "working").map((k) => k.status_ms).filter(Boolean)));

  return { viewing, settledAt, kids, busy, state, running, napUntil, hidden, woke, since, working, newest, begun, started };
}

// Plain row facts in; ordered sections, visible pages and the next wake out. No storage, commands or timers.
export function inboxSections(every, { scope, pins, workOpen, napOpen, open, limit }) {
  const list = scope.length ? every.filter((x) => scope.includes(x.a.space)) : every;
  const newest = (x, y) => y.since - x.since || byAddress(x, y);
  const pinned = pins.map((p) => list.find((x) => x.address === p)).filter((x) => x && !x.hidden);
  const rest = list.filter((x) => !pins.includes(x.address));
  // Active by when each came back to the person; Working by when its run started.
  const out = rest.filter((x) => !x.settledAt && !x.hidden && !x.working).sort(newest);
  const work = rest.filter((x) => !x.settledAt && !x.hidden && x.working).sort((x, y) => y.begun - x.begun || byAddress(x, y));
  // Soonest back first; pinned ones too: they wake back to their pin.
  const nap = list.filter((x) => x.hidden).sort((x, y) => x.napUntil - y.napUntil || byAddress(x, y));
  const put = rest.filter((x) => x.settledAt).sort((x, y) => y.settledAt[0] - x.settledAt[0] || byAddress(x, y));
  // Shelves fold by default on this screen; the one in view stays out even folded or past the page, so it's never lost.
  const busyRows = workOpen ? work : work.filter((x) => x.viewing);
  const napRows = napOpen ? nap : nap.filter((x) => x.viewing);
  const page = open ? put.slice(0, limit) : [];
  const rows = [...page, ...put.filter((x) => x.viewing && !page.includes(x))];
  const next = Math.min(Infinity, ...every.filter((x) => x.hidden).map((x) => x.napUntil));
  return { next, ...Object.fromEntries(Object.entries({ list, pinned, out, work, nap, put, busyRows, napRows, rows }).map(([key, xs]) => [key, xs.map((x) => x.a)])) };
}
