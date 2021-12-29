-- Function checks params table fields and game dies if any of required params missed
function check_required_params(params, required_params)
    if (type(params) ~= 'table' or type(required_params) ~= 'table') then
        error('Arguments must be table type!')
    end

    for i, required_param_name in pairs(required_params) do
        if params[required_param_name] == nil then
            error('No param ' .. required_param_name .. '!')
        end
    end
end

-- Function sets params table fields with default values
function set_default_params(params, default_params)
    if (type(params) ~= 'table' or type(default_params) ~= 'table') then
        error('Arguments must be table type!')
    end
    for param_name, param_value in pairs(default_params) do
        if params[param_name] == nil then
            params[param_name] = param_value
        end
        if (type(param_value) == 'table') then
            set_default_params(params[param_name], param_value)
        end
    end
    return params
end

-- Next service functions relays on _GB global table object to save game data

-- Creates timer and adds it to global registry, so we can clean up them all at once later
function timer_add(delay, listener)
    local timer_id
    timer_id = timer.performWithDelay(delay, function()
        listener()
        find_and_remove(_GB.timers, timer_id)
    end, 1)
    table.insert(_GB.timers, timer_id)
    return timer_id
end

-- Removes timer from global registry if we don't want it anymore
function timer_remove(timer_id)
    if timer_id then
        find_and_remove(_GB.timers, timer_id)
        timer.cancel(timer_id)
    end
end

-- Adds listener to global registry
function enterframe_add(listener)
    table.insert(_GB.enterframe_listeners, listener)
end

-- Removes listener from global registry
function enterframe_remove(listener)
    find_and_remove(_GB.enterframe_listeners, listener)
end

-- Enterframe event dispatcher. Here we go through all enterframe listeners we have in registry and execute them one-by-one
local function enterframe_dispatch(event)
    local l = _GB.enterframe_listeners

    for i = 1, #l do
        if (l[i] ~= nil) then
            l[i](event)
        end
    end
end
Runtime:addEventListener('enterFrame', enterframe_dispatch)


-- Get X offset between virtual game resolution and real screen size
function getXOffset()
    return (display.contentWidth - display.actualContentWidth) / 2
end

-- Get Y offset between virtual game resolution and real screen size
function getYOffset()
    return (display.contentHeight - display.actualContentHeight) / 2
end

-- Finds and removes object from table, when we don't know it's index
function find_and_remove(collection, object)
    local l = collection
    local count = table.maxn(l)
    for i = 1, count, 1 do
        if l[i] == object then
            table.remove(l, i)
        end
    end
    return l
end

-- Extend base table library with hasValue - check that element exists in table
function table.hasValue(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
--[[
-- Debug function to recursive print table structure
-- DO NOT USE IN PRODUCTION!
function printTable(t, indent, printedTables)
    if _GB.GD.settings and (_GB.GD.settings.debug == true) then
        local printedTables = printedTables or {}
        if indent == nil then
            indent = ''
        end
        print(indent .. '{')
        indent = indent .. '  '
        for i, v in pairs(t) do
            if type(v) == 'table' then
                print(indent .. tostring(i) .. ':')
                if table.hasValue(printedTables, v) then
                    print('Circular reference! Will not print this table.')
                else
                    table.insert(printedTables, v)
                    indent = printTable(v, indent, printedTables)
                end
            elseif type(v) == 'string' then
                print(indent .. tostring(i) .. ': "' .. v .. '"')
            else
                print(indent .. tostring(i) .. ': ' .. tostring(v))
            end
        end

        indent = string.sub(indent, 1, string.len(indent) - 2)
        print(indent .. '}')

        return indent
    end
end
]]
function print_r(t)
    local utils = require "scripts.libs.utils"
    utils.printTable(t)
end 
-- Create fullscreen black rectangle, which we can use as fadeout between game scenes
local screen_fade_rect = display.newRect(0, 0, display.actualContentWidth, display.actualContentHeight)
screen_fade_rect:setFillColor(0, 0, 0)
screen_fade_rect.anchorX = 0.5
screen_fade_rect.anchorY = 0.5
screen_fade_rect.x = display.contentCenterX
screen_fade_rect.y = display.contentCenterY

-- Simple function to fadeout screen to black
function screenFadeOut(onComplete)
    transition.cancel(screen_fade_rect)
    local onComplete = onComplete or nil
    screen_fade_rect:toFront()
    transition.fadeOut(screen_fade_rect, { time = 800, onComplete = function() if (onComplete ~= nil) then onComplete() end end })
end

-- Function to fadein screen after previous fading out
function screenFadeIn(onComplete)
    transition.cancel(screen_fade_rect)
    local onComplete = onComplete or nil
    screen_fade_rect:toFront()
    transition.fadeIn(screen_fade_rect, { time = 800, onComplete = function() if (onComplete ~= nil) then onComplete() end end })
end

-- Important function to cleanup all game processes when moving between Composer scenes.
-- It needed to prevent memory leaks and suprising bugs.
function clean_scene()
    -- Cancel all running transitions
    transition.cancel()

    -- Go through timer registry and cancel all running timers
    local tmr = timer
    local t = _GB.timers
    for i = 1, #t do
        tmr.cancel(t[i])
        t[i] = nil
    end
    _GB.timers = nil
    _GB.timers = {}

    -- Go through enterframe listeners registry and remove them all
    local l = _GB.enterframe_listeners
    local count = table.maxn(l)
    for i = 1, count, 1 do
        table.remove(l)
    end
    _GB.enterframe_listeners = nil
    _GB.enterframe_listeners = {}

    -- One more time cancel all running transitions, because when we make this first time in beginning of this function,
    -- some transitions may be in onComplete event stages, where they can to run another transitions (even when current ones
    -- was cancelled!)
    transition.cancel()
end

function start_game()
    -- Load saved game state
    -- local path = system.pathForFile('level.json', system.DocumentsDirectory)
    -- local file = io.open(path, 'r')
    -- local data
    -- if file then
    --     local json = require('json')
    --     data = json.decode(file:read('*a'))
    --     io.close(file)
    -- end

        -- If we want to start from very beginning
    _GB.composer.gotoScene('scenes.start')

end
