// A space's mark, as T3 Code's sidebar draws a project (ProjectFavicon): the project's own icon when it has
// one, else a two-letter monogram tinted with a color its name picks. One rule, with a copy in each mod that
// draws spaces (t3-inbox, t3-spaces, t3-new-menu, t3-tabs).
import { image, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, readTextFile, appHome, settings, shared, setShared, spaces, panes } from "herdr";
import { Buffer } from "buffer";
import { createHash } from "crypto";
import * as fs from "fs/promises";

// T3's project colors in its order, each as Tailwind's 400 (dark themes) and 600 (light).
const PALETTE = [
  ["#9ca3af", "#4b5563"], ["#f87171", "#dc2626"], ["#fb923c", "#ea580c"], ["#fbbf24", "#d97706"],
  ["#facc15", "#ca8a04"], ["#a3e635", "#65a30d"], ["#4ade80", "#16a34a"], ["#34d399", "#059669"],
  ["#2dd4bf", "#0d9488"], ["#22d3ee", "#0891b2"], ["#38bdf8", "#0284c7"], ["#60a5fa", "#2563eb"],
  ["#818cf8", "#4f46e5"], ["#a78bfa", "#7c3aed"], ["#c084fc", "#9333ea"], ["#e879f9", "#c026d3"],
  ["#f472b6", "#db2777"], ["#fb7185", "#e11d48"],
];

// The name's first letter or digit, capitalized: one glyph, where T3 spells two (a CJK pair only fits
// squeezed). A name without letters or digits (home's "~") spells nothing.
function monogram(name) {
  const first = name.normalize("NFKC").match(/[\p{L}\p{N}]/u)?.[0];
  return first ? [...first.toUpperCase()][0] : "";
}

// As T3: the name, folded, hashed into the palette, so a name has one color everywhere.
export function tint(name, dark) {
  const seed = name.normalize("NFKC").trim().toLocaleLowerCase("en-US") || "project";
  let i = 0;
  for (const g of seed) i = (i * 31 + g.codePointAt(0)) % PALETTE.length;
  return PALETTE[i][dark ? 0 : 1];
}

function isDark(t) {
  const hex = /^#([0-9a-f]{6})/i.exec(t.background ?? "");
  if (!hex) return true;
  const n = parseInt(hex[1], 16);
  return (n >> 16) * 0.299 + ((n >> 8) & 255) * 0.587 + (n & 255) * 0.114 < 128;
}

// `ps`: panes(), read once by the caller (each read copies every pane). `follow`: drawn beside a mod that keeps looking
// (t3-spaces, t3-inbox), so it asks only where no one has answered yet.
export function projectMark(s, size, t, ps, follow) {
  const icon = s && projectIcon(s, ps, follow);
  if (icon) return image(icon).size(size).flex_none().rounded(size / 4);
  const text = monogram(s?.name ?? "");
  // Nothing to spell: T3's plain folder.
  if (!text) return h_flex().size(size).flex_none().items_center().justify_center()
    .child(svg("mods/workspace-chrome/folder.svg").size(size).text_color(t.dim));
  const color = tint(s.name, isDark(t));
  // As T3's ProjectMonogram: the color on a 14% wash of itself, bold monospace at its 8.25 in a 16 tile.
  return h_flex().size(size).flex_none().rounded(size / 4).bg(color + "24").items_center().justify_center()
    .font_family(settings().font_family ?? "JetBrains Mono").font_bold().text_size(size * 8.25 / 16).text_color(color)
    .child(text);
}

// T3's well-known places (ProjectFaviconResolver), less the .icns ones an image here can't be.
const PLACES = ["favicon.svg", "favicon.ico", "favicon.png", "public/favicon.svg", "public/favicon.ico", "public/favicon.png",
  "app/favicon.ico", "app/favicon.png", "app/icon.svg", "app/icon.png", "app/icon.ico", "src/favicon.ico", "src/favicon.svg",
  "src/app/favicon.ico", "src/app/icon.svg", "src/app/icon.png", "assets/icon.svg", "assets/icon.png", "assets/logo.svg",
  "assets/logo.png", ".idea/icon.svg"];
// Then the pages that may link one.
const PAGES = ["index.html", "public/index.html", "app/routes/__root.tsx", "src/routes/__root.tsx", "app/root.tsx", "src/root.tsx", "src/index.html"];

// As T3: an HTML <link rel="icon" href>, else a route's { rel: "icon", href }.
function linkedIcon(source) {
  const html = /<link\b(?=[^>]*\brel=["'](?:icon|shortcut icon)["'])(?=[^>]*\bhref=["']([^"'?]+))[^>]*>/i.exec(source);
  if (html) return html[1];
  for (const run of source.split("}")) {
    if (!/\brel\s*:\s*["'](?:icon|shortcut icon)["']/i.test(run)) continue;
    const href = /\bhref\s*:\s*["']([^"'?]+)/i.exec(run);
    if (href) return href[1];
  }
  return null;
}

// The icon of the project a folder is in (its repo's top, as T3's project root), copied under the app's
// folder (images show only from there); null if it has none. All through exec and readTextFile, so another
// machine's space works the same.
async function lookUp(on, dir) {
  const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd: dir, on });
  const root = (top.code === 0 && top.stdout.trim()) || dir;
  const first = async (paths) => (await exec("sh", ["-c", 'for f; do [ -f "$f" ] && { printf %s "$f"; exit; }; done', "sh", ...paths], { cwd: root, on })).stdout || null;
  let hit = await first(PLACES);
  for (const page of PAGES) {
    if (hit) break;
    const href = linkedIcon((await readTextFile(`${root}/${page}`, { on })) ?? "")?.replace(/^\//, "");
    // Inside the folder only, as T3 keeps it.
    if (href && !href.split("/").includes("..")) hit = await first([`public/${href}`, href]);
  }
  if (!hit) return null;
  const r = await exec("sh", ["-c", 'base64 < "$1"', "sh", hit], { cwd: root, on });
  if (r.code !== 0) return null;
  const bytes = Buffer.from(r.stdout.replace(/\s+/g, ""), "base64");
  // Named by its content: a changed icon is a new file, so nothing keeps showing the old one.
  const name = `cache/t3-icons/${createHash("sha256").update(bytes).digest("hex").slice(0, 16)}${hit.slice(hit.lastIndexOf(".")).toLowerCase()}`;
  if (!(await fs.exists(`${appHome()}/${name}`))) {
    await fs.mkdir(`${appHome()}/cache/t3-icons`, { recursive: true });
    await fs.writeFile(`${appHome()}/${name}`, bytes);
  }
  return name;
}

// Where a space is now, as t3-spaces has it: its first terminal's live folder, else where it was made.
export function placeOf(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps?.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}

// Shared "space.icons": [machine, folder] -> the copy's path or null, so every mod shows what one found.
// shortcut: folders with an icon that no space uses any more stay listed; prune them if the list ever grows noticeably.
const looked = new Map(); // [machine, folder] -> when this copy last looked
const lastIcon = new Map(); // space -> its icon where it last had an answer
const iconKey = (s, ps) => JSON.stringify([s.machine ?? null, placeOf(s, ps)]);
function projectIcon(s, ps, follow) {
  const folder = placeOf(s, ps);
  if (!folder) return null;
  const key = iconKey(s, ps), icons = shared("space.icons") ?? {}, known = icons[key] ?? null;
  // As T3's cache: a found icon is looked for again after 10 minutes, a missing one after a minute.
  const stale = !looked.has(key) || Date.now() - looked.get(key) > (known ? 600000 : 60000);
  if (stale && !(follow && key in icons)) {
    looked.set(key, Date.now());
    lookUp(s.machine ?? null, folder).then((found) => {
      const all = shared("space.icons") ?? {};
      if (all[key] === found) return;
      // Each folder a terminal passes through would otherwise stay listed as having none.
      const ps = panes(), used = new Set(spaces().map((x) => iconKey(x, ps)));
      setShared("space.icons", { ...Object.fromEntries(Object.entries(all).filter(([k, icon]) => icon || used.has(k))), [key]: found });
    }, () => {}); // a machine away, no sh: the next look tries again
  }
  // Until a place new to it answers (a cd), the space keeps the icon it had, not a flash of its letter.
  if (!(key in icons)) return lastIcon.get(s.id) ?? null;
  lastIcon.set(s.id, known);
  return known;
}
