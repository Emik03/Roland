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
local frozen_blocklist = {CardSleeve = true}
local frozen_sounds = f(4):map(frozen_sound):map("key"):table()

local needs_chip_mult_override = {
    Bull = true,
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
    j_Roland_suitable = "Roland_suitable",
}

SMODS.current_mod.frozen_chip_mult = needs_chip_mult_override
SMODS.current_mod.frozen_current_round = current_round_overrides

local function freeze(card)
    ---@generic T
    ---@param x T
    ---@return T
    local function copy(x)
        return type(x) == "table" and f(x):map(copy):where(function(v, k)
            return k ~= "nine_tally" or v ~= 0
        end):table() or x
    end

    if frozen_blocklist[(card.ability or {}).name] then
        return card.ability
    end

    card.Roland_frozen_ability = card.Roland_frozen_ability or copy(card.ability)
    card.ability = card.Roland_frozen_ability and copy(card.Roland_frozen_ability) or card.ability
    card.Roland_frozen = card.Roland_frozen and {probability = SMODS.get_probability_vars(card, 1, 1)}
    local ability, ret = card.ability, card.Roland_frozen_ability

    if type(ability) ~= "table" then
        return ret
    end

    ability.seal = ability.seal or {}

    if not ability.name or not G.GAME.current_round then
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
    sound = {sound = "Roland_frozen", per = 1, vol = 0.8},
    attributes = {"passive", "scaling", "mod_chance"},
    pronouns = "any_all",
    weight = 8,
    extra_cost = 4,
    in_shop = true,
    apply_to_float = false,
    calculate = function(_, card, context)
        local _ = not context.fix_probability and not context.mod_probability and freeze(card)
    end,
    on_remove = function(card)
        card.Roland_frozen, card.Roland_frozen_ability, card.Roland_frozen_current_round = nil, nil, nil
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

    if is_frozen and self.ability.name == "Loyalty Card" then
        return (context.joker_main and self.ability.loyalty_remaining == 0) and
            {xmult = self.ability.extra.Xmult} or nil
    end

    if is_frozen and self.ability.name == "Turtle Bean" then
        return
    end

    local ret = {orig_calculate_joker(self, context, ...)}

    if not is_frozen or type(ret[1]) ~= "table" then
        return unpack(ret)
    end

    local ability = freeze(self)

    if not needs_chip_mult_override[ability.name] then
        return unpack(ret)
    end

    return f {mult = "mult_mod", chips = "chip_mod", xmult = "xmult", x_mult = "x_mult"}:map(function(v)
        local key = "Roland_frozen_" .. v
        ability[key] = ability[key] or ret[1][v]
        return ability[key]
    end):where(f().id):table()
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

local orig_get_probability_vars = SMODS.get_probability_vars

function G.P_CENTERS.j_erosion:mult(card)
    local ability = card.Roland_frozen_ability
    local ret = math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)

    if not ability then
        return ret
    end

    ability.Roland_erosion_mult = ability.Roland_erosion_mult or ret
    return ability.Roland_erosion_mult
end

function SMODS.get_probability_vars(trigger_obj, ...)
    local numerator, denominator = orig_get_probability_vars(trigger_obj, ...)
    return trigger_obj and (trigger_obj.Roland_frozen or {}).probability or numerator, denominator
end

q(function()
    local estate = G.P_CENTERS.j_Bakery_Estate

    if not estate then
        return
    end

    ---@param card Card|{ Roland_frozen: {estate: integer} }
    local function estate_pos(card)
        if card.area ~= G.jokers and card.area.config.type ~= "title" then
            return 1
        end

        card.Roland_frozen.estate = card.Roland_frozen.estate and
            card.Roland_frozen.estate or
            (f(card.area.cards):swap():any(function(_, k)
                return k == card
            end) or 1)

        return card.Roland_frozen.estate
    end

    local orig_calculate = estate.calculate

    function estate:calculate(card, context, ...)
        if not card or not card.edition or not card.edition.Roland_frozen then
            return orig_calculate(self, card, context, ...)
        end

        if not context.joker_main then
            return
        end

        local joker_count = estate_pos(card)
        local extra = card.ability.extra or {}
        return {chips = extra.chips * joker_count, mult = extra.mult * joker_count}
    end

    local orig_loc_vars = estate.loc_vars

    function estate:loc_vars(info_queue, card, ...)
        if not card or not card.edition or not card.edition.Roland_frozen then
            return orig_loc_vars(self, info_queue, card, ...)
        end

        local joker_count = estate_pos(card)
        local extra = card.ability.extra or {}
        return {vars = {extra.chips * joker_count, extra.mult * joker_count}}
    end
end)

q(function()
    local proxy = G.P_CENTERS.j_Bakery_Proxy

    if not proxy then
        return
    end

    ---@param card Card|{ Roland_frozen: {proxy: string} }
    local function get_proxied_joker(card)
        if not G.jokers or not G.jokers.cards then
            return
        end

        card.Roland_frozen.proxy = card.Roland_frozen.proxy or
            (Bakery_API.get_proxied_joker() or card).config.center.key

        ---@param v Card
        local function eq(v)
            return v.config.center.key == card.Roland_frozen.proxy
        end

        return f(G.jokers.cards):any(eq) ---@type Card?
    end

    local orig_calculate = proxy.calculate

    function proxy:calculate(card, context, ...)
        if not card or not card.edition or not card.edition.Roland_frozen then
            return orig_calculate(self, card, context, ...)
        else
            return SMODS.blueprint_effect(card, get_proxied_joker(card), context)
        end
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

q(function()
    local orig_flip_double_sided = (Bakery_API or {}).flip_double_sided

    if not orig_flip_double_sided then
        return
    end

    function Bakery_API.flip_double_sided(card, ...)
        if not card.edition or not card.edition.Roland_frozen then
            return orig_flip_double_sided(card, ...)
        end
    end
end)
