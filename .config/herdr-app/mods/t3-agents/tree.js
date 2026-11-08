// An agent with the sub-agents it started, one reading for Inbox cards, the agents list, tabs and pane headers:
// one stuck anywhere in it needs the person; then its own unread reply; an agent waiting on working sub-agents
// is still at work.
// A copy lives in each mod that uses it (scripts/sync.sh), as name.js does.

// A turn that failed needs the person as a question does. Programs report it as `error`; agents() has no such
// word, so it's read from the terminal's own (terminals()).
export const ownStatus = (word, address, all) => (all.find((k) => k.address === address)?.status === "error" ? "blocked" : word);

// A sub-agent's own word: a sub-agent without a pane isn't in agents(), so its raw word, error counting as
// blocked. It's never done: it reports to its parent, and the parent's done is the news.
export const kidStatus = (k, listed) => {
  const s = k.status === "error" ? "error" : listed.get(k.address) ?? k.status;
  return s === "error" ? "blocked" : s === "done" ? "idle" : s;
};

// Live sub-agents of `addr`, all the way down.
export function descendants(all, addr) {
  return all.filter((k) => k.parent === addr && k.state === "live").flatMap((k) => [k, ...descendants(all, k.address)]);
}

// Its own word with what's under it: needing the person first, then its own done, then busy or waiting on
// sub-agents it will hear back from, else its own. No word of its own: no agent, whatever it started.
export function treeStatus(own, kids) {
  if (own == null) return own;
  if (own === "blocked" || kids.includes("blocked")) return "blocked";
  return own !== "done" && kids.includes("working") ? "working" : own;
}

// A settled agent stays settled until new work: busy now, or a turn ended since. Label removal can still be in flight,
// or the Inbox not started, so the label alone isn't enough. `k` is its terminal.
export function stillSettled(k, word, kids) {
  const label = k?.labels?.settled;
  if (!label) return false;
  const busy = (s) => s === "working" || s === "blocked";
  return !busy(word) && !kids.some(busy) && (k.turn ?? 0) <= Number(label.split(":")[1]);
}

// Settled or snoozed (until it wakes) isn't news in either sidebar.
export function notNews(k, word, kids) {
  return stillSettled(k, word, kids) || Number(k?.labels?.snoozed) > Date.now();
}

// Snapshot once per render, like namer(): what's under each address, as words.
export function subAgents(agentList, all) {
  const listed = new Map(agentList.map((a) => [a.address, a.status]));
  return (addr) => descendants(all, addr).map((k) => kidStatus(k, listed));
}
