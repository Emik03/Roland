local f, q = unpack(... or require "lib.shared")

SMODS.Joker:take_ownership("joker", {cost = 1}, true)
local orig_set_debuff = Card.set_debuff

function Card:set_debuff(...)
    if SMODS.get_enhancements(self).m_wild and SMODS.Mods.Roland.config.no_wild_debuff then
        self.debuff = false
    else
        orig_set_debuff(self, ...)
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

    f(Bakery_API.get_highlighted()):each(function(v)
        q(function()
            play_sound "tarot1"
            local card = (copier or self)
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

    q {
        delay = 0.7,
        trigger = "after",
        func = function()
            Bakery_API.unhighlight_all()
        end,
    }
end

local orig_use_card = G.FUNCS.use_card

function G.FUNCS.use_card(e, ...)
    if not SMODS.Mods.Roland.config.faster_planets or
        not (((e.config.ref_table or {}).ability or {}).consumeable or {}).hand_type then
        return orig_use_card(e, ...)
    end

    play_sound("tarot1", percent, 0.6)
    e.config.ref_table:use_consumeable(e.config.ref_table.area)

    SMODS.calculate_context {
        using_consumeable = true,
        consumeable = e.config.ref_table,
        area = e.config.ref_table.from_area,
    }

    local normal = G.GAME.pack_choices and e.config.ref_table.area ~= G.pack_cards
    e.config.ref_table:remove()

    if normal then
        return
    end

    G.GAME.pack_choices = G.GAME.pack_choices - 1
    local _ = G.GAME.pack_choices <= 0 and G.FUNCS.end_consumeable()
end

local orig_create_card_for_shop = create_card_for_shop

function create_card_for_shop(...)
    ---@type Card
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
    return ante == 39 and 1e294 or (_G["to_number"] or f().id)(orig_get_blind_amount(ante))
end

local function no_harsh_ante_scaling()
    return not _G["Talisman"] or not SMODS.Mods.Roland.config.harsh_ante_scaling
end

function get_blind_amount(ante, ...)
    local loop = 39

    if ante < loop or no_harsh_ante_scaling() then
        return orig_get_blind_amount(ante, ...)
    end

    if (ante - 9) / 15 >= loop then
        return 1 / 0
    end

    --- @type { constants?: { TEN: table }, new: (fun(self: self, arr?: number[], sign?: number, noNormalize?: boolean): table), pow: (fun(x: number, y: number): number) }
    local big, rem = _G["Big"], tonumber(blind((ante % loop) + 1))

    return ante / 15 >= loop and big:new(f(blind(ante - (loop * 15))):map(f().const(10)):table()) or
        (ante / 9 >= loop and big:new(f(ante / loop - 8):map(f().const(10)):concat {rem}:table()) or
            (ante / 2 >= loop and big:new {rem, ante / loop} or
                (big.constants and big.constants.TEN or big:new {10}):pow(rem)))
end

q(function()
    local scribe = G.P_CENTERS.c_Bakery_Scribe

    if not scribe then
        return true
    end

    local orig_can_use = scribe.can_use

    function scribe.can_use(...)
        return orig_can_use(...) and
            (SMODS.Mods.Roland.config.scribable_basket or f(G.jokers.highlighted):all(function(v)
                return v.config.center.key ~= "j_Roland_basket"
            end))
    end
end)
