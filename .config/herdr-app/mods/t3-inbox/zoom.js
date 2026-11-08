import { panes, run } from "herdr";

// A tab draws its zoomed pane whichever pane is focused, and focusing moves no zoom: the card would light one agent while another
// shows, the keyboard would go nowhere, and showing that other one would cost it its done. So the zoom goes first, in the focus's
// tick: a tick's commands land in one frame, and in a tab out of view a zoom shows nothing. pane.zoom toggles, so never on the pane already zoomed.
function zoomTo(found) {
  const ps = panes(), p = ps.find(found);
  if (p && !p.zoomed && ps.some(q => q.tab === p.tab && q.zoomed)) run("pane.zoom", { pane: p.pane });
}
export function focusPane(pane) {
  zoomTo(p => p.pane === pane);
  run("pane.focus", { pane });
}
export function focusAgent(terminal) {
  zoomTo(p => p.terminal === terminal);
  run("agent.focus", { terminal });
}
