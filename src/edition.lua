local f, q = unpack(... or require "lib.shared")

SMODS.Shader {
    key = "frozen",
    path = "frozen.fs",
}

---@param suffix string
local function frozen_sound(suffix)
    local key = "frozen" .. suffix
    return SMODS.Sound {key = key, path = key .. ".ogg"}
end

frozen_sound "_click"
local frozen_sounds = f(4):map(frozen_sound):map("key"):table()

local needs_chip_mult_override = {
    Bull = true,
    Estate = true,
    Erosion = true,
    Misprint = true,
    TierList = true,
    Bootstraps = true,
    ["Blue Joker"] = true,
    ["Abstract Joker"] = true,
    ["Fortune Teller"] = true,
}

local current_round_overrides = {
    Castle = "castle_card",
    Farmer = "farmer_card",
    Tuxedo = "tuxedo_card",
    ["Go Fish"] = "fish_rank",
    ["The Idol"] = "idol_card",
    ["Mail-In Rebate"] = "mail_card",
    Obelisk = "most_played_poker_hand",
    ["Ancient Joker"] = "ancient_card",
    Wherewolf = "Bakery_Wherewolf_card",
}

SMODS.current_mod.frozen_chip_mult = needs_chip_mult_override
SMODS.current_mod.frozen_current_round = current_round_overrides

local function freeze(card)
    ---@generic T
    ---@param x T
    ---@return T
    local function copy(x)
        return type(x) == "table" and f(x):map(copy):where(function(v, k)
            return k ~= "Roland_frozen_proxy" and (k ~= "nine_tally" or v ~= 0)
        end):table() or x
    end

    card.Roland_frozen_ability = card.Roland_frozen_ability or copy(card.ability)
    card.ability = card.Roland_frozen_ability and copy(card.Roland_frozen_ability) or card.ability
    local ret = card.Roland_frozen_ability
    local ability = card.ability

    if type(ability) ~= "table" or not ability.name or not G.GAME.current_round then
        return ret
    end

    local key = current_round_overrides[ability.name]

    if not key then
        return ret
    end

    card.Roland_frozen_current_round = card.Roland_frozen_current_round or copy(G.GAME.current_round[key])
    G.GAME.current_round[key] = copy(card.Roland_frozen_current_round)
    return ret
end

SMODS.Edition {
    key = "frozen",
    shader = "frozen",
    pools = {Joker = true},
    sound = {sound = "Roland_frozen", per = 1, vol = 0.8},
    weight = 8,
    extra_cost = 4,
    in_shop = true,
    apply_to_float = false,
    calculate = function(_, card)
        freeze(card)
    end,
    on_remove = function(card)
        card.Roland_frozen_ability = nil
    end,
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
}

local orig_play_sound = play_sound

function play_sound(sound, pitch, ...)
    if sound ~= "Roland_frozen" and sound ~= "Roland_frozen_click" then
        return orig_play_sound(sound, pitch, ...)
    end

    local overriden_sound = sound == "Roland_frozen" and
        pseudorandom_element(frozen_sounds, pseudoseed "Roland_frozen") or
        sound

    local added_pitch = pseudorandom(pseudoseed "Roland_frozen_pitch") / 4 + 0.8
    return orig_play_sound(overriden_sound, pitch + added_pitch, ...)
end

local orig_click = Card.click

function Card:click(...)
    local highlight = self.highlighted
    local ret = orig_click(self, ...)

    if self.edition and self.edition.Roland_frozen and highlight ~= self.highlighted then
        play_sound("Roland_frozen_click", highlight and 0 or 0.5, 0.6)
    end

    return ret
end

local orig_calculate_joker = Card.calculate_joker

---@param self Card|{Roland_frozen_ability?: table}
function Card:calculate_joker(context, ...)
    local is_frozen = self.edition and self.edition.Roland_frozen

    if is_frozen and self.ability.name == "Turtle Bean" then
        return
    end

    local ret = {orig_calculate_joker(self, context, ...)}

    if not is_frozen or not ret[1] then
        return unpack(ret)
    end

    local ability = freeze(self)

    if not needs_chip_mult_override[ability.name] then
        return unpack(ret)
    end

    ability.Roland_frozen_mult_mod = ability.Roland_frozen_mult_mod or ret[1].mult_mod
    ability.Roland_frozen_chip_mod = ability.Roland_frozen_chip_mod or ret[1].chip_mod
    ability.Roland_frozen_xmult = ability.Roland_frozen_xmult or ret[1].xmult

    return {
        chip_mod = ability.Roland_frozen_chip_mod,
        mult_mod = ability.Roland_frozen_mult_mod,
        xmult = ability.Roland_frozen_xmult,
        message = localize {
            type = "variable",
            key = "a_mult",
            vars = {
                ability.Roland_frozen_mult_mod or
                ability.Roland_frozen_chip_mod or
                ability.Roland_frozen_xmult,
                (ability.Roland_frozen_mult_mod and ability.Roland_frozen_chip_mod) and
                ability.Roland_frozen_chip_mod or nil,
            },
        },
    }
end

local orig_calculate_dollar_bonus = Card.calculate_dollar_bonus

---@param self Card|{Roland_frozen_ability?: table}
function Card:calculate_dollar_bonus(...)
    if not self.edition or not self.edition.Roland_frozen then
        return orig_calculate_dollar_bonus(self, ...)
    end

    local ability = freeze(self)

    if ability.name == "Satellite" then
        ability.Roland_frozen_planets_used = ability.Roland_frozen_planets_used or
            orig_calculate_dollar_bonus(self, ...)

        return self.ability.extra * ability.Roland_frozen_planets_used
    end

    return orig_calculate_dollar_bonus(self, ...)
end

q(function()
    local proxy = G.P_CENTERS.j_Bakery_Proxy

    if not proxy then
        return
    end

    local function get_proxied_joker(card)
        if not G.jokers or not G.jokers.cards then
            return
        end

        local ability = freeze(card)

        ---@param v Card
        local function eq(v)
            return v.unique_val == ability.Roland_frozen_proxy
        end

        ability.Roland_frozen_proxy = (Bakery_API.get_proxied_joker() or card).unique_val
        return f(G.jokers.cards):any(eq) ---@type Card?
    end

    local orig_calculate = proxy.calculate

    ---@param card Card|{ Roland_frozen_ability: table }
    function proxy:calculate(card, context, ...)
        if not card or not card.edition or not card.edition.Roland_frozen then
            return orig_calculate(self, card, context, ...)
        end

        return SMODS.blueprint_effect(card, get_proxied_joker(card), context)
    end

    local orig_loc_vars = proxy.loc_vars

    function proxy:loc_vars(info_queue, card, ...)
        if not card or not card.edition or not card.edition.Roland_frozen then
            return orig_loc_vars(self, info_queue, card, ...)
        end

        local other = get_proxied_joker(card)

        local var = (other and other ~= card) and localize {
            type = "name_text",
            set = other.config.center.set,
            key = other.config.center.key,
        } or localize "k_none"

        return {vars = {var}}
    end
end)
