// What a terminal is on, one rule for Inbox cards, the agents list, tabs and pane headers:
// its Pi session while Pi runs, then (agents only) a tab someone named, then a telling terminal title, else the program.
// A terminal with no title of its own reports its address (t9) as one: that tells nothing.
import { terminals, spaces, shared } from "herdr";

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();
// Agents' own title marks, by program (the key their status report names): Pi's "π - <session> - <folder>",
// OpenCode's "OC | <session>". Only theirs come off: another agent's title that happens to look alike stays.
const MARK = { pi: /^π - /u, opencode: /^OC \| / };
const OWN = {
  pi: (s, folder) => { s = s.replace(MARK.pi, ""); return folder && s.endsWith(` - ${folder}`) ? s.slice(0, -folder.length - 3) : s; },
  opencode: (s) => s.replace(MARK.opencode, ""),
};

// What a pane runs, for its icon: its program, or for a mod pane what its mod gives in shared("<mod>.program") ({ icon, tint }).
export const programOf = (x) => x.mod ? shared(`${x.mod}.program`) ?? null : x.program;

// What a mod pane reports of its tab in shared("<mod>.status"), as the word an agent would.
export const modStatus = (x) => shared(`${x.mod}.status`)?.[x.tab] ?? null;

// Snapshot once per render; the returned function takes an agent or a pane (status set = an agent).
export function namer() {
  const term = new Map(terminals().map((k) => [k.address, k]));
  const tabs = new Map(spaces().flatMap((s) => s.tabs.map((c) => [c.id, { ...c, space: s.name }])));
  return (x) => {
    // A mod pane goes by the title its mod gives it in shared("<mod>.titles"), keyed by its tab; else its folder name.
    if (x.mod) return shared(`${x.mod}.titles`)?.[x.tab] || x.title;
    const address = x.address ?? x.terminal;
    const tab = tabs.get(x.tab);
    // A title that only names the folder (Codex's project, Pi with no session) says what the space already does.
    const folder = (term.get(address)?.cwd ?? x.cwd ?? "").split(/[\\/]/).pop();
    const own = OWN[x.program?.key];
    // An agent's session and title outlive it: lazygit, started after Pi in the same shell, sets no title and
    // would read as Pi's session. Not an agent and in an agent's marks, the title is one left behind.
    const left = !x.program?.agent && Object.values(MARK).some((m) => m.test(clean(x.title)));
    const live = left ? "" : own ? own(clean(x.title), folder) : clean(x.title);
    const telling = live && live !== x.program?.name && live.toLowerCase() !== x.program?.key
      && !/^[~/]|^[A-Za-z]:\\/.test(live) && !live.includes("@") && live !== address
      && live !== folder && live !== (x.space_name ?? tab?.space);
    return (x.program?.key === "pi" && term.get(address)?.labels?.["pi.session"]) || (x.status != null && tab?.named && tab.name)
      || (telling && live) || x.program?.name || address || "shell";
  };
}
