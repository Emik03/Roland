local function protect(fun)
    return function()
        local res, ret = pcall(fun)

        if not res then
            sendErrorMessage(tostring(ret), "Roland")
        end

        return not res or ret ~= false
    end
end

local function protect_ev(fun)
    if type(fun) == "table" then
        fun.func = protect(fun.func)
        fun = getmetatable(fun) == Event and fun or Event(fun)
    elseif type(fun) == "function" then
        fun = Event {func = protect(fun)}
    else
        error("Expected a function or event, got a " .. type(fun), 3)
    end

    return fun
end

local origf = F
local luaf = assert(SMODS.load_file "src/LuaFunctional/functional.lua")() or require "src.LuaFunctional.functional"
F = origf -- We do not condone globals as side effects!

if false then
    ---Returns the elements from the given `list`. This function is equivalent to
    ---```lua
    ---    return list[i], list[i+1], ···, list[j]
    ---```
    ---
    ---
    ---[View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-unpack"])
    ---
    ---@generic T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
    ---@param list {
    --- [1]?: T1,
    --- [2]?: T2,
    --- [3]?: T3,
    --- [4]?: T4,
    --- [5]?: T5,
    --- [6]?: T6,
    --- [7]?: T7,
    --- [8]?: T8,
    --- [9]?: T9,
    --- [10]?: T10,
    ---}
    ---@param i?   integer
    ---@param j?   integer
    ---@return T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
    ---@nodiscard
    function unpack(list, i, j)
        error {list, i, j}
    end
end

---@class Query<K, V>: metatable
local _ = luaf._proto

--- Creates a non-numerically-indexed query from the given table.
---@param obj table
---@param f_pairs? fun(t: table): unknown
---@param numeric boolean?
---@return Query
local function f(obj, f_pairs, numeric)
    return f_pairs and luaf.from(obj, f_pairs, numeric ~= false) or (obj[1] and luaf.ipairs(obj) or luaf.pairs(obj))
end

--- Queues an event to be run.
--- Note that events added this way implicitly `return true` unless you explicitly `return false`, unlike the vanilla ones.
--- @param fun (fun():false|nil)|Event The event or a function to run turn into an event.
--- @param front boolean|nil `true` to add the event to the front of the queue, rather than the end.
local function q(fun, front)
    G.E_MANAGER:add_event(protect_ev(fun), nil, front)
end

--- Determines if a center is allowed to be usable.
---@return boolean
local function u()
    return not ((G.play and #G.play.cards > 0 or G.CONTROLLER.locked or
            (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) and
        G.STATE ~= G.STATES.HAND_PLAYED and
        G.STATE ~= G.STATES.DRAW_TO_HAND and
        G.STATE ~= G.STATES.PLAY_TAROT)
end

return {f, q, u}
