local function ws_action(move, mode, index)
    return function()
        local active_ws = hl.get_active_workspace()
        if active_ws then
            local id = active_ws.id
            local same_group = (index - 1) * 10 + (id % 10)
            local same_slot = math.floor((id - 1) / 10) * 10 + index
            local target = (mode == "g") and same_group or same_slot
            if move then
                return hl.dispatch(hl.dsp.window.move({ workspace = target }))
            else
                return hl.dispatch(hl.dsp.focus({ workspace = target }))
            end
        end
    end
end

local function resize_by_screen(width_pct, height_pct)
    local screen = hl.get_active_monitor()
    if screen and type(screen.width) == "number" and type(screen.height) == "number" then
        if (width_pct and height_pct) > 0 then
            local w = math.floor(screen.width * width_pct / 100)
            local h = math.floor(screen.height * height_pct / 100)
            return { x = w, y = h, relative = false }
        end
    end
end

local function resize_active_window(width_pct, height_pct)
    local w = 800
    local h = 600
    local win = hl.get_active_window()
    if win and win.size then
        w = win.size.x * (width_pct / 100)
        h = win.size.y * (height_pct / 100)
        return { x = w, y = h, relative = true }
    end
end

local function resizer(title_pattern, width_pct, height_pct, actions, plain_match)
    local window = hl.get_active_window()
    if (window and window.title) and string.find(window.title, title_pattern, 1, plain_match) then
        hl.dispatch(hl.dsp.window.float())
        local action_list = (type(actions) == "table") and actions or { actions }
        for _, action in ipairs(action_list) do
            hl.dispatch(action)
        end
        hl.dispatch(hl.dsp.window.resize(resize_by_screen(width_pct, height_pct)))
        hl.dispatch(hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true" }))
    end
end

local function move_actions()
    local screen = hl.get_active_monitor()
    local win = hl.get_active_window()
    if screen and screen.width and screen.height and win and win.size then
        local monitor_height = screen.height / screen.scale
        local monitor_width = screen.width / screen.scale
        local scale_factor = (monitor_height / 4) / win.size.y
        local target_width = win.size.x * scale_factor
        local target_height = win.size.y * scale_factor
        local x_resize = math.floor(math.max(200, target_width))
        local y_resize = math.floor(math.max(150, target_height))
        local offset = math.min(monitor_width, monitor_height) * 0.03
        local move_x = math.floor(screen.x + monitor_width - x_resize - offset)
        local move_y = math.floor(screen.y + monitor_height - y_resize - offset)
        return {
            hl.dsp.window.resize({ x = x_resize, y = y_resize }),
            hl.dsp.window.move({ x = move_x, y = move_y, relative = false }),
        }
    end
end

return {
    resizer = resizer,
    resize_by_screen = resize_by_screen,
    resize_active_window = resize_active_window,
    ws_action = ws_action,
    move_actions = move_actions,
}
