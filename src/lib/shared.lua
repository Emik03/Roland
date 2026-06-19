local f = assert(SMODS.load_file "src/lib/funky.lua")() or require "lib.funky"

local function protect(fun)
    return function()
        local res, ret = pcall(fun)

        if not res then
            sendErrorMessage(tostring(ret), "Roland")
        end

        return not res or ret ~= false and not (SMODS.current_mod and ret ~= true)
    end
end

local function protect_ev(fun)
    if type(fun) == "function" then
        return Event {func = protect(fun)}
    elseif type(fun) ~= "table" then
        error("Expected a function or table, got a " .. type(fun), 3)
    elseif type(fun.is) == "function" and fun:is(SMODS.GameObject) then
        return Event {
            blocking = false,
            no_delete = true,
            func = protect(function()
                if not Bakery_API or not Bakery_API.credit then
                    return false
                end

                Bakery_API.credit(fun)
            end),
        }
    else
        fun.func = protect(fun.func or fun[1])
        return getmetatable(fun) == Event and fun or Event(fun)
    end
end

--- Queues an event to be run.
--- Note that events added this way implicitly `return true` unless you explicitly `return false`.
--- For `front`; boolean `true` to add the event to the front of the queue, rather than the end.
--- @generic T: fun():boolean?|Event
--- @param fun T|Event|{front?: boolean} The table or function to turn into an event.
--- @return T fun
local function q(fun)
    local ev = protect_ev(fun)
    G.E_MANAGER:add_event(ev, nil, ev.front)
    return fun
end

--- Determines if a center is allowed to be usable.
---@return boolean
local function u()
    return not ((G.play and next(G.play.cards) or G.CONTROLLER.locked or G.GAME.STOP_USE and G.GAME.STOP_USE > 0) and
        G.STATE ~= G.STATES.HAND_PLAYED and
        G.STATE ~= G.STATES.DRAW_TO_HAND and
        G.STATE ~= G.STATES.PLAY_TAROT)
end

return {f, q, u}
