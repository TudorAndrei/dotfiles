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
prefix("shift+n", "session.new")
prefix("shift+w", "session.rename")
prefix("shift+d", "session.close")
prefix("shift+]", "session.next")
prefix("shift+[", "session.previous")
prefix("tab", "session.recent")

prefix("c", "client.tab.new")
prefix("n", "client.tab.rename")
prefix("p", "client.tab.previous")
prefix("shift+x", "client.tab.close")
for i = 1, 9 do
  prefix(tostring(i), "client.tab.goto", { index = i })
end

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

local state_rank = { blocked = 1, error = 2, done = 3, working = 4, idle = 5 }
local state_icon = { blocked = "person", error = "star", done = "tag", working = "clock", idle = "terminal" }

local agent_procs = { claude = true, codex = true, pi = true, opencode = true, gemini = true, aider = true, agent = true, amp = true }

local function collect_agents(entries)
  local call = rex.call
  local sessions = call("session.list")
  for _, s in ipairs(type(sessions) == "table" and sessions.sessions or {}) do
    local view = call("session.view", { session_id = s.session_id })
    for _, w in ipairs(type(view) == "table" and view.windows or {}) do
      for _, layer in ipairs(w.layers or {}) do
        for _, b in ipairs(layer.blocks or {}) do
          if b.creator_name == terminal then
            local args = { session_id = s.session_id, block_id = b.block_id }
            local st = call(terminal .. ".program_status", args)
            local rec
            for _, r in ipairs(type(st) == "table" and st.records or {}) do
              if not rec or (state_rank[r.state] or 5) < (state_rank[rec.state] or 5) then
                rec = r
              end
            end
            local app = rec and (rec.effective_app or rec.app)
            if not rec then
              local proc = call(terminal .. ".process", args)
              local fg = type(proc) == "table" and proc.foreground and proc.foreground.name
              if fg and agent_procs[fg] then
                rec, app = {}, fg
              end
            end
            if rec then
              local state = state_rank[rec.state] and rec.state or "idle"
              table.insert(entries, {
                rank = state_rank[state],
                updated = rec.updated_at or "",
                session_id = s.session_id,
                window_id = w.window_id,
                block_id = b.block_id,
                item = {
                  id = b.block_id,
                  title = (app or b.label or "agent") .. " · " .. s.label,
                  subtitle = rec.msg or rec.title or w.label,
                  detail = state,
                  icon = state_icon[state],
                },
              })
            end
          end
        end
      end
    end
  end
end

local function agent_entries()
  local entries = {}
  collect_agents(entries)
  table.sort(entries, function(a, b)
    if a.rank ~= b.rank then return a.rank < b.rank end
    return a.updated > b.updated
  end)
  return entries
end

rex.action{
  name = "agent_picker",
  title = "Agents: Jump to Agent…",
  run = function(ctx)
    local entries = agent_entries()
    if #entries == 0 then
      rex.log("info", "agent_picker: no agents found")
      return
    end
    local items, by_id = {}, {}
    for _, e in ipairs(entries) do
      table.insert(items, e.item)
      by_id[e.item.id] = e
    end
    local id, why = rex.ui.pick{ title = "Jump to agent", placeholder = "Filter agents", items = items }
    if id == nil then
      if why ~= "cancelled" then rex.log("warn", "agent_picker: " .. why) end
      return
    end
    local e = by_id[id]
    rex.call("session.focus_block", { session_id = e.session_id, block_id = e.block_id })
    rex.client.queue("session.select", { session_id = e.session_id, window_id = e.window_id })
  end,
}
prefix("l", "agent_picker")

rex.host{ label = "nixos-laptop", endpoint = "http://100.121.29.45:7297" }
rex.host{ label = "andrei-pc", endpoint = "http://100.108.67.58:7297" }
