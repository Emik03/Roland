local f = unpack(... or require "src.functional")

SMODS.Joker {
    key = "rigged",
    atlas = "void",
    config = {extra = {level = "1"}}, -- Strings do not get mutated by other mods, hopefully.
    pos = {x = 0, y = 0},
    eternal_compat = false,
    cost = 8,
    rarity = 2,
    loc_vars = function(_, _, card)
        return {vars = {}}
    end,
}

---@diagnostic disable-next-line: undefined-global
local rarities = Cryptid and
    {{1, "Common"}, {2, "Uncommon"}, {3, "Rare"}, {"cry_epic"}, {4, "Legendary"}, {"cry_exotic"}} or
    {{1, "Common"}, {2, "Uncommon"}, {3, "Rare"}, {4, "Legendary"}}

local orig_poll_rarity = SMODS.poll_rarity

---@diagnostic disable-next-line: duplicate-set-field
function SMODS.poll_rarity(_pool_key, _rand_key)
    local rarity = orig_poll_rarity(_pool_key, _rand_key)

    local max = f(SMODS.find_card "j_Roland_rigged"):reduce(0, function(a, n)
        return n.debuff and a or math.max(a, tonumber(n.ability.extra.level))
    end)

    if f(rarities, ipairs):take(max):filter(function(v)
            return f(v):any(function(vv)
                return vv == rarity
            end)
        end):any() then
        return rarities[max + 1][1] or rarities[#rarities][1]
    end

    return rarity
end

local orig_update = Game.update

---@diagnostic disable-next-line: duplicate-set-field
function Game:update(dt)
    orig_update(self, dt)

    if not G.GAME then
        return
    end

    local candidates = {}

    local max = f(SMODS.find_card "j_Roland_rigged"):reduce(1, function(a, n)
        local level = tonumber(n.ability.extra.level) or 1

        if not candidates[level] then
            candidates[level] = n
        elseif level == 1 then
            candidates[0] = n
        end

        return math.max(a, level)
    end)

    for i = math.min(max, #rarities - 2), 1, -1 do
        if not candidates[i] then
            goto continue
        end

        local skip = true

        for j = i - 1, i == 1 and 0 or 1, -1 do
            if not candidates[j] then
                break
            end

            skip = j > 1
        end

        if skip then
            goto continue
        end

        for j = i - 1, i == 1 and 0 or 1, -1 do
            candidates[i].sell_cost = candidates[i].sell_cost + candidates[j].sell_cost
            candidates[j].ability.extra.level = "-1"
            candidates[j]:start_dissolve()
        end

        local extra = candidates[i].ability.extra
        local level = tonumber(extra.level)
        extra.level = tostring(level + 1)
        candidates[i].children.center:set_sprite_pos({x = 0, y = math.min(level or 0, 2)})
        play_sound("Roland_milestone", 0.9 ^ (level - 2))
        ::continue::
    end
end
