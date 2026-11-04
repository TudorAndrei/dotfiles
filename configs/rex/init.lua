local P = "ctrl+space>"

local function prefix(key, action, args)
  rex.bind(P .. key, action, args)
end

rex.bind(P .. "ctrl+space", "pane.send_key", { key = "ctrl+space" })

prefix("shift+/", "client.palette.toggle")
prefix("s", "client.settings")
prefix("shift+r", "client.config.reload")
prefix("b", "client.sidebar.toggle")

prefix("g", "session.switch")
prefix("l", "session.switch")
prefix("shift+n", "session.new")
prefix("shift+w", "session.rename")
prefix("shift+d", "session.close")
prefix("shift+]", "session.next")
prefix("shift+[", "session.previous")

local current_window, last_window = {}, {}

local function note_window(sid)
  local view = rex.session.view{ session_id = sid }
  if not view or not view.active_window_id then
    return nil
  end
  local active = view.active_window_id
  if current_window[sid] and current_window[sid] ~= active then
    last_window[sid] = current_window[sid]
  end
  current_window[sid] = active
  return view
end

local function switch_window(fn)
  return function(ctx)
    local view = note_window(ctx.session_id)
    if view then
      fn(ctx, view)
      note_window(ctx.session_id)
    end
    return true
  end
end

prefix("c", "client.tab.new")
prefix("n", "client.tab.rename")
prefix("p", switch_window(function(ctx)
  rex.session.focus_previous_window{ session_id = ctx.session_id }
end))
prefix("shift+x", "client.tab.close")
for i = 1, 9 do
  prefix(tostring(i), switch_window(function(ctx, view)
    local win = view.windows and view.windows[i]
    if win then
      rex.session.focus_window{ session_id = ctx.session_id, window_id = win.window_id }
    end
  end))
end
prefix("tab", switch_window(function(ctx, view)
  local target = last_window[ctx.session_id]
  for _, win in ipairs(view.windows or {}) do
    if win.window_id == target and target ~= view.active_window_id then
      rex.session.focus_window{ session_id = ctx.session_id, window_id = target }
      return
    end
  end
end))

prefix("v", "pane.split", { direction = "right" })
prefix("h", "pane.split", { direction = "down" })
prefix("x", "pane.close")
prefix("z", "pane.zoom")
prefix("shift+p", "pane.copy_id")
prefix("[", "client.find.open")
prefix("f", "pane.float")

rex.mode("resize", { exclusive = true })
prefix("r", "client.mode.enter", { name = "resize" })
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("resize/" .. key, "pane.resize", { direction = dir })
  rex.bind("resize/" .. dir, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/q", "client.mode.exit")

local terminal = "com.superlogical.terminal"
local vim_names = { vim = true, nvim = true, vi = true, view = true, vimdiff = true, nvimdiff = true }

local function runs_vim(block_id)
  local proc = rex.block.call(terminal, "process", { block_id = block_id })
  local fg = proc and proc.foreground
  return fg ~= nil and vim_names[fg.name] == true
end

for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    if ctx.block_id and runs_vim(ctx.block_id) then
      return false
    end
    rex.session.focus_direction{ direction = dir }
    return true
  end)
end

rex.host{ label = "nixos-laptop", endpoint = "http://100.121.29.45:7297" }
