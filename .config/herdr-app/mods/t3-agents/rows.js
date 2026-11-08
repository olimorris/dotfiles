// The agents list's rows and group headers, including their leaving ghosts.
import { div, image, svg } from "gpui-kit";
import { h_flex, Popup } from "gpui-base";
import { spaces, run, hc, notify, setShared, openOverlay } from "herdr";
import { namer } from "./name.js";
import { focusAgent } from "./zoom.js";
import { kidStatus } from "./tree.js";
import { projectMark } from "./project.js";
import { glow, hoverKept, tip, tipMark } from "./tip.js";
import { programIcon, detailsFor, detailsAt, detailsLine, detailsCard } from "./details.js";
import { stop, within } from "./focus.js";
import { MOTION, foldArrow } from "./motion.js";

// T3's one-line row and shelf or folder header, its folders 8 apart and its list's 1px between items (gap-px).
const ROW = 36, HEAD = 32, HEAD_GAP = 8;
export const STACK = 1;
export const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
export const SECTION = { 4: "Needs you", 3: "Done", 2: "Working", 1: "Idle" };

// The agent's icon from the app's program table: a one-color glyph or a picture.
function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

// How long it's been in its state, as the shipped agents list says it.
function duration(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "<1m";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

// Live sub-agents of `addr`, depth first, each with the tree lines in front of it.
function agentTree(all, addr, lead = []) {
  const kids = all.filter((k) => k.parent === addr && k.state === "live");
  return kids.flatMap((k, i) => {
    const last = i === kids.length - 1;
    return [
      { t: k, depth: lead.length + 1, lines: [...lead, last ? "└" : "├"] },
      ...agentTree(all, k.address, [...lead, last ? "" : "│"]),
    ];
  });
}

// `ghost`: drawn for its leaving, without handlers or ids the list uses.
function agentSubRow(view, t, s, shown, card, ghost) {
  const k = s.t;
  const st = kidStatus(k, view.listed);
  const pic = icon(k.program, 14, t.foreground);
  const on = k.address === shown;
  const name = k.name || k.template || k.program?.name || k.address;
  const rowId = `sub-${k.address}`;
  const over = !ghost && (view.hovered === rowId || within(view, [rowId]));
  const base = h_flex()
    .relative()
    .pl(10 + s.depth * 20)
    .pr(10)
    .rounded(6)
    .h(ROW)
    .flex_none()
    .items_center()
    .gap(10)
    .text_size(14)
    .when(on, (el) => el.bg(t.selected))
    // Upstream's 9px turn, hung from each ancestor's icon center (18px, then every 20px), ending 4px short of this icon.
    .children(s.lines.flatMap((l, j) => [
      l === "│" || l === "├" ? div().absolute().left(17.25 + 20 * j).top(0).bottom(-STACK).w(1.5).bg(t.input) : null,
      l === "├" || l === "└" ? div().absolute().left(17.25 + 20 * j).top(-4).h(22).w(9.75).border_l(1.5).border_b(1.5).rounded_bl(6).border_color(t.input) : null,
    ].filter(Boolean)))
    .child(h_flex().size(16).flex_none().items_center().justify_center()
      .when(Boolean(pic), el => el.child(pic)))
    .child(h_flex().flex_1().min_w(0).overflow_hidden()
      .child(div().min_w(0).truncate().when(on, (el) => el.font_medium()).text_color(on || over ? t.foreground : t.muted).child(name)))
    .child(agentStatus(view, t, { status: st }, "", ghost ? undefined : `sub-status-${k.address}`));
  if (ghost) return base;
  return stop(view, t, rowId, base
    .id(rowId)
    .role("button").accessibility_label(name)
    .when(!on, el => el.hover(s => s.bg(t.hover)).active(s => s.bg(t.selected)))
    .on_hover((over, cx) => {
      if (over) { view.hovered = rowId; detailsFor(view, rowId, cx); }
      else if (view.hovered === rowId) { view.hovered = null; detailsFor(view, null, cx); }
      cx.notify();
    })
    .on_mouse_move((e) => detailsAt(view, rowId, e))
    .on_click((_e, cx) => {
      // The peek opens where the card stands: no fade, or the two overlap.
      detailsFor(view, null, cx);
      view.detailsOut = null;
      cx.notify();
      run("terminal.peek", { terminal: k.address });
    })
    .when([view.hovered, view.details, view.detailsOut].includes(rowId), (el) => el.child(card(name, rowId))), 6);
}

export function agentStatus(view, t, a, note = "", id) {
  const color = t[a.status] ?? t.dim;
  let mark;
  if (a.status === "working") mark = svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900);
  else if (a.status === "blocked") mark = div().size(12).flex_none().rounded(3).bg(t.blocked + "26").text_size(10).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!");
  // Idle: a ring; done: a dot. Every mark is 12 wide, as T3's one-line row, flush right, so the column ends where Spaces' git info does.
  else if (a.status === "idle") mark = div().size(6).mx(3).flex_none().rounded_full().border(1.5).border_color(t.idle ?? t.dim);
  else mark = div().size(6).mx(3).flex_none().rounded_full().bg(a.status === "done" ? color : t.dim + "00");
  const label = (SECTION[RANK[a.status]] ?? "Unknown") + note;
  const el = h_flex().size(20).flex_none().items_center().justify_end()
    .role("status").accessibility_label(label).child(mark);
  return id ? tipMark(view, t, `${id}-mark`, label, el.id(id)) : el;
}

export function agentEntries(view, t, { list, all, shown, ps, now, viewing, byPriority, own, shownStatus, groups }) {
  const withKids = (a, i) => {
    const subs = agentTree(all, a.address);
    const r = { key: a.address, h: ROW + STACK, el: row(a, i, subs), ghost: () => row(a, i, subs, true) };
    // A sub-agent with no pane of its own isn't in agents(): it's placed by the agent it hangs from, and has no branch to name, as its folder may be another worktree.
    const sub = (s) => ({ key: `sub-${s.t.address}`, h: ROW + STACK, el: agentSubRow(view, t, s, shown, (name, key) => details(list.find((x) => x.address === s.t.address) ?? { ...s.t, space: a.space, space_name: a.space_name }, name, key)), ghost: () => agentSubRow(view, t, s, shown, null, true) });
    if (!view.isFolded(a.address)) return [r, ...subs.map(sub)];
    // Folded, a sub-agent that needs the person still shows, hung straight from its parent.
    const stuck = subs.filter((s) => kidStatus(s.t, view.listed) === "blocked");
    return [r, ...stuck.map((s, j) => sub({ t: s.t, depth: 1, lines: [j === stuck.length - 1 ? "└" : "├"] }))];
  };

  // A button's icon and text brighten together: a hover style reaches the text but not the svg, so it's state,
  // as in the inbox. Inside a hovered row a button's own hover fill doesn't show, so this is the cue.
  const lit = (id) => (view.hot === id ? t.foreground : t.dim);
  // As the shipped agents list: a parent's fold arrow, and folded, the count. Dim: the row's status
  // carries any hidden child's urgency.
  const fold = (a, subs, ghost) => {
    const open = !view.isFolded(a.address), id = `fold-${a.address}`, color = ghost ? t.dim : lit(id);
    const base = div()
      .h(20).min_w(20).flex_none()
      .px(6)
      .flex()
      .items_center()
      .justify_center()
      .rounded(4)
      .text_size(11)
      .gap(4)
      .text_color(color)
      .when(!open, (el) => el.child(String(subs.length)))
      .child(foldArrow("t3-agents", ghost ? null : `${id}-arrow`, open, 12, color));
    if (ghost) return base;
    return tip(view, t, id, open ? "Collapse sub-agents" : "Expand sub-agents", stop(view, t, id, base
      .id(id)
      // As T3's row controls, hover only lights it: no ground.
      .role("button").accessibility_label(open ? "Collapse sub-agents" : "Expand sub-agents")
      .on_hover(glow(view, id))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        view.toggleFold(a.address, cx);
      }), 4));
  };

  // A row's detail is what the agent is on, as the inbox, tabs and pane headers name it.
  const label = namer();
  const detail = new Map(list.map(a => [a.address, /^\d+$/.test(label(a)) ? null : label(a)]));
  const seen = {};
  for (const a of list) { const k = `${a.space_name}\u0000${detail.get(a.address) ?? ""}`; seen[k] = (seen[k] ?? 0) + 1; }
  for (const a of list) {
    if (detail.get(a.address) == null && seen[`${a.space_name}\u0000`] > 1) detail.set(a.address, label(a));
  }

  // A row's details, as t3-inbox's and T3's thread card: on the row's right from its top. A control lit in the row speaks for itself instead.
  // `key`: a sub-agent with a pane is also listed on its own, and each of its rows goes by itself.
  const details = (a, name, key = a.address) => {
    const machine = a.address.includes("/") ? a.address.split("/")[0] : null;
    const branch = ps.find((p) => p.pane === a.pane)?.branch, pic = programIcon(a.program, 12, t.muted);
    const up = view.details === key || view.detailsOut === key;
    return Popup.new(`details-${key}`, div()).absolute().top(-1).right(-1).size(1)
      .when(up, (pop) => pop.content(detailsCard(view, t, key, name, [
        a.space_name && detailsLine(t, projectMark(spaces().find((s) => s.id === a.space) ?? { name: a.space_name }, 12, t, ps, true), a.space_name),
        machine && detailsLine(t, svg("mods/t3-agents/icons/server.svg").size(12).flex_none().text_color(t.muted), machine),
        branch && detailsLine(t, svg("mods/t3-agents/icons/git-branch.svg").size(12).flex_none().text_color(t.muted), branch),
        pic && detailsLine(t, div().flex_none().opacity(0.6).child(pic), a.program.name),
      ], { hide: Boolean(view.hot) }).ml(4)));
  };

  const row = (a, i, subs = [], ghost) => {
    const pic = icon(a.program, 16, t.foreground);
    const more = detail.get(a.address);
    // An agent on another machine (`vps/t7`) says which.
    const machine = a.address.includes("/") ? a.address.split("/")[0] : null;
    const st = shownStatus(a), on = viewing(a);
    const isPinned = view.pins.includes(a.address);
    const pinId = `pin-${a.address}`, rowId = `ag-${a.address}`;
    // Hovered, or with the keyboard on the row or inside it.
    const offer = !ghost && (view.hovered === a.address || within(view, [rowId, pinId, `fold-${a.address}`]));
    // As T3's rows: what you're on or what wants you leads; the rest recede until hovered, a working one fainter still.
    const leads = on || offer || st === "blocked" || st === "done";
    // Over the time's slot on hover, as in the shipped list; the two cross-fade, as T3's corner. Faded out it's no button.
    const pin = () => div().id(pinId)
      .size(24).flex_none().flex().items_center().justify_center()
      .rounded(6)
      .opacity(offer ? 1 : 0).transition("opacity", MOTION)
      .when(offer, (el) => stop(view, t, pinId, el.role("button")
        .accessibility_label(isPinned ? "Unpin" : "Pin")
        .on_hover(glow(view, pinId))
        .on_click((_e, cx) => {
          cx.stop_propagation();
          // The row's about to move from under the pointer.
          view.hovered = view.hot = null;
          detailsFor(view, null, cx);
          setShared("agents.pins", isPinned ? view.pins.filter((p) => p !== a.address) : [...view.pins, a.address]);
          // A pin ends a snooze. Here, not in the Inbox: it may not have started yet.
          if (!isPinned && all.find((k) => k.address === a.address)?.labels?.snoozed) cx.spawn(async () => {
            const r = await hc(["label", a.address, "snoozed="]).catch((e) => ({ code: 1, stderr: String(e) }));
            if (r.code !== 0) notify({ title: "Couldn't update the agent", body: r.stderr.trim(), level: "error" });
          });
          cx.notify();
        }), 6))
      .child(svg(`mods/t3-agents/icons/${isPinned ? "pin-off" : "pin"}.svg`).size(12).flex_none().text_color(lit(pinId)));
    // A row leads with what the agent is on; an automatic tab number says nothing.
    // Without a space header above (priority, pinned) the space follows, dim, and gives way first.
    const full = byPriority || isPinned;
    const name = full ? more ?? (a.space_name || label(a)) : more ?? (/^\d+$/.test(label(a)) ? a.program?.name || label(a) : label(a));
    const where = full && more && a.space_name && a.space_name !== more ? a.space_name : null;
    // Its sub-agents' word, when it isn't its own, is marked as theirs.
    const fromKid = st !== "idle" && st !== own(a);
    const when = view.since(a);
    const lead = h_flex().size(16).flex_none().items_center().justify_center().when(Boolean(pic), el => el.child(pic));
    const server = svg("mods/t3-agents/icons/server.svg").size(14).flex_none().text_color(t.dim);
    const time = div().flex_none().text_size(12).text_color(t.dim).opacity(offer ? 0 : 1).transition("opacity", MOTION).when(Boolean(when), el => el.child(duration(now - when)));
    const base = h_flex()
      .relative()
      .w_full().min_w(0)
      .px(10)
      .h(ROW)
      .flex_none()
      .rounded(6)
      .items_center()
      .gap(10)
      .opacity(st === "working" && !on && !offer ? 0.7 : 1)
      .when(on, (el) => el.bg(t.selected))
      .child(ghost ? lead : lead.id(`agent-fold-${a.address}`)
        .when(subs.length > 0, el => el.role("button").accessibility_label(view.isFolded(a.address) ? "Expand sub-agents" : "Collapse sub-agents").on_click((_e, cx) => {
          cx.stop_propagation();
          view.toggleFold(a.address, cx);
        })))
      .child(h_flex().flex_1().min_w(0).gap(10).items_center()
        .child(div().min_w(0).truncate().when(on || st === "blocked" || st === "done", (el) => el.font_medium()).text_color(leads ? t.foreground : t.muted).child(name))
        .when(Boolean(where), el => el.child(div().flex_1().flex_shrink(1000).min_w(0).truncate().text_size(12).text_color(t.dim).child(where))))
      // As Inbox's cards and T3's: a server mark, the machine named on hover.
      .when(Boolean(machine), el => el.child(ghost ? server : tipMark(view, t, `machine-${a.address}`, machine, server)))
      .child(h_flex().when(!ghost, el => el.id(`controls-${a.address}`)).flex_none().items_center().gap(4)
        .when(subs.length > 0, el => el.child(fold(a, subs, ghost)))
        // The time and the pin share one slot, T3's corner, so hovering moves nothing else.
        .child(ghost ? h_flex().h(24).min_w(32).flex_none().items_center().justify_end().child(time)
          : h_flex().id(`when-${a.address}`).relative().h(24).min_w(32).flex_none().items_center().justify_end()
            .child(time)
            .child(div().absolute().top(0).right(0).child(tip(view, t, pinId, isPinned ? "Unpin" : "Pin", pin()))))
        .child(agentStatus(view, t, { status: st }, fromKid ? " (sub-agent)" : "", ghost ? undefined : `status-${a.address}`)));
    if (ghost) return base;
    return stop(view, t, rowId, base
      .id(rowId)
      .transition("opacity", MOTION)
      .role("button").accessibility_label(label(a) || a.program?.name || a.address)
      .when(!on, el => el.hover(s => s.bg(t.hover)).active(s => s.bg(t.selected)))
      .when([view.hovered, view.details, view.detailsOut].includes(a.address), (el) => el.child(details(a, name)))
      .on_hover((over, cx) => {
        if (over) { view.hovered = a.address; detailsFor(view, a.address, cx); }
        else if (view.hovered === a.address) { view.hovered = null; detailsFor(view, null, cx); }
        cx.notify();
      })
      .on_mouse_move((e) => detailsAt(view, a.address, e))
      .on_click((_e, cx) => {
        // As a T3 tooltip, a click takes its card down until the pointer comes back.
        detailsFor(view, null, cx);
        focusAgent(a.address);
      }), 6);
  };

  // Groups in list order: spaces (grouped) or priority sections. Agents of a
  // space are next to each other in agents(), so neighbours make a group.
  // A group no longer drawn never reports the pointer leaving it, so it would come back lit.
  if (!groups.some((g) => g.id === view.overGroup)) view.overGroup = null;
  const chevron = (g, open, ghost) => {
    const color = !ghost && view.overGroup === g.id ? t.foreground : t.dim;
    return div().flex_none().text_color(color).child(foldArrow("t3-agents", ghost ? null : `chevron-${g.id}`, open, 12, color));
  };
  // Drawn as Inbox's shelves, T3's: a dim label, then at the far edge the count and the chevron, an indicator that lights with its row.
  const shelf = (g, open, ghost) => {
    const base = h_flex()
      .mx(2).px(8)
      .h(HEAD)
      .flex_none()
      .gap(8)
      .items_center()
      .text_size(12)
      .font_medium()
      .text_color(t.dim)
      .child(div().flex_1().min_w(0).truncate().child(g.label))
      .child(div().flex_none().font_normal().child(String(g.members.length)))
      .child(chevron(g, open, ghost));
    if (ghost) return base;
    return stop(view, t, g.id, hoverKept(view, "overGroup", g.id, base
      .id(g.id)
      .role("button").accessibility_label(`${open ? "Collapse" : "Expand"} ${g.label}`)
      .on_click((_e, cx) => view.toggleFold(g.id, cx, g.id === "sec-1"))));
  };
  // A space's group, as T3's project folder: its mark and name; closed, how many it hides and a dot if one of them wants you.
  // Right-click: the space's menu, as in Spaces.
  const folder = (g, open, ghost) => {
    const hiding = open ? [] : g.members.filter((a) => !viewing(a));
    const top = hiding.map(shownStatus).reduce((m, s) => ((RANK[s] ?? 0) > (RANK[m] ?? 0) ? s : m), null);
    const dot = top && top !== "idle";
    const space = spaces().find((s) => s.id === g.space) ?? { name: g.label };
    const base = h_flex()
      .px(10)
      .h(HEAD)
      .flex_none()
      .gap(10)
      .items_center()
      .rounded(8)
      .child(projectMark(space, 16, t, ps, true))
      .child(div().flex_1().min_w(0).truncate().font_medium().text_color(t.foreground + "e6").child(g.label))
      .when(Boolean(dot), (el) => el.child(div().size(6).flex_none().rounded_full().bg(t[top]).role("status").accessibility_label(SECTION[RANK[top]])))
      .when(hiding.length > 0, (el) => el.child(div().flex_none().text_size(12).text_color(t.dim).child(String(hiding.length))))
      .child(chevron(g, open, ghost));
    if (ghost) return base;
    return stop(view, t, g.id, hoverKept(view, "overGroup", g.id, base
      .id(g.id)
      .hover((s) => s.bg(t.hover))
      .active((s) => s.bg(t.selected))
      .role("button").accessibility_label(`${open ? "Collapse" : "Expand"} ${g.label}`)
      .on_click((_e, cx) => view.toggleFold(g.id, cx, false))
      .on_mouse_down("right", () => openOverlay({ mod: "t3-menu", kind: "popup", width: 220, height: 260, props: { tab: "space", target: { id: g.space } } }))), 8);
  };
  // A closed group still shows the row you're on, as T3's route row, and hints at the rest.
  const entries = groups.flatMap((g, i) => {
    const open = !view.isFolded(g.id, g.id === "sec-1");
    const head = (ghost) => g.space ? div().flex_none().when(i > 0, (el) => el.pt(HEAD_GAP)).child(folder(g, open, ghost)) : shelf(g, open, ghost);
    return [{ key: `m:${g.id}`, h: HEAD + STACK + (g.space && i ? HEAD_GAP : 0), el: head(false), ghost: () => head(true) },
      ...(open ? g.members : g.members.filter(viewing)).flatMap(withKids)];
  });

  return entries;
}
