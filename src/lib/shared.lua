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
            func = function()
                if not Bakery_API or not Bakery_API.credit then
                    return false
                end

                Bakery_API.credit(fun)
                return true
            end,
        }
    else
        fun.func = protect(fun.func or fun[1])
        return getmetatable(fun) == Event and fun or Event(fun)
    end
end

---@alias Attributes "mult"|"chips"|"xmult"|"xchips"|"score"|"xscore"|"blindsize"|"xblindsize"|"balance"|"swap"|"retrigger"|"scaling"|"reset"|"suit"|"diamonds"|"hearts"|"spades"|"clubs"|"hand_type"|"rank"|"ace"|"two"|"three"|"four"|"five"|"six"|"seven"|"eight"|"nine"|"ten"|"jack"|"queen"|"king"|"face"|"economy"|"generation"|"destroy_card"|"hands"|"discard"|"hand_size"|"chance"|"joker_slot"|"mod_chance"|"copying"|"full_deck"|"passive"|"joker"|"tarot"|"planet"|"spectral"|"enhancements"|"seals"|"editions"|"tag"|"skip"|"modify_card"|"perma_bonus"|"prevents_death"|"boss_blind"|"reroll"|"on_sell"|"sell_value"|"food"|"space"|"bakery_double_sided"
if false then
    -- This allows for better type inference.
    SMODS.Mods.Roland.config = require "config"

    ---@type Card[]
    CardArea.cards = CardArea.cards

    ---@type userdata|{getWidth: fun(self: self): number}
    SMODS.Atlas.image_data = SMODS.Atlas.image_data

    --- @type { constants?: { TEN: table }, new: (fun(self: self, arr?: number[], sign?: number, noNormalize?: boolean): table), pow: (fun(x: number, y: number): number) }
    _G["Big"] = _G["Big"]

    --- @type fun(area: CardArea, ...: ...): Card
    create_card_for_shop = create_card_for_shop

    -- This exists to remove the @deprecated warning.
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
