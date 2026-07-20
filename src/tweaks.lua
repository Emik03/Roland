local f, q, r = (... or require "lib.shared")[1], (... or require "lib.shared")[2], (... or require "lib.shared")[4]
SMODS.Joker:take_ownership("joker", {cost = 1}, true)
local orig_set_debuff = Card.set_debuff

function Card:set_debuff(should_debuff, ...)
    if self.ability.Roland_crimson ~= nil then
        self.ability.Roland_crimson = not not should_debuff
        return
    end

    if SMODS.get_enhancements(self).m_wild and SMODS.Mods.Roland.config.no_wild_debuff then
        self.debuff = false
    else
        orig_set_debuff(self, should_debuff, ...)
    end
end

local orig_use_consumeable = Card.use_consumeable

function Card:use_consumeable(area, copier, ...)
    if SMODS.Mods.Roland.config.faster_planets and self.ability.consumeable.hand_type then
        set_consumeable_usage(self)
        level_up_hand(copier or self, self.ability.consumeable.hand_type, true)
        return
    end

    local seal_spectrals = {["Deja Vu"] = true, Medium = true, Talisman = true, Trance = true}

    if not seal_spectrals[self.ability.name] then
        return orig_use_consumeable(self, area, copier, ...)
    end

    local card = copier or self

    f(Bakery_API.get_highlighted()):each(function(v)
        q(function()
            play_sound "tarot1"
            card:juice_up(0.3, 0.5)
        end)

        q {
            delay = 0.1,
            trigger = "after",
            func = function()
                v:set_seal(self.ability.extra, nil, true)
            end,
        }
    end)

    q {delay = 0.7, trigger = "after", func = Bakery_API.unhighlight_all}
end

local orig_use_card = G.FUNCS.use_card

function G.FUNCS.use_card(e, ...)
    local ref = e.config.ref_table or {}
    local consumeable = (ref.ability or {}).consumeable or {}

    if not SMODS.Mods.Roland.config.faster_planets or
        (not consumeable.hand_type and not consumeable.hand_types) then
        return orig_use_card(e, ...)
    end

    local normal = G.STATE == G.STATES.SHOP or
        ref.area ~= G.pack_cards or
        not G.GAME.pack_choices or
        G.GAME.pack_choices <= 0

    ref.from_area = ref.from_area or ref.area
    play_sound("tarot1", percent, 0.6)
    discover_card(ref.config.center)
    ref:use_consumeable(ref.area)
    SMODS.calculate_context {area = ref.area, consumeable = ref, using_consumeable = true}
    ref:remove()

    if normal then
        return
    end

    G.GAME.pack_choices = G.GAME.pack_choices - 1
    local _ = G.GAME.pack_choices <= 0 and G.FUNCS.end_consumeable()
end

local orig_create_card_for_shop = create_card_for_shop

function create_card_for_shop(...)
    local ret = orig_create_card_for_shop(...)

    if not SMODS.Mods.Roland.config.illusion_seal or
        not G.GAME.used_vouchers.v_illusion or
        not ({Default = true, Enhanced = true})[(((ret or {}).config or {}).center or {}).set] or
        pseudorandom(pseudoseed "Roland_illusion") <= 0.8 then
        return ret
    end

    local seal = SMODS.poll_seal {type_key = "Roland_illusion_seal", guaranteed = true}
    ret:set_seal(seal, true, true)
    return ret
end

local orig_get_blind_amount = get_blind_amount

---@param ante number
---@return table|number
local function blind(ante)
    return ante == 39 and 1e294 or (to_number or f.id)(orig_get_blind_amount(ante))
end

local function no_harsh_ante_scaling()
    return not Talisman or not SMODS.Mods.Roland.config.harsh_ante_scaling
end

---@type (fun(rem: number): number|table)[]
SMODS.current_mod.harsh_ante_scaling = {
    function(rem)
        return (Big.constants and Big.constants.TEN or Big:new {10}):pow(blind(rem + 1))
    end,
    function(rem)
        return Big:new {1, rem + 1}
    end,
    function(rem)
        return Big:new {1, 1, [rem + 2] = 1}
    end,
    function(rem)
        return Big:new {1, 1, [blind(rem) + 2] = 1}
    end,
    function(rem)
        return rem <= 1 and Big:new {1.7976931348623157e308, 1, [1.7975e308] = 1} or 1 / 0
    end,
}

function get_blind_amount(ante, ...)
    local offset = 40

    if ante < offset or no_harsh_ante_scaling() then
        return orig_get_blind_amount(ante, ...)
    end

    local loop = 10

    return f(SMODS.Mods.Roland.harsh_ante_scaling, r):any(function(_, k)
        return (ante - offset) / loop + 1 >= k
    end)((ante - offset) % loop + 1)
end
