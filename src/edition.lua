local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]

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
local frozen_sounds = f(4):map(frozen_sound):map "key":table()

local needs_chip_mult_override = {
    Bull = true,
    Erosion = true,
    Misprint = true,
    TierList = true,
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
        return type(x) == "table" and f(x):map(copy):table() or x
    end

    if frozen_blocklist[(card.ability or {}).name] then
        return card.ability
    end

    local config = card.config or {}

    (card.ability or {}).Roland_crimson = not not (card.ability or {}).Roland_crimson
    card.Roland_frozen_base = card.Roland_frozen_base or copy(card.base)
    card.Roland_frozen_card = card.Roland_frozen_card or copy(config.card)
    card.Roland_frozen_ability = card.Roland_frozen_ability or copy(card.ability)
    card.base = card.Roland_frozen_base and copy(card.Roland_frozen_base) or card.base

    local diff = type(card.set_sprites) == "function" and
        f(card.Roland_frozen_card):diff(config.card, f.chain(type, f.nq "table"))

    config.card = card.Roland_frozen_card and copy(card.Roland_frozen_card) or config.card
    card.ability = card.Roland_frozen_ability and copy(card.Roland_frozen_ability) or card.ability
    card.Roland_frozen = card.Roland_frozen or {probability = SMODS.get_probability_vars(card, 1, 1)}

    if diff then
        card:set_sprites(card.config.center, card.config.card)
    end

    local ability, ret = card.ability, card.Roland_frozen_ability
    ability.extra = ability.extra == nil and {} or ability.extra

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

local function hook_estate()
    ---@param card Card|{ Roland_frozen: {estate: integer} }
    local function estate_pos(card)
        if card.area ~= G.jokers and card.area.config.type ~= "title" then
            return 1
        end

        card.Roland_frozen.estate = card.Roland_frozen.estate or card.rank or 1
        return card.Roland_frozen.estate
    end

    local estate = G.P_CENTERS.j_Bakery_Estate
    local orig_calculate = estate.calculate

    function estate:calculate(card, context, ...)
        if not (card or {}).Roland_frozen or not (card.edition or {}).Roland_frozen then
            return orig_calculate(self, card, context, ...)
        end

        if not context.joker_main then
            return
        end

        local joker_count = estate_pos(card)
        local extra = card.ability.extra
        return {chips = extra.chips * joker_count, mult = extra.mult * joker_count}
    end

    local orig_loc_vars = estate.loc_vars

    function estate:loc_vars(info_queue, card, ...)
        if not (card or {}).Roland_frozen or not (card.edition or {}).Roland_frozen then
            return orig_loc_vars(self, info_queue, card, ...)
        end

        local joker_count = estate_pos(card)
        local extra = card.ability.extra or {}
        return {vars = {extra.chips * joker_count, extra.mult * joker_count}}
    end
end

local function hook_proxy()
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

        return f(G.jokers.cards):any(eq)
    end

    local proxy = G.P_CENTERS.j_Bakery_Proxy
    local orig_calculate = proxy.calculate

    function proxy:calculate(card, context, ...)
        if not (card or {}).Roland_frozen or not (card.edition or {}).Roland_frozen then
            return orig_calculate(self, card, context, ...)
        else
            return SMODS.blueprint_effect(card, get_proxied_joker(card), context)
        end
    end

    local orig_loc_vars = proxy.loc_vars

    function proxy:loc_vars(info_queue, card, ...)
        if not (card or {}).Roland_frozen or not (card.edition or {}).Roland_frozen then
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
end

local function hook_scribe()
    local scribe = G.P_CENTERS.c_Bakery_Scribe
    local orig_can_use = scribe.can_use

    function scribe.can_use(...)
        return orig_can_use(...) and
            (SMODS.Mods.Roland.config.scribable_basket or f(G.jokers.highlighted):all(function(v)
                return v.config.center.key ~= "j_Roland_basket"
            end))
    end
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
        card.Roland_frozen,
        card.Roland_frozen_base,
        card.Roland_frozen_card,
        card.Roland_frozen_ability,
        card.Roland_frozen_current_round = nil, nil, nil, nil, nil
    end,
    get_weight = function(self)
        return self.weight * G.GAME.edition_rate
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

local orig_save = Card.save

function Card:save(...)
    if false then
        ---@type Card|{Roland_frozen: table, Roland_frozen_ability: table, Roland_frozen_base: table, Roland_frozen_card: table, Roland_frozen_current_round: table}
        self = self
    end

    local ret = orig_save(self, ...)

    ret.Roland_frozen,
    ret.Roland_frozen_base,
    ret.Roland_frozen_card,
    ret.Roland_frozen_ability,
    ret.Roland_frozen_current_round =
        self.Roland_frozen,
        self.Roland_frozen_base,
        self.Roland_frozen_card,
        self.Roland_frozen_ability,
        self.Roland_frozen_current_round

    return ret
end

local is_bean = {["Turtle Bean"] = true, j_mp_turtle_bean = true}
local orig_calculate_joker = Card.calculate_joker

---@param self Card|{Roland_frozen_ability?: table}
function Card:calculate_joker(context, ...)
    local is_frozen = self.edition and self.edition.Roland_frozen

    if is_frozen and self.ability.name == "Loyalty Card" then
        return (context.joker_main and self.ability.loyalty_remaining == 0) and
            {xmult = self.ability.extra.Xmult} or nil
    end

    if is_frozen and is_bean[self.ability.name] then
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
    end):where(f.id):table()
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

function SMODS.current_mod.bootstraps_mult(card)
    local ability = card.Roland_frozen_ability
    local ret = math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)

    if not ability then
        return ret
    end

    ability.Roland_bootstraps_mult = ability.Roland_bootstraps_mult or ret
    return ability.Roland_bootstraps_mult
end

function SMODS.get_probability_vars(trigger_obj, ...)
    local numerator, denominator = orig_get_probability_vars(trigger_obj, ...)
    return trigger_obj and (trigger_obj.Roland_frozen or {}).probability or numerator, denominator
end

q {
    blocking = false,
    no_delete = true,
    func = function()
        local orig_flip_double_sided = (Bakery_API or {}).flip_double_sided

        if not orig_flip_double_sided then
            return false
        end

        function Bakery_API.flip_double_sided(card, ...)
            if not card.edition or not card.edition.Roland_frozen then
                return orig_flip_double_sided(card, ...)
            end
        end

        local _ = G.P_CENTERS.j_Bakery_Estate and hook_estate()
        local _ = G.P_CENTERS.c_Bakery_Scribe and hook_scribe()
        local _ = G.P_CENTERS.j_Bakery_Proxy and hook_proxy()
    end,
}
