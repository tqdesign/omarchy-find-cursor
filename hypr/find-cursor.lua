-- Double-tap Ctrl to run find-cursor, like Windows' "Show location of pointer
-- when I press the CTRL key". require() this from ~/.config/hypr/hyprland.lua,
-- or paste it into ~/.config/hypr/bindings.lua.
--
-- Hyprland reports XKB keycodes (evdev+8) and timeMs. Ctrl used with another
-- key (Ctrl+C) is a chord, not a tap; any other key between taps cancels.

local DUP_MS = 30
local DOUBLE_MS = 500

local ctrl_key = {
  [37] = true, -- Control_L
  [105] = true, -- Control_R
}
local held = false
local used_as_modifier = false
local last_ms = nil

-- The overlay animates itself; skip the compositor's layer fade.
hl.layer_rule({ match = { namespace = "tqdesign-find-cursor" }, no_anim = true, animation = "none" })

hl.on("input.keyboard.key", function(code, time_ms, state)
  -- state: 0 released, 1 pressed, 2 repeat
  if ctrl_key[code] then
    if state == 1 then
      if held then
        return
      end
      held = true
      used_as_modifier = false
    elseif state == 0 then
      if not held then
        return
      end
      held = false
      if used_as_modifier then
        last_ms = nil
        return
      end
      if last_ms and time_ms >= last_ms then
        local dt = time_ms - last_ms
        if dt < DUP_MS then
          return
        end
        if dt <= DOUBLE_MS then
          last_ms = nil
          hl.exec_cmd("find-cursor")
          return
        end
      end
      last_ms = time_ms
    end
    return
  end

  if state == 1 then
    if held then
      used_as_modifier = true
    end
    last_ms = nil
  end
end)
