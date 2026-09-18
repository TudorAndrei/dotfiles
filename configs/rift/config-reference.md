# rift configuration reference

This document details the configuration of `rift`. Copy the example configuration from `rift.default.toml` into `~/.config/rift/config.toml` (or `$HOME/.config/rift/config.toml`) and adjust to taste.

# reference

The default configuration is available [here](https://github.com/acsandmann/rift/blob/main/rift.default.toml) and that is a great example in addition to the reference below.

---

## [settings]
- `animate` (boolean)
  - Master switch for window animations. `true`/`false`.
- `animation_duration` (float)
  - Seconds per animation. Typical values: `0.15`–`0.35`. `0.0` disables duration but keep `animate = false` to fully disable.
- `animation_fps` (float)
  - Frames per second for animations. Values > 0. Recommend 60–120.

Example:
```/dev/null/example.toml#L1-6
[settings]
animate = true
animation_duration = 0.2
animation_fps = 100.0
```

- `default_disable` (boolean)
  - Controls whether newly-created macOS spaces are managed by rift by default.
  - If `true`, spaces start out disabled and must be activated; if `false`, spaces are managed by default and you can disable specific ones.
- `mouse_follows_focus` (boolean)
  - If `true`, when focus changes rift will move the mouse pointer to the focused window.
- `mouse_hides_on_focus` (boolean)
  - If `true`, hide the mouse pointer after focusing a window.
- `focus_follows_mouse` (boolean)
  - If `true`, moving the mouse into a window focuses it.
- `focus_follows_mouse_disable_hotkey` (Hotkey/object)
  - Optional: a hotkey which, while held, temporarily disables `focus_follows_mouse`. (Serialize as the same hotkey shape used in keybindings.)
- `auto_focus_blacklist` (array of strings)
  - Application bundle IDs (e.g. `"com.apple.Spotlight"`) that should not trigger automatic workspace switching or steal focus behavior.
- `run_on_start` (array of strings)
  - Shell commands rift will run on startup. Useful for external integrations or launching helper scripts. When used with `rift-cli subscribe`, rift can send event data via environment variables available to those commands.
- `hot_reload` (boolean)
  - When `true`, rift will watch the configuration file and reload automatically when it changes.

---

## [settings.layout]
Layout system and layout-specific options.

- `mode` (string)
  - `"traditional"` (container-based like i3/sway) or `"bsp"` (binary space partitioning). Defaults to `"traditional"` if omitted.
  - Layout tuning is done via the subtables described below: `[settings.layout.stack]`, `[settings.layout.master_stack]`, `[settings.layout.gaps]`, and `[settings.layout.scrolling]`.

### [settings.layout.stack]
- `stack_offset` (float)
  - How much stacked windows stick out (px). `0.0` means windows fully overlap. Typical 30–50 for visible stacked edges.
- `default_orientation` (string / enum)
  - Controls default stack orientation. Options:
    - `"perpendicular"` (default): choose orientation perpendicular to parent split
    - `"same"`: use the same orientation as the parent split
    - `"horizontal"` / `"vertical"`: force a specific orientation

### [settings.layout.master_stack]
- `master_ratio` (float)
  - Fraction of the screen reserved for the master area when `layout.mode = "master_stack"`. Valid range 0.05–0.95.
- `master_count` (integer)
  - Number of windows kept in the master area. Must be at least `1`.
- `master_side` (string / enum)
  - Placement of the master column: `left`, `right`, `top`, or `bottom`.
- `new_window_placement` (string / enum)
  - Where a new window lands when the master area is already full: `master`, `stack`, or `focused`.

### [settings.layout.gaps]
- `[settings.layout.gaps.outer]`
  - `top`, `left`, `bottom`, `right` (floats): gap between windows and screen edges.
- `[settings.layout.gaps.inner]`
  - `horizontal`, `vertical` (floats): gaps between tiled windows.
- `[settings.layout.gaps.per_display]`
  - map keyed by display UUID. Each key may contain:
    - `"<display-uuid>.outer"`
      - `top`, `left`, `bottom`, `right` (floats): override outer gaps for that display.
    - `"<display-uuid>.inner"`
      - `horizontal`, `vertical` (floats): override inner gaps for that display.
  - Notes: an override may specify only `outer`, only `inner`, or both; any fields present replace the corresponding defaults for that display.

### [settings.layout.scrolling]
- `animate` (boolean, optional)
  - Whether this layout animates transitions regardless of the global `[settings].animate` flag (`None` inherits the global setting).
- `column_width_ratio` (float)
  - Default width of the selected column as a fraction of the screen width (0..1).
- `min_column_width_ratio` (float)
  - Smallest allowed column width ratio used when resizing the strip.
- `max_column_width_ratio` (float)
  - Largest allowed column width ratio used when resizing the strip.
- `alignment` (string / enum)
  - Visual alignment for the focused column: `left`, `center` (default), or `right`.
- `focus_navigation_style` (string / enum)
  - Horizontal navigation behavior: `niri` (default, reveal on demand) or `anchored` (always align focused column to `alignment`).
- `gestures` (table)
  - Configure scroll/swipe gestures within the scrolling layout (see below).

### [settings.layout.scrolling.gestures]
- `enabled` (boolean)
  - Enable horizontal scroll gestures (distinct from workspace swipe gestures) when `true`.
- `invert_horizontal` (boolean)
  - Reverse the direction of the scroll gesture.
- `vertical_tolerance` (float)
  - Maximum absolute vertical delta (normalized) allowed for a gesture to count as horizontal.
- `fingers` (integer)
  - Number of fingers required to trigger a scroll gesture.
- `distance_pct` (float)
  - Normalized horizontal distance (0..1) required to emit a scroll step.
- `propagate_to_workspace_swipe` (boolean)
  - When `true`, overscrolling past the strip boundaries can transition to the next/previous workspace.
- `workspace_switch_threshold` (float)
  - Amount of overscroll (in strip steps) needed before the layout hands control to the workspace switcher (default ~0.625).

---

## [settings.ui]
> [!WARNING]
> the following ui features are experimental

### [settings.ui.menu_bar]
- `enabled` (boolean): show menu bar workspace indicators.
- `show_empty` (boolean): when `true`, include empty workspaces in the menu bar (can cause menubar overflow on macOS).
- `mode` (string / enum)
  - Controls which workspaces appear: `all` (default) or `active`.
- `active_label` (string / enum)
  - How to label the active workspace: `index` (default) or `name`.
- `display_style` (string / enum)
  - How to render a workspace: `layout` (default) or `label`.

### [settings.ui.stack_line]
- `enabled` (boolean): enable experimental stack-line indicator.
- `thickness` (float): thickness in pixels when enabled.
- `horiz_placement` (string): `"top"` / `"bottom"` for horizontal stacks.
- `vert_placement` (string): `"left"` / `"right"` for vertical stacks.
- `spacing` (float): spacing in points between the window edge and the stack line.

### [settings.ui.mission_control]
- `enabled` (boolean): enable mission-control related helpers.
- `fade_enabled` (boolean): whether mission-control fade helper is active.
- `fade_duration_ms` (float): fade duration in milliseconds.

---

## [settings.gestures]
Trackpad gesture configuration.

- `enabled` (boolean): enable horizontal swipes to switch virtual workspaces.
- `invert_horizontal_swipe` (boolean): invert the direction of swipe actions.
- `skip_empty` (boolean): attempt to skip empty workspaces on swipe (if supported).
- `fingers` (integer): number of fingers required for swipe gestures.
- `haptics_enabled` (boolean): enable haptic feedback on swipe commit.

---

## [settings.window_snapping]

- `drag_swap_fraction` (float)
  - Fraction threshold used when dragging a window over another to determine when they should swap positions in the layout.

---

## [virtual_workspaces]
Virtual workspace controls.

- `enabled` (boolean)
  - If `false`, rift acts like a tiler with a single space.
- `default_workspace_count` (integer)
  - Number of workspaces rift creates on startup (recommended 1–32).
- `auto_assign_windows` (boolean)
  - When `true`, new windows can be auto-assigned using `app_rules`.
- `preserve_focus_per_workspace` (boolean)
  - When `true`, rift remembers the last-focused window per virtual workspace.
- `workspace_auto_back_and_forth` (boolean)
  - When `true`, switching to the previously active workspace will return you to the last active workspace (back-and-forth behavior).
- `workspace_names` (array of strings)
  - Optional human-readable names for workspaces in indexed order. If fewer names than `default_workspace_count` are provided, remaining names default to `"Workspace X"`.
- `default_workspace` (integer)
  - Index of the workspace to use as the default active workspace on startup (0-based).
- `reapply_app_rules_on_title_change` (boolean)
  - When `true`, app rules are reapplied if a window title changes (useful with `title_regex`/`title_substring` rules).
- `workspace_rules` (array of objects)
  - Optional layout overrides keyed by workspace index or name so specific workspaces default to a different `layout.mode`.
- `app_rules` (array of objects)
  - Rules that match windows and optionally assign them to workspaces or mark them floating.

### app_rules object fields
- `app_id` (string, optional): application bundle identifier (e.g., `"com.apple.Safari"`).
- `app_name` (string, optional): substring match on application name.
- `title_regex` (string, optional): regex applied to the window title. If present it must be a valid regex or the rule will be ignored with a warning.
- `title_substring` (string, optional): literal substring match (case-sensitive) on window title.
- `ax_role` (string, optional): exact match for the macOS Accessibility AXRole (e.g., `"AXWindow"`, `"AXDialog"`).
- `ax_subrole` (string, optional): exact match for the macOS Accessibility AXSubrole (e.g., `"AXSystemDialog"`).
- `workspace` (integer or string, optional): target workspace (0-based index) or workspace name. If omitted or invalid, defaults to the active workspace.
- `floating` (boolean, optional): whether new windows matched by the rule should float.
- `manage` (boolean, optional): whether Rift should manage matching windows (default = `true`). Set to `false` to ignore certain apps entirely.

Matching semantics:
- All non-empty fields in a rule are combined with logical AND. A rule only matches if every specified field matches.
- Multiple rules may match a window:
  - If multiple matching rules share the same non-empty `app_id`, the rule with more specified conditions (more specific) wins.
  - Otherwise, the rule with the highest specificity (most fields set) is chosen; ties are broken by earlier config order.

Examples:
- Float dialogs for a specific app but tile others:
```/dev/null/example.toml#L1-6
app_rules = [
  { app_id = "com.example.X", title_regex = "Dialog", floating = true },
  { app_id = "com.example.X", floating = false },
]
```
- Float any "Preferences" window for any app:
```/dev/null/example.toml#L1-3
app_rules = [
  { title_substring = "Preferences", floating = true },
]
```

### workspace_rules object fields
- `workspace` (integer or string): workspace index (0-based) or workspace name to target.
- `layout` (string / enum): layout mode that workspace should use. Options: `"traditional"`, `"bsp"`, `"master_stack"`, `"scrolling"`.

Example: make workspace 2 use the master-stack layout by default:
```/dev/null/example.toml#L1-3
workspace_rules = [
  { workspace = 2, layout = "master_stack" },
]
```

---

## [modifier_combinations]
Define reusable modifier combinations to avoid repetition in the keybindings table.

- Example:
```/dev/null/example.toml#L1-2
[modifier_combinations]
comb1 = "Alt + Shift"
```
Then use `comb1` in `[keys]` entries like `"comb1 + H" = { move_node = "left" }`.

---

## [keys]
Keybindings map strings (modifier + key) to commands or command objects.

- Syntax: use quotes around the key combination: `"Alt + Shift + H" = ...`
- Supported modifiers: `Alt`, `Ctrl`, `Shift`, `Meta` (Meta is Command on macOS).
- Available modifier tokens (generic or side-specific): `Alt`/`Option`, `AltLeft`/`OptionLeft`, `AltRight`/`OptionRight`, `Ctrl`/`Control`, `CtrlLeft`/`ControlLeft`, `CtrlRight`/`ControlRight`, `Shift`, `ShiftLeft`, `ShiftRight`, `Meta`/`Cmd`/`Command`, `MetaLeft`/`CmdLeft`/`CommandLeft`, `MetaRight`/`CmdRight`/`CommandRight`.
- Arrow keys can use `ArrowUp`/`Up`, etc. Spacing is flexible.

The configuration parses key strings into the internal hotkey structure; modifier combinations defined in `[modifier_combinations]` will be expanded before parsing.

Example bindings:
```/dev/null/example.toml#L1-10
"Alt + H" = { move_focus = "left" }
"Alt + Shift + Left" = { join_window = "left" }
"Alt + 1" = { switch_to_workspace = 1 }
"comb1 + S" = { switch_to_workspace = 2 }
```

> Note about `comb1` usage: define `comb1` in `[modifier_combinations]` and reference it in `[keys]`.

# commands

- `toggle_space_activated` — Toggle whether the focused macOS space is activated (managed) by rift.
- `next_workspace` / `prev_workspace` — Switch to the next/previous virtual workspace. Pass `true` to force skipping empty workspaces or `false` to include them; omit the argument to use the configured default skip-empty behavior.
- `switch_to_workspace` — Jump to a workspace by index (0-based). If the workspace is already active, `workspace_auto_back_and_forth` may instead return you to the previous workspace.
- `move_window_to_workspace` — Move the focused window (or a specific `window_id`) to another workspace. Accepts `N` or `{ workspace = N, window_id = 123 }`.
- `create_workspace` — Allocate a new virtual workspace.
- `switch_to_last_workspace` — Return to the most recently active workspace.
- `set_workspace_layout` — Change a workspace's layout mode. Example: `{ mode = "scrolling" }` for the active workspace or `{ workspace = 2, mode = "bsp" }` to target a different index. Valid `mode` values: `traditional`, `bsp`, `master_stack`, `scrolling`.
- `next_window` / `prev_window` — Step focus through the windows in the active workspace.
- `ascend` / `descend` — Move focus up/down the layout tree hierarchy.
- `move_focus` — Move focus in a direction: `left`, `right`, `up`, or `down`.
- `move_node` — Move the focused node/window in a direction relative to its current split.
- `join_window` — Merge the focused window into the branch in the given direction.
- `toggle_stack` — Toggle stacked state for the selected container (replaces older `stack_windows` / `unstack_windows`).
- `toggle_orientation` — Toggle the global split/stack orientation behavior.
- `unjoin_windows` — Unjoin previously joined nodes in the layout.
- `toggle_window_floating` — Toggle the focused window between tiled and floating.
- `toggle_focus_floating` — Raise floating windows from the current workspace so they are reachable.
- `toggle_fullscreen` — Enter/exit fullscreen for the focused window, ignoring outer gaps.
- `toggle_fullscreen_within_gaps` — Fullscreen the focused window while keeping the configured outer gaps (fills the tiling area).
- `resize_window_grow` / `resize_window_shrink` — Smartly expand/contract the current selection.
- `resize_window_by` — Resize by a specific `amount` (float), e.g. `{ resize_window_by = { amount = 25.0 } }`.
- `swap_windows` — Swap two `window_id`s (e.g. `[123, 456]` from `serialize` output).
- `show_mission_control_all` — Show Rift's mission control view for all workspaces.
- `show_mission_control_current` — Show Rift's mission control view focused on the current workspace.
- `dismiss_mission_control` — Hide the Rift mission control view if it is active.
- `exec` — Execute an external command. Accepts a string or array (`"exec" = "alacritty"` or `exec = ["sh","-c","echo hello"]`).
- `focus_display` — Move focus to a display using a selector (direction string, 0-based index, or UUID); tries to focus the first window before warping the pointer.
- `move_window_to_display` — Move a window to another display. `selector` accepts a direction (`"left"`, `"right"`, `"up"`, `"down"`), a 0-based index, or a display UUID; include `window_id` to target a specific window or omit it to use the focused/window-under-cursor window.
- `focus_window` — Focus a specific `window_id` (and optional `window_server_id` when needed), useful with `serialize` output.
- `close_window` — Close a window. Provide `window_server_id` if you know it; otherwise Rift closes the tracked current window (usually focused or under the cursor).
- `debug` — Print the active layout tree and relevant debug info.
- `serialize` — Dump Rift's internal state to stdout (useful for debugging or automation).
> Master-stack-only commands:
- `adjust_master_ratio` — Shift the master area size by `delta` (float).
- `adjust_master_count` — Change the number of windows kept in the master area by `delta` (integer).
- `promote_to_master` — Move the focused window into the master area.
- `swap_master_stack` — Swap the master area with the currently active stack.
> Scrolling-layout-only commands:
- `scroll_strip` — Scroll the column strip by a normalized `delta` (e.g. `0.5` for half a column width).
- `snap_strip` — Snap the strip to the nearest column boundary.
- `center_selection` — Toggle a temporary centering override for the focused column without altering `alignment`.
