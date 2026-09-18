#!/usr/bin/env python3
"""Convert a tmux-resurrect save into a herdr-resurrect snapshot.

    ./tmux-resurrect-import.py                 # convert, print the restore command
    ./tmux-resurrect-import.py --set-last      # also make it the snapshot restore uses
    ./tmux-resurrect-import.py --only dotfiles --only notes
"""

import argparse
import datetime
import json
import os
import pathlib
import re
import socket
import sys

TMUX_LAST = pathlib.Path.home() / ".local/state/tmux/resurrect/last"
SNAP_DIR = pathlib.Path.home() / ".local/state/herdr-resurrect/snapshots"
LAST_JSON = pathlib.Path.home() / ".local/state/herdr-resurrect/last.json"

SHELLS = {"zsh", "bash", "fish", "sh", "dash", "ksh", "nu", "login", "-zsh", "-bash"}
AGENTS = {
    "claude": "claude",
    "codex": "codex",
    "gemini": "gemini",
    "cursor-agent": "cursor",
    "copilot": "copilot",
    "opencode": "opencode",
    "droid": "droid",
    "amp": "amp",
    "pi": "pi",
}
RESTORABLE = {
    "vi", "vim", "nvim", "view", "emacs", "helix", "hx",
    "man", "less", "more", "tail", "top", "htop", "btop",
    "ssh", "mosh", "irssi", "weechat", "mutt", "lazygit", "lazydocker", "k9s",
}


def agent_name(command):
    base = command.split("/")[-1]
    for prefix, name in AGENTS.items():
        if base == prefix or base.startswith(prefix + "-"):
            return name
    return None


def parse_layout(layout):
    """Return the leaf rects of a tmux layout string, in tmux pane order."""
    body = layout.split(",", 1)[1] if "," in layout else layout
    pos = 0
    leaves = []

    def node():
        nonlocal pos
        m = re.match(r"(\d+)x(\d+),(\d+),(\d+)", body[pos:])
        if not m:
            raise ValueError(f"bad layout at {pos}: {body[pos:pos + 20]!r}")
        w, h, x, y = (int(v) for v in m.groups())
        pos += m.end()
        if pos < len(body) and body[pos] in "{[":
            closer = "}" if body[pos] == "{" else "]"
            pos += 1
            while True:
                node()
                if pos < len(body) and body[pos] == ",":
                    pos += 1
                    continue
                break
            if pos >= len(body) or body[pos] != closer:
                raise ValueError(f"unbalanced layout near {pos}")
            pos += 1
        else:
            m2 = re.match(r",(\d+)", body[pos:])
            if m2:
                pos += m2.end()
            leaves.append({"x": x, "y": y, "width": w, "height": h})

    node()
    return leaves


def parse_pane(fields):
    full = fields[-1][1:] if fields[-1].startswith(":") else fields[-1]
    if fields[-2].isdigit():
        command, active, path = fields[-3], fields[-4], fields[-5]
        title_end = len(fields) - 5
    else:
        command, active, path = fields[-2], fields[-3], fields[-4]
        title_end = len(fields) - 4
    return {
        "session": fields[1],
        "window": int(fields[2]),
        "window_flags": fields[4],
        "pane": int(fields[5]),
        "title": "\t".join(fields[6:title_end]),
        "cwd": path[1:] if path.startswith(":") else path,
        "active": active == "1",
        "command": command,
        "full_command": full,
    }


def parse_window(fields):
    return {
        "session": fields[1],
        "window": int(fields[2]),
        "name": fields[3][1:] if fields[3].startswith(":") else fields[3],
        "flags": fields[5],
        "layout": fields[6],
    }


def read_save(path):
    panes, windows, state = [], {}, None
    for line in path.read_text().splitlines():
        fields = line.split("\t")
        if fields[0] == "pane" and len(fields) >= 9:
            panes.append(parse_pane(fields))
        elif fields[0] == "window" and len(fields) >= 7:
            w = parse_window(fields)
            windows[(w["session"], w["window"])] = w
        elif fields[0] == "state" and len(fields) >= 2:
            state = fields[1]
    return panes, windows, state


def build_pane(index, pane, rect):
    entry = {
        "pane_id": f"import:p{index}",
        "index": index,
        "label": None,
        "cwd": pane["cwd"],
        "rect": rect,
    }
    command = pane["command"]
    agent = agent_name(command)
    if agent:
        entry["agent"] = {
            "name": agent,
            "argv": None,
            "cmdline": pane["full_command"] or agent,
            "cwd": pane["cwd"],
            "session": None,
        }
    elif command not in SHELLS:
        entry["command"] = {
            "name": command,
            "argv": None,
            "cmdline": pane["full_command"] or command,
            "cwd": pane["cwd"],
            "restorable": command.split("/")[-1] in RESTORABLE,
            "captured_via": "tmux-resurrect",
        }
    return entry


def build(panes, windows, state, only):
    host = socket.gethostname().split(".")[0]
    sessions = sorted({p["session"] for p in panes}, key=str.lower)
    if only:
        sessions = [s for s in sessions if s in only]

    workspaces = []
    focused_workspace = None
    pane_counter = 0

    for number, session in enumerate(sessions, start=1):
        workspace_id = f"import:w{number}"
        if session == state:
            focused_workspace = workspace_id

        tabs = []
        indices = sorted({p["window"] for p in panes if p["session"] == session})
        for tab_number in indices:
            members = sorted(
                (p for p in panes if p["session"] == session and p["window"] == tab_number),
                key=lambda p: p["pane"],
            )
            window = windows.get((session, tab_number))

            rects = []
            if window:
                try:
                    rects = parse_layout(window["layout"])
                except ValueError as exc:
                    print(f"  warning: {session}:{tab_number} layout unreadable ({exc})",
                          file=sys.stderr)
            if len(rects) != len(members):
                rects = [None] * len(members)

            entries = []
            for i, (pane, rect) in enumerate(zip(members, rects)):
                pane_counter += 1
                entries.append(build_pane(i, pane, rect))
                entries[-1]["pane_id"] = f"import:p{pane_counter}"

            label = window["name"] if window else ""
            if label in ("", host, socket.gethostname()):
                label = None

            tabs.append({
                "tab_id": f"{workspace_id}:t{tab_number}",
                "number": tab_number,
                "label": label,
                "zoomed": bool(window and "Z" in window["flags"]),
                "panes": entries,
            })

        first = tabs[0]["panes"][0]["cwd"] if tabs and tabs[0]["panes"] else None
        workspaces.append({
            "workspace_id": workspace_id,
            "number": number,
            "label": session,
            "active_tab_id": tabs[0]["tab_id"] if tabs else None,
            "cwd": first,
            "tabs": tabs,
        })

    return {
        "version": 1,
        "tool": "herdr-resurrect",
        "saved_at": datetime.datetime.now(datetime.timezone.utc)
        .isoformat(timespec="milliseconds")
        .replace("+00:00", "Z"),
        "protocol": None,
        "focused": {"workspace_id": focused_workspace, "tab_id": None, "pane_id": None},
        "workspaces": workspaces,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--file", type=pathlib.Path, default=TMUX_LAST)
    parser.add_argument("--out", type=pathlib.Path)
    parser.add_argument("--only", action="append", default=[])
    parser.add_argument("--set-last", action="store_true")
    args = parser.parse_args()

    if not args.file.exists():
        sys.exit(f"no tmux-resurrect save at {args.file}")

    panes, windows, state = read_save(args.file.resolve())
    model = build(panes, windows, state, set(args.only))
    if not model["workspaces"]:
        sys.exit("nothing to import")

    stamp = model["saved_at"].replace("-", "").replace(":", "")[:15].replace("T", "-")
    out = args.out or SNAP_DIR / f"snapshot-{stamp}-tmux.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(model, indent=2))

    tabs = sum(len(w["tabs"]) for w in model["workspaces"])
    counted = [p for w in model["workspaces"] for t in w["tabs"] for p in t["panes"]]
    agents = sum(1 for p in counted if "agent" in p)
    commands = sum(1 for p in counted if p.get("command", {}).get("restorable"))
    skipped = sum(1 for p in counted if "command" in p and not p["command"]["restorable"])

    print(f"wrote {out}")
    print(f"  {len(model['workspaces'])} workspaces, {tabs} tabs, {len(counted)} panes")
    print(f"  {agents} agents, {commands} commands relaunched, {skipped} not on the allowlist")

    if args.set_last:
        LAST_JSON.parent.mkdir(parents=True, exist_ok=True)
        LAST_JSON.write_text(json.dumps(model, indent=2))
        print(f"  set as {LAST_JSON}")

    plugin = pathlib.Path.home() / ".config/herdr/plugins/github"
    root = next(iter(sorted(plugin.glob("ntindle.herdr-resurrect-*"))), None)
    restore = f"node {root}/bin/restore.js" if root else "herdr plugin action invoke ntindle.herdr-resurrect.restore"
    print()
    print(f"  dry run: {restore} --file {out} --dry-run")
    print(f"  apply:   {restore} --file {out} --recreate")


if __name__ == "__main__":
    main()
