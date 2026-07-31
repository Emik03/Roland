local f = assert(SMODS.load_file "src/lib/funky.lua")() or require "lib.funky"

---@param v string
---@return Card|Tag
local function add(v)
    if v == "op" then
        local op = SMODS.add_card {no_edition = true, key = "j_joker"}
        op.ability.mult = 1e100
        return op
    elseif v == "xop" then
        local xop = SMODS.add_card {no_edition = true, key = "j_Roland_jokersr"}
        xop.ability.extra.xmult = 1e100
        return xop
    end

    if G.P_BLINDS[v] then
        if G.STATE ~= G.STATES.MENU then
            G.from_boss_tag = true
            G.GAME.perscribed_bosses = G.GAME.perscribed_bosses or {}
            G.GAME.perscribed_bosses[G.GAME.round_resets.ante] = v
            G.FUNCS.reroll_boss()
        end

        return G.P_BLINDS[v]
    end

    if not G.P_TAGS[v] then
        return SMODS.add_card {
            no_edition = true,
            key = v,
            area = G.P_CENTERS[v] and
                (({Default = true, Enhanced = true})[G.P_CENTERS[v].set] and G.hand or
                    G.P_CENTERS[v].set == "Booster" and G.shop_booster or
                    G.P_CENTERS[v].set == "Voucher" and G.shop_vouchers) or nil,
        }
    end

    local tag = Tag(v)

    if tag.name == "Orbital Tag" then
        local hands = f(G.GAME.hands):where "visible":keys():table()
        tag.ability.orbital_hand = pseudorandom_element(hands, pseudoseed "Roland_c_orbital_tag")
    end

    add_tag(tag)
    return tag
end

local function simplify(x)
    return type(x) == "string" and x:lower():gsub("%s", ""):gsub("_", ""):gsub("^the", "") or x
end

local function flatten(v)
    return type(v) ~= "table" and {v} or (f.isf(v) and v:table() or v)
end

---@param it string
local function find(it)
    if ({op = true, xop = true})[it] or (G.P_CENTERS[it] or {}).config then
        return it
    end

    local match = simplify(it)

    local pool = match == "Blind" and G.P_BLINDS or
        f(G.P_CENTER_POOLS):any(f.chain(f.arg(2), simplify, f.eq(match)))

    if type(pool) == "table" and next(pool) then
        return pseudorandom_element(pool, pseudoseed "Roland_c").key
    end

    if Cryptid and Cryptid.aliases and Cryptid.aliases[it] then
        return Cryptid.aliases[it]
    end

    return f(G.localization.descriptions)
        :flatmap(flatten)
        :where(type, "table")
        :where(function(v, k)
            return ((G.P_CENTERS[k] or {}).config or G.P_BLINDS[k]) and
                (match == simplify(k) or match == simplify(v.name))
        end)
        :keys()
        :any()
end

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

--- Creates one or more cards.
---@param ... any
---@return Card|Tag|(Card|Tag[])
local function c(...)
    local cards = f {...}
        :flatmap(flatten)
        :where(type, "string")
        :map(string.lower)
        :map(find)
        :where(f.id)
        :map(add)
        :values()
        :table()

    return #cards > 1 and cards or cards[1]
end

return {f, q, u, setmetatable({}, {
    __call = function(_, ...)
        return c(...)
    end,
    __index = function(_, k)
        return c(k)
    end,
    __newindex = function(_, k, v)
        local n = tonumber(v)

        for _ = 1, type(n) == "number" and n or 1 do
            c(k)
        end
    end,
})}
